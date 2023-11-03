require 'llx'
require 'musictheory/util'

-- Pitch Classes
PitchClass = class 'PitchClass' {
  __init = function(self, args)
    self.name = args.name
    self.index = args.index
  end
}

PitchClass.A = PitchClass{name='A', index=1}
PitchClass.B = PitchClass{name='B', index=2}
PitchClass.C = PitchClass{name='C', index=3}
PitchClass.D = PitchClass{name='D', index=4}
PitchClass.E = PitchClass{name='E', index=5}
PitchClass.F = PitchClass{name='F', index=6}
PitchClass.G = PitchClass{name='G', index=7}
PitchClass[1] = PitchClass.A
PitchClass[2] = PitchClass.B
PitchClass[3] = PitchClass.C
PitchClass[4] = PitchClass.D
PitchClass[5] = PitchClass.E
PitchClass[6] = PitchClass.F
PitchClass[7] = PitchClass.G


majorPitchIntervals = List{2, 2, 1, 2, 2, 2, 1}
majorPitchIndices = Spiral(table.unpack(intervalsToIndices(majorPitchIntervals)))
minorPitchIntervals = List{2, 1, 2, 2, 1, 2, 2}
minorPitchIndices = intervalsToIndices(minorPitchIntervals)

middleOctave = 4

sharp = 1
natural = 0
flat = -1

local lowestPitchIndices = {
  [PitchClass.A] = 21,
  [PitchClass.B] = 23,
  [PitchClass.C] = 24,
  [PitchClass.D] = 26,
  [PitchClass.E] = 28,
  [PitchClass.F] = 29,
  [PitchClass.G] = 30
}

IntervalQuality = {
  major = UniqueSymbol('IntervalQuality.major'),
  minor = UniqueSymbol('IntervalQuality.minor'),
  diminished = UniqueSymbol('IntervalQuality.diminished'),
  augmented = UniqueSymbol('IntervalQuality.augmented'),
  perfect = UniqueSymbol('IntervalQuality.perfect'),
}

