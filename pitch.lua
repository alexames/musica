require 'llx'
require 'musictheory/pitch_class'
require 'musictheory/pitch_interval'
require 'musictheory/util'

major_pitch_intervals = List{2, 2, 1, 2, 2, 2, 1}
major_pitch_indices = Spiral(intervalsToIndices(major_pitch_intervals))
minor_pitch_intervals = List{2, 1, 2, 2, 1, 2, 2}
minor_pitch_indices = intervalsToIndices(minor_pitch_intervals)

local middle_octave = 4

local sharp = 1
local natural = 0
local flat = -1

local lowest_pitch_indices = {
  [PitchClass.A] = 21,
  [PitchClass.B] = 23,
  [PitchClass.C] = 24,
  [PitchClass.D] = 26,
  [PitchClass.E] = 28,
  [PitchClass.F] = 29,
  [PitchClass.G] = 31
}

Pitch = class 'Pitch' {
  __init = function(self, args)
    local pitch_class = args.pitch_class
    local octave = args.octave or middle_octave
    local accidentals = args.accidentals or 0
    local pitch_index = args.pitch_index

    self.pitch_class = pitch_class
    self.octave = octave
    if pitch_index ~= nil then
      local naturalPitch = lowest_pitch_indices[pitch_class] + (self.octave * 12)
      self.accidentals = pitch_index - naturalPitch
    else
      self.accidentals = accidentals
    end
  end,

  is_enharmonic = function(self, other)
    return tointeger(self) == tointeger(other)
  end,

  __tointeger = function(self)
    return lowest_pitch_indices[self.pitch_class]
           + (self.octave * 12)
           + self.accidentals
  end,

  __eq = function(self, other)
    return tointeger(self) == tointeger(other)
  end,

  __lt = function(self, other)
    return tointeger(self) < tointeger(other)
  end,

  __le = function(self, other)
    return tointeger(self) <= tointeger(other)
  end,

  __add = function(self, pitch_interval)
    assert(isinstance(pitch_interval, PitchInterval))
    local pitch_class = PitchClass[(self.pitch_class.index + pitch_interval.number - 1) % 7 + 1]
    local octave = math.floor(self.octave + (self.pitch_class.index + pitch_interval.number - 1) / 7)
    local pitch_index = tointeger(self) + tointeger(pitch_interval)
    return Pitch{pitch_class=pitch_class,
                 octave=octave,
                 pitch_index=pitch_index}
  end,

  __sub = function(self, other)
    self, other = metamethod_args(Pitch, self, other)
    if isinstance(other, Pitch) then
      local self_pitchClass_octave = (self.pitch_class.index - 1) + self.octave * 7
      local other_pitch_class_octave = (other.pitch_class.index - 1) + other.octave * 7
      return PitchInterval{number=self_pitchClass_octave - other_pitch_class_octave,
                           semitoneInterval=tointeger(self) - tointeger(other)}
    elseif isinstance(other, PitchInterval) then
      local pitch_class = PitchClass[(self.pitch_class.index - other.number - 1) % 7 + 1]
      local octave = self.octave + math.floor((self.pitch_class.index - other.number - 1) / 7)
      local pitch_index = tointeger(self) - tointeger(other)
      return Pitch{pitch_class=pitch_class,
                   pitch_index=pitch_index}
    end
  end,

  __call = function(self, octaveTransposition)
    return Pitch{pitch_class = self.pitch_class,
                 octave=PitchInterval.octave * octaveTransposition,
                 accidentals=self.accidentals}
  end,

  __tostring = function(self)
    local fmt = 'Pitch{pitch_class=%s, octave=%s, accidentals=%s}'
    return fmt:format(self.pitch_class, self.octave, self.accidentals)
  end,

  -- __repr = function(self)
  --   if lowest_pitch_indices[PitchClass.A] <= tointeger(self) and tointeger(self) < 128
  --      and flat <= self.accidentals <= sharp then
  --     pitch_className = self.pitch_class.name:lower()
  --     if self.accidentals == flat then
  --       accidental = "Flat"
  --     elseif self.accidentals == sharp then
  --       accidental = "Sharp"
  --     else
  --       accidental = ""
  --     end
  --     return "Pitch." + pitch_className + accidental + str(self.octave)
  --   end

  --   if self.accidentals then
  --     coeffecient = abs(self.accidentals)
  --     if coeffecient > 1 then
  --       coeffecientString = "%s * " % coeffecient
  --     else
  --       coeffecientString = ""
  --     end
  --     accidentalString = string.format(", accidentals=%s%s",
  --       coeffecientString,
  --       tern(self.accidentals > 0, "sharp", "flat"))
  --   else
  --     accidentalString = ""
  --   end
  --   return string.format("Pitch{%s, octave=%s%s}",
  --     self.pitch_class.name, self.octave, accidentalString)
  -- end
}

local current_pitch = lowest_pitch_indices[PitchClass.A]
local current_octave = 0
local accidentalArgs = {
  {suffix='', accidental=natural},
  {suffix='flat', accidental=flat},
  {suffix='sharp', accidental=sharp},
}

while current_pitch < 128 do
  for pitch_class, interval
      in zip({ivalues(PitchClass)}, {ivalues(minor_pitch_intervals)}) do
    pitch_class = pitch_class[1]
    interval = interval[1]
    for unused, args in ipairs(accidentalArgs) do
      local pitch_name = pitch_class.name:lower() .. args.suffix .. current_octave
      Pitch[pitch_name] = Pitch{pitch_class=pitch_class,
                                octave=current_octave,
                                accidentals=args.accidental}
    end
    current_pitch = current_pitch + interval
  end
  current_octave = current_octave + 1
end
