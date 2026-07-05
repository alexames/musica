-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Interval representation for musical pitches.
-- A PitchInterval represents the distance between two pitches as a
-- diatonic number (0=unison, 1=second, ...) plus accidentals that
-- adjust its size in semitones. Intervals support arithmetic: they
-- can be added to Pitches and to each other, subtracted, and scaled
-- by an integer. Named constants (PitchInterval.major_third,
-- PitchInterval.perfect_fifth, etc.) cover the common intervals from
-- unison through octave.
-- @module musica.pitch_interval

local accidental = require 'musica.accidental'
local interval_quality = require 'musica.interval_quality'
local llx = require 'llx'
local pitch_class = require 'musica.pitch_class'
local pitch_util = require 'musica.pitch_util'

local _ENV, _M = llx.environment.create_module_environment()

local Accidental = accidental.Accidental
local check_arguments = llx.check_arguments
local IntervalQuality = interval_quality.IntervalQuality
local isinstance = llx.isinstance
local List = llx.List
local major_pitch_indices = pitch_util.major_pitch_indices
local Number = llx.Number
local PitchClass = pitch_class.PitchClass
local tointeger = llx.tointeger

local PitchIntervalArgs = llx.Schema{
  __name='PitchIntervalArgs',
  type=llx.Table,
  properties={
    number={type=llx.Integer},
    quality={type=llx.Any}, -- need to handle circular dependencies better.
    semitone_interval={type=llx.Integer},
    accidentals={type=llx.Integer},
  }
}