PitchInterval = class 'PitchInterval' {
  __init = function(self, args)
    local number = args.number
    local quality = args.quality
    local semitoneInterval = args.semitoneInterval
    local accidentals = args.accidentals or 0

    self.number = number
    if quality then
      self.accidentals = self:__qualityToAccidental(quality)
    elseif semitoneInterval then
      self.accidentals = semitoneInterval - self:__numberToSemitones()
    else
      self.accidentals = accidentals
    end
  end;

  isPerfect = function(self)
    return PitchInterval.perfectIntervals:contains(self.number % 7)
  end;

  isEnharmonic = function(self, other)
    return int(self) == int(other)
  end;

  __numberToSemitones = function(self)
    return majorPitchIndices[self.number]
  end;

  __qualityToAccidental = function(self, quality)
    if self:isPerfect() then
      if quality == IntervalQuality.diminished then
        accidentals = flat
      elseif quality == IntervalQuality.perfect then
        accidentals = natural
      elseif quality == IntervalQuality.augmented then
        accidentals = sharp
      end
    else
      if quality == IntervalQuality.diminished then
        accidentals = 2 * flat
      elseif quality == IntervalQuality.minor then
        accidentals = flat
      elseif quality == IntervalQuality.major then
        accidentals = natural
      elseif quality == IntervalQuality.augmented then
        accidentals = sharp
      end
    end
    return accidentals
  end;

  __add = function(self, other)
    -- If you're adding to another pitch interval, the result is a pitch interval
    if getmetatable(other) == PitchInterval then
      return PitchInterval{
        number=self.number + other.number,
        semitoneInterval=int(self) + int(other)}
    end
    -- If you're adding to a Pitch, the result == a pitch.
    if getmetatable(other) == Pitch then
      return other + self
    end
  end;

  __sub = function(self, other)
    return PitchInterval{number=self.number - other.number,
                         semitoneInterval=int(self) - int(other)}
  end;

  __mul = function(self, coeffecient)
    return PitchInterval{number=coeffecient * self.number,
                         semitoneInterval=coeffecient * int(self)}
  end;

  __eq = function(self, other)
    return self.number == other.number and self.accidentals == other.accidentals
  end;

  __int = function(self)
    return self:__numberToSemitones() + self.accidentals
  end;

  __reprPerfectQualities={[-1]="diminished", [0]="perfect", [1]="augmented"},
  __reprImperfectQualities={[-2]="diminished", [-1]="minor", [0]="major", [1]="augmented"},
  __reprNumbers={"Unison", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Octave"},

  __repr = function(self)
    if self.number == 0 and self.accidentals == 0 then
      return "PitchInterval.unison"
    elseif self.number == 7 and self.accidentals == 0 then
      return "PitchInterval.octave"
    elseif 0 <= self.number <= 7 then
      if self:isPerfect() then
        if -1 <= self.accidentals <= 1 then
          return ("PitchInterval."
                  + PitchInterval.__reprPerfectQualities[self.accidentals]
                  + PitchInterval.__reprNumbers[self.number])
        end
      else
        if -2 <= self.accidentals <= 1 then
          return ("PitchInterval."
                  + PitchInterval.__reprImperfectQualities[self.accidentals]
                  + PitchInterval.__reprNumbers[self.number])
        end
      end
    end
    return reprArgs('PitchInterval',
                    {{'number', self.number},
                     {'accidentals', self.accidentals, 0}})
  end;

  half     = 1,
  halfstep = 1,
  halftone = 1,
  semitone = 1,

  whole     = 2,
  wholestep = 2,
  wholetone = 2,

  perfectIntervals = List{0, 3, 4},
  imperfectIntervals = List{1, 2, 5, 6},
}

PitchInterval.unison           = PitchInterval{number=0, quality=IntervalQuality.perfect}
PitchInterval.augmentedUnison  = PitchInterval{number=0, quality=IntervalQuality.augmented}

PitchInterval.diminishedSecond = PitchInterval{number=1, quality=IntervalQuality.diminished}
PitchInterval.minorSecond      = PitchInterval{number=1, quality=IntervalQuality.minor}
PitchInterval.majorSecond      = PitchInterval{number=1, quality=IntervalQuality.major}
PitchInterval.augmentedSecond  = PitchInterval{number=1, quality=IntervalQuality.augmented}

PitchInterval.diminishedThird  = PitchInterval{number=2, quality=IntervalQuality.diminished}
PitchInterval.minorThird       = PitchInterval{number=2, quality=IntervalQuality.minor}
PitchInterval.majorThird       = PitchInterval{number=2, quality=IntervalQuality.major}
PitchInterval.augmentedThird   = PitchInterval{number=2, quality=IntervalQuality.augmented}

PitchInterval.diminishedFourth = PitchInterval{number=3, quality=IntervalQuality.diminished}
PitchInterval.perfectFourth    = PitchInterval{number=3, quality=IntervalQuality.perfect}
PitchInterval.augmentedFourth  = PitchInterval{number=3, quality=IntervalQuality.augmented}

PitchInterval.diminishedFifth  = PitchInterval{number=4, quality=IntervalQuality.diminished}
PitchInterval.perfectFifth     = PitchInterval{number=4, quality=IntervalQuality.perfect}
PitchInterval.augmentedFifth   = PitchInterval{number=4, quality=IntervalQuality.augmented}

PitchInterval.diminishedSixth  = PitchInterval{number=5, quality=IntervalQuality.diminished}
PitchInterval.minorSixth       = PitchInterval{number=5, quality=IntervalQuality.minor}
PitchInterval.majorSixth       = PitchInterval{number=5, quality=IntervalQuality.major}
PitchInterval.augementedSixth  = PitchInterval{number=5, quality=IntervalQuality.augmented}

PitchInterval.dimishedSeventh  = PitchInterval{number=6, quality=IntervalQuality.diminished}
PitchInterval.minorSeventh     = PitchInterval{number=6, quality=IntervalQuality.minor}
PitchInterval.majorSeventh     = PitchInterval{number=6, quality=IntervalQuality.major}
PitchInterval.augmentedSeventh = PitchInterval{number=6, quality=IntervalQuality.augmented}

PitchInterval.dimishedOctave   = PitchInterval{number=7, quality=IntervalQuality.diminished}
PitchInterval.octave           = PitchInterval{number=7, quality=IntervalQuality.perfect}


Pitch = class 'Pitch' {
  __init = function(self, args)
    local pitchClass = args.pitchClass
    local octave = args.octave or middleOctave
    local accidentals = args.accidentals or 0
    local pitchIndex = args.pitchIndex

    self.pitchClass = pitchClass
    self.octave = octave
    if pitchIndex ~= nil then
      naturalPitch = lowestPitchIndices[pitchClass] + (self.octave * 12)
      self.accidentals = pitchIndex - naturalPitch
    else
      self.accidentals = accidentals
    end
  end;

  isEnharmonic = function(self, other)
    return int(self) == int(other)
  end;

  __int = function(self)
    return lowestPitchIndices[self.pitchClass] + (self.octave * 12) + self.accidentals
  end;

  __eq = function(self, other)
    return int(self) == int(other)
  end;

  __lt = function(self, other)
    return int(self) < int(other)
  end;

  __le = function(self, other)
    return int(self) <= int(other)
  end;

  __add = function(self, pitchInterval)
    pitchClass = PitchClass[(self.pitchClass.index + pitchInterval.number - 1) % 7 + 1]
    octave = math.floor(self.octave + (self.pitchClass.index + pitchInterval.number - 1) / 7)
    pitchIndex = int(self) + int(pitchInterval)
    return Pitch{pitchClass=pitchClass,
                 octave=octave,
                 pitchIndex=pitchIndex}
  end;

  __sub = function(self, other)
    if getmetatable(other) == Pitch then
      selfPitchClassOctave = (self.pitchClass.index - 1) + self.octave * 7
      otherPitchClassOctave = (other.pitchClass.index - 1) + other.octave * 7
      return PitchInterval{number=selfPitchClassOctave - otherPitchClassOctave,
                           semitoneInterval=int(self) - int(other)}
    elseif getmetatable(other) == PitchInterval then
      pitchClass = PitchClass[(self.pitchClass.index - other.number - 1) % 7 + 1]
      octave = self.octave + math.floor((self.pitchClass.index - other.number - 1) / 7)
      pitchIndex = int(self) - int(other)
      return Pitch{pitchClass=pitchClass,
                   pitchIndex=pitchIndex}
    end
  end;

  __call = function(self, octaveTransposition)
    return Pitch{pitchClass = self.pitchClass,
                 octave=PitchInterval.octave * octaveTransposition,
                 accidentals=self.accidentals}
  end;


  __repr = function(self)
    if lowestPitchIndices[PitchClass.A] <= int(self) and int(self) < 128
       and flat <= self.accidentals <= sharp then
      pitchClassName = self.pitchClass.name:lower()
      if self.accidentals == flat then
        accidental = "Flat"
      elseif self.accidentals == sharp then
        accidental = "Sharp"
      else
        accidental = ""
      end
      return "Pitch." + pitchClassName + accidental + str(self.octave)
    end

    if self.accidentals then
      coeffecient = abs(self.accidentals)
      if coeffecient > 1 then
        coeffecientString = "%s * " % coeffecient
      else
        coeffecientString = ""
      end
      accidentalString = string.format(", accidentals=%s%s",
        coeffecientString,
        tern(self.accidentals > 0, "sharp", "flat"))
    else
      accidentalString = ""
    end
    return string.format("Pitch{%s, octave=%s%s}",
      self.pitchClass.name, self.octave, accidentalString)
  end
}

local currentPitch = lowestPitchIndices[PitchClass.A]
local currentOctave = 0
local accidentalArgs = {
  {suffix='', accidental=natural},
  {suffix='Flat', accidental=flat},
  {suffix='Sharp', accidental=sharp},
}

while currentPitch < 128 do
  for pitchClass, interval in zip({ivalues(PitchClass)}, {ivalues(minorPitchIntervals)}) do
    pitchClass = PitchClass[1]
    interval = interval[1]
    for unused, args in ipairs(accidentalArgs) do
      local pitchName = pitchClass.name:lower() .. args.suffix .. currentOctave
      Pitch[pitchName] = Pitch{pitchClass=pitchClass,
                               octave=currentOctave,
                               accidentals=args.accidental}
    end
    currentPitch = currentPitch + interval
  end
  currentOctave = currentOctave + 1
end
