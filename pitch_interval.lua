require 'llx'
require 'musictheory/accidental'
require 'musictheory/interval_quality'
require 'musictheory/pitch_class'
require 'musictheory/util'

PitchInterval = class 'PitchInterval' {
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

  is_perfect = function(self)
    return PitchInterval.perfect_intervals:contains(self.number % 7)
  end,

  is_enharmonic = function(self, other)
    return tointeger(self) == tointeger(other)
  end,

  _number_to_semitones = function(self)
    return major_pitch_indices[self.number]
  end,

  _quality_to_accidental = function(self, quality)
    if self:is_perfect() then
      if quality == IntervalQuality.diminished then
        accidentals = Accidental.flat
      elseif quality == IntervalQuality.perfect then
        accidentals = Accidental.natural
      elseif quality == IntervalQuality.augmented then
        accidentals = Accidental.sharp
      end
    else
      if quality == IntervalQuality.diminished then
        accidentals = 2 * Accidental.flat
      elseif quality == IntervalQuality.minor then
        accidentals = Accidental.flat
      elseif quality == IntervalQuality.major then
        accidentals = Accidental.natural
      elseif quality == IntervalQuality.augmented then
        accidentals = Accidental.sharp
      end
    end
    return accidentals
  end,

  __add = function(self, other)
    self, other = metamethod_args(PitchInterval, self, other)
    if isinstance(other, PitchInterval) then
      -- If we are adding to another PitchInterval, the result is a PitchInterval.
      return PitchInterval{
        number=self.number + other.number,
        semitone_interval=tointeger(self) + tointeger(other)}
    elseif isinstance(other, Pitch) then
      -- If we are adding to a Pitch, the result is a pitch.
      return other + self
    end
  end,

  __sub = function(self, other)
    return PitchInterval{number=self.number - other.number,
                         semitone_interval=tointeger(self) - tointeger(other)}
  end,

  __mul = function(self, coeffecient)
    self, coeffecient = metamethod_args(PitchInterval, self, coeffecient)
    return PitchInterval{number=coeffecient * self.number,
                         semitone_interval=coeffecient * tointeger(self)}
  end,

  __eq = function(self, other)
    return self.number == other.number and self.accidentals == other.accidentals
  end,

  __tointeger = function(self)
    return self:_number_to_semitones() + self.accidentals
  end,

  __reprPerfectQualities={[-1]="diminished", [0]="perfect", [1]="augmented"},
  __reprImperfectQualities={[-2]="diminished", [-1]="minor", [0]="major", [1]="augmented"},
  __reprNumbers={[0]="unison", "second", "third", "fourth", "fifth", "sixth", "seventh", "octave"},

  __tostring = function(self)
    if self.number == 0 and self.accidentals == 0 then
      return "PitchInterval.unison"
    elseif self.number == 7 and self.accidentals == 0 then
      return "PitchInterval.octave"
    elseif (0 <= self.number) and (self.number <= 7) then
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
    return repr_args('PitchInterval',
                    {{'number', self.number},
                     {'accidentals', self.accidentals, 0}})
  end,

  half     = 1,
  halfstep = 1,
  halftone = 1,
  semitone = 1,

  whole     = 2,
  wholestep = 2,
  wholetone = 2,

  perfect_intervals = List{0, 3, 4},
  imperfect_intervals = List{1, 2, 5, 6},
}

PitchInterval.unison            = PitchInterval{number=0, quality=IntervalQuality.perfect}
PitchInterval.augmented_unison  = PitchInterval{number=0, quality=IntervalQuality.augmented}

PitchInterval.diminished_second = PitchInterval{number=1, quality=IntervalQuality.diminished}
PitchInterval.minor_second      = PitchInterval{number=1, quality=IntervalQuality.minor}
PitchInterval.major_second      = PitchInterval{number=1, quality=IntervalQuality.major}
PitchInterval.augmented_second  = PitchInterval{number=1, quality=IntervalQuality.augmented}

PitchInterval.diminished_third  = PitchInterval{number=2, quality=IntervalQuality.diminished}
PitchInterval.minor_third       = PitchInterval{number=2, quality=IntervalQuality.minor}
PitchInterval.major_third       = PitchInterval{number=2, quality=IntervalQuality.major}
PitchInterval.augmented_third   = PitchInterval{number=2, quality=IntervalQuality.augmented}

PitchInterval.diminished_fourth = PitchInterval{number=3, quality=IntervalQuality.diminished}
PitchInterval.perfect_fourth    = PitchInterval{number=3, quality=IntervalQuality.perfect}
PitchInterval.augmented_fourth  = PitchInterval{number=3, quality=IntervalQuality.augmented}

PitchInterval.diminished_fifth  = PitchInterval{number=4, quality=IntervalQuality.diminished}
PitchInterval.perfect_fifth     = PitchInterval{number=4, quality=IntervalQuality.perfect}
PitchInterval.augmented_fifth   = PitchInterval{number=4, quality=IntervalQuality.augmented}

PitchInterval.diminished_sixth  = PitchInterval{number=5, quality=IntervalQuality.diminished}
PitchInterval.minor_sixth       = PitchInterval{number=5, quality=IntervalQuality.minor}
PitchInterval.major_sixth       = PitchInterval{number=5, quality=IntervalQuality.major}
PitchInterval.augemented_sixth  = PitchInterval{number=5, quality=IntervalQuality.augmented}

PitchInterval.dimished_seventh  = PitchInterval{number=6, quality=IntervalQuality.diminished}
PitchInterval.minor_seventh     = PitchInterval{number=6, quality=IntervalQuality.minor}
PitchInterval.major_seventh     = PitchInterval{number=6, quality=IntervalQuality.major}
PitchInterval.augmented_seventh = PitchInterval{number=6, quality=IntervalQuality.augmented}

PitchInterval.dimished_octave   = PitchInterval{number=7, quality=IntervalQuality.diminished}
PitchInterval.octave            = PitchInterval{number=7, quality=IntervalQuality.perfect}