--- Represents a musical interval between two pitches.
-- A PitchInterval combines a diatonic number (0=unison, 1=second,
-- ..., 7=octave) with accidentals measuring the deviation in
-- semitones from the major or perfect form of that interval.
-- Intervals can be compared, added to Pitches, and combined with
-- each other arithmetically.
-- @type PitchInterval
PitchInterval = llx.class 'PitchInterval' {
  --- Creates a new PitchInterval.
  -- Can be constructed from a number and a quality, from a number and
  -- a semitone_interval, or from a number and raw accidentals.
  -- @function PitchInterval:__init
  -- @tparam PitchInterval self
  -- @tparam table args Table with construction parameters
  -- @tparam number args.number Diatonic number (0=unison, 1=second,
  -- ..., 7=octave)
  -- @tparam[opt] IntervalQuality args.quality Interval quality
  -- (major, minor, perfect, diminished, augmented)
  -- @tparam[opt] number args.semitone_interval Total size in
  -- semitones (alternative to quality)
  -- @tparam[opt=0] number args.accidentals Semitone deviation from
  -- the major/perfect interval (alternative to quality)
  -- @usage
  -- local m3 = PitchInterval{number=2, quality=IntervalQuality.minor}
  -- local tritone = PitchInterval{number=3, semitone_interval=6}
  __init = function(self, args)
    local number = args.number
    local quality = args.quality
    local semitone_interval = args.semitone_interval
    local accidentals = args.accidentals or 0

    self.number = number
    if quality then
      self.accidentals = self:_quality_to_accidental(quality)
    elseif semitone_interval then
      self.accidentals = semitone_interval - self:_number_to_semitones()
    else
      self.accidentals = accidentals
    end
  end,

  --- Checks whether the interval is in the perfect family.
  -- Unisons, fourths, fifths, and octaves are perfect intervals;
  -- seconds, thirds, sixths, and sevenths are imperfect.
  -- @function PitchInterval:is_perfect
  -- @tparam PitchInterval self
  -- @treturn boolean true if the interval number is perfect
  is_perfect = function(self)
    check_arguments{self=PitchInterval}
    return PitchInterval.perfect_intervals:contains(self.number % 7)
  end,

  --- Checks if two intervals are enharmonically equivalent.
  -- Two intervals are enharmonic if they span the same number of
  -- semitones but may be spelled differently (e.g., augmented second
  -- and minor third).
  -- @function PitchInterval:is_enharmonic
  -- @tparam PitchInterval self
  -- @tparam PitchInterval other Another PitchInterval to compare
  -- @treturn boolean true if enharmonically equivalent
  is_enharmonic = function(self, other)
    check_arguments{self=PitchInterval, other=PitchInterval}
    return tointeger(self) == tointeger(other)
  end,

  -- Converts the diatonic number to its size in semitones within
  -- the major scale (private helper).
  _number_to_semitones = function(self)
    return major_pitch_indices[self.number]
  end,

  -- Converts an IntervalQuality to an accidental offset, honoring
  -- the perfect/imperfect distinction (private helper).
  _quality_to_accidental = function(self, quality)
    local result
    if self:is_perfect() then
      if quality == IntervalQuality.diminished then
        result = Accidental.flat
      elseif quality == IntervalQuality.perfect then
        result = Accidental.natural
      elseif quality == IntervalQuality.augmented then
        result = Accidental.sharp
      end
    else
      if quality == IntervalQuality.diminished then
        result = 2 * Accidental.flat
      elseif quality == IntervalQuality.minor then
        result = Accidental.flat
      elseif quality == IntervalQuality.major then
        result = Accidental.natural
      elseif quality == IntervalQuality.augmented then
        result = Accidental.sharp
      end
    end
    assert(result ~= nil,
           string.format('invalid quality %s for %s interval',
                         tostring(quality),
                         self:is_perfect() and 'perfect' or 'imperfect'))
    return result
  end,

  --- Adds a PitchInterval or Pitch to this interval.
  -- Adding two intervals yields their sum as a PitchInterval; adding
  -- a Pitch delegates to Pitch addition and yields a Pitch.
  -- @function PitchInterval:__add
  -- @tparam PitchInterval self
  -- @tparam PitchInterval|Pitch other A PitchInterval or Pitch
  -- @treturn PitchInterval|Pitch PitchInterval (if PitchInterval)
  -- or Pitch (if Pitch)
  -- @usage
  -- local p5 = PitchInterval.major_third + PitchInterval.minor_third
  -- local e4 = PitchInterval.major_third + Pitch.c4
  __add = function(self, other)
    check_arguments{
      self=PitchInterval,
      other=llx.Any --[[Union{Pitch,PitchInterval]]
    }
    self, other = llx.metamethod_args(PitchInterval, self, other)
    if isinstance(other, PitchInterval) then
      -- If we are adding to another PitchInterval,
      -- the result is a PitchInterval.
      return PitchInterval{
        number=self.number + other.number,
        semitone_interval=tointeger(self) + tointeger(other)}
    else
      -- If we are adding to a Pitch (or other type with __add), delegate.
      return other + self
    end
  end,

  --- Subtracts another PitchInterval from this one.
  -- @function PitchInterval:__sub
  -- @tparam PitchInterval self
  -- @tparam PitchInterval other The interval to subtract
  -- @treturn PitchInterval The difference between the intervals
  __sub = function(self, other)
    check_arguments{self=PitchInterval, other=PitchInterval}
    return PitchInterval{number=self.number - other.number,
                         semitone_interval=tointeger(self) - tointeger(other)}
  end,

  --- Multiplies the interval by an integer coefficient.
  -- Scales both the diatonic number and the semitone size. Works
  -- with the coefficient on either side of the operator.
  -- @function PitchInterval:__mul
  -- @tparam PitchInterval self
  -- @tparam number coefficient Integer scale factor
  -- @treturn PitchInterval The scaled interval
  __mul = function(self, coefficient)
    self, coefficient = llx.metamethod_args(PitchInterval, self, coefficient)
    check_arguments{self=PitchInterval, coefficient=llx.Integer}
    return PitchInterval{number=coefficient * self.number,
                         semitone_interval=coefficient * tointeger(self)}
  end,

  --- Checks equality of two intervals.
  -- Intervals are equal if they have the same number and accidentals
  -- (i.e., notational equality). For enharmonic equivalence (same
  -- semitone count, possibly different spelling), use is_enharmonic.
  -- @function PitchInterval:__eq
  -- @tparam PitchInterval self
  -- @tparam PitchInterval other Another PitchInterval
  -- @treturn boolean true if notationally equal
  __eq = function(self, other)
    check_arguments{self=PitchInterval, other=PitchInterval}
    return self.number == other.number and self.accidentals == other.accidentals
  end,

  --- Less-than comparison.
  -- Ordered by semitone value first, then by interval number for
  -- enharmonic distinctions (e.g., augmented second < minor third).
  -- @function PitchInterval:__lt
  -- @tparam PitchInterval self
  -- @tparam PitchInterval other Another PitchInterval
  -- @treturn boolean true if self is smaller than other
  __lt = function(self, other)
    check_arguments{self=PitchInterval, other=PitchInterval}
    local self_int = tointeger(self)
    local other_int = tointeger(other)
    if self_int ~= other_int then
      return self_int < other_int
    end
    return self.number < other.number
  end,

  --- Less-than-or-equal comparison.
  -- @function PitchInterval:__le
  -- @tparam PitchInterval self
  -- @tparam PitchInterval other Another PitchInterval
  -- @treturn boolean true if self is smaller than or equal to other
  __le = function(self, other)
    check_arguments{self=PitchInterval, other=PitchInterval}
    return self == other or self < other
  end,

  --- Converts the interval to an integer (size in semitones).
  -- @return Total size of the interval in semitones
  __tointeger = function(self)
    check_arguments{self=PitchInterval}
    return self:_number_to_semitones() + self.accidentals
  end,

  -- Lookup tables mapping accidentals and numbers to the names used
  -- by __tostring (private data).
  __reprPerfectQualities={[-1]="diminished", [0]="perfect", [1]="augmented"},
  __reprImperfectQualities={
    [-2]="diminished", [-1]="minor",
    [0]="major", [1]="augmented",
  },
  __reprNumbers={
    [0]="unison", "second", "third", "fourth",
    "fifth", "sixth", "seventh", "octave",
  },

  --- Returns a string representation of the interval.
  -- @return String like "PitchInterval.major_third", or a
  -- constructor form for intervals without a common name
  __tostring = function(self)
    check_arguments{self=PitchInterval}
    if self.number == 0 and self.accidentals == 0 then
      return "PitchInterval.unison"
    elseif self.number == 7 and self.accidentals == 0 then
      return "PitchInterval.octave"
    elseif 0 <= self.number and self.number <= 7 then
      if self:is_perfect() then
        if (-1 <= self.accidentals) and (self.accidentals <= 1) then
          return ("PitchInterval."
                  .. PitchInterval.__reprPerfectQualities[self.accidentals]
                  .. '_'
                  .. PitchInterval.__reprNumbers[self.number])
        end
      else
        if (-2 <= self.accidentals) and (self.accidentals <= 1) then
          return ("PitchInterval."
                  .. PitchInterval.__reprImperfectQualities[self.accidentals]
                  .. '_'
                  .. PitchInterval.__reprNumbers[self.number])
        end
      end
    end
    return string.format('PitchInterval{number=%s,accidentals=%s}',
                         self.number, self.accidentals)
  end,

  -- Semitone step aliases: one semitone.
  half     = 1,
  halfstep = 1,
  halftone = 1,
  semitone = 1,

  -- Semitone step aliases: two semitones.
  whole     = 2,
  wholestep = 2,
  wholetone = 2,

  -- Interval numbers (mod 7) in the perfect and imperfect families.
  perfect_intervals = List{0, 3, 4},
  imperfect_intervals = List{1, 2, 5, 6},
}

local IQ = IntervalQuality

-- Named interval constants from unison through octave
-- (e.g. PitchInterval.minor_third, PitchInterval.perfect_fifth).
PitchInterval.unison = PitchInterval{
  number=0, quality=IQ.perfect}
PitchInterval.augmented_unison = PitchInterval{
  number=0, quality=IQ.augmented}

PitchInterval.diminished_second = PitchInterval{
  number=1, quality=IQ.diminished}
PitchInterval.minor_second = PitchInterval{
  number=1, quality=IQ.minor}
PitchInterval.major_second = PitchInterval{
  number=1, quality=IQ.major}
PitchInterval.augmented_second = PitchInterval{
  number=1, quality=IQ.augmented}

PitchInterval.diminished_third = PitchInterval{
  number=2, quality=IQ.diminished}
PitchInterval.minor_third = PitchInterval{
  number=2, quality=IQ.minor}
PitchInterval.major_third = PitchInterval{
  number=2, quality=IQ.major}
PitchInterval.augmented_third = PitchInterval{
  number=2, quality=IQ.augmented}

PitchInterval.diminished_fourth = PitchInterval{
  number=3, quality=IQ.diminished}
PitchInterval.perfect_fourth = PitchInterval{
  number=3, quality=IQ.perfect}
PitchInterval.augmented_fourth = PitchInterval{
  number=3, quality=IQ.augmented}

PitchInterval.diminished_fifth = PitchInterval{
  number=4, quality=IQ.diminished}
PitchInterval.perfect_fifth = PitchInterval{
  number=4, quality=IQ.perfect}
PitchInterval.augmented_fifth = PitchInterval{
  number=4, quality=IQ.augmented}

PitchInterval.diminished_sixth = PitchInterval{
  number=5, quality=IQ.diminished}
PitchInterval.minor_sixth = PitchInterval{
  number=5, quality=IQ.minor}
PitchInterval.major_sixth = PitchInterval{
  number=5, quality=IQ.major}
PitchInterval.augmented_sixth = PitchInterval{
  number=5, quality=IQ.augmented}

PitchInterval.diminished_seventh = PitchInterval{
  number=6, quality=IQ.diminished}
PitchInterval.minor_seventh = PitchInterval{
  number=6, quality=IQ.minor}
PitchInterval.major_seventh = PitchInterval{
  number=6, quality=IQ.major}
PitchInterval.augmented_seventh = PitchInterval{
  number=6, quality=IQ.augmented}

PitchInterval.diminished_octave = PitchInterval{
  number=7, quality=IQ.diminished}
PitchInterval.octave = PitchInterval{
  number=7, quality=IQ.perfect}

return _M
