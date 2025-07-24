-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local accidental = require 'musica.accidental'
local llx = require 'llx'
local pitch_class = require 'musica.pitch_class'
local pitch_interval = require 'musica.pitch_interval'
local pitch_util = require 'musica.pitch_util'

local _ENV, _M = llx.environment.create_module_environment()

local Accidental = accidental.Accidental
local class = llx.class
local isinstance = llx.isinstance
local List = llx.List
local minor_pitch_intervals = pitch_util.minor_pitch_intervals
local PitchClass = pitch_class.PitchClass
local PitchInterval = pitch_interval.PitchInterval
local tointeger = llx.tointeger
local zip = llx.functional.zip

local middle_octave = 4

local lowest_pitch_indices = {
  [PitchClass.A] = 21,
  [PitchClass.B] = 23,
  [PitchClass.C] = 24,
  [PitchClass.D] = 26,
  [PitchClass.E] = 28,
  [PitchClass.F] = 29,
  [PitchClass.G] = 31,
}

Pitch = class 'Pitch' {
  __init = function(self, args)
    local pitch_class = args.pitch_class
    local octave = args.octave or middle_octave
    local accidentals = args.accidentals or 0
    local pitch_index = args.pitch_index
    local midi_index = args.midi_index
    if midi_index then
      -- Handle midi time signatures to guess whether to use sharps or flats.
      -- Write unit tests for this.
      local pitch_classes = {
        [0] = PitchClass.C, PitchClass.C,
        PitchClass.D, PitchClass.D,
        PitchClass.E,
        PitchClass.F, PitchClass.F,
        PitchClass.G, PitchClass.G,
        PitchClass.A, PitchClass.A,
        PitchClass.B,
      }
      pitch_index = midi_index
      pitch_class = pitch_classes[midi_index % 12]
      octave = (midi_index - lowest_pitch_indices[PitchClass.A]) // 12
    end
    self.pitch_class = pitch_class
    self.octave = octave
    if pitch_index then
      local natural_pitch = lowest_pitch_indices[pitch_class] + (self.octave * 12)
      self.accidentals = pitch_index - natural_pitch
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
    -- check_arguments{self=Pitch, pitch_interval=PitchInterval}
    local pitch_class = PitchClass[(self.pitch_class.index + pitch_interval.number - 1) % 7 + 1]
    local octave = math.floor(self.octave + (self.pitch_class.index + pitch_interval.number - 1) / 7)
    local pitch_index = tointeger(self) + tointeger(pitch_interval)
    return Pitch{pitch_class=pitch_class,
                 octave=octave,
                 pitch_index=pitch_index}
  end,

  __sub = function(self, other)
    self, other = llx.metamethod_args(Pitch, self, other)
    -- check_arguments{self=Pitch, other=Union{Pitch,PitchInterval}}
    if isinstance(other, Pitch) then
      local self_pitch_class_octave = (self.pitch_class.index - 1) + self.octave * 7
      local other_pitch_class_octave = (other.pitch_class.index - 1) + other.octave * 7
      return PitchInterval{number=self_pitch_class_octave - other_pitch_class_octave,
                           semitone_interval=tointeger(self) - tointeger(other)}
    elseif isinstance(other, PitchInterval) then
      local pitch_class = PitchClass[(self.pitch_class.index - other.number - 1) % 7 + 1]
      local octave = self.octave + math.floor((self.pitch_class.index - other.number - 1) / 7)
      local pitch_index = tointeger(self) - tointeger(other)
      return Pitch{pitch_class=pitch_class,
                   pitch_index=pitch_index}
    end
  end,

  __tostringf = function(self, formatter)
    formatter:insert(tostring(self))
  end,

  __tostring = function(self)
    if lowest_pitch_indices[PitchClass.A] <= tointeger(self)
        and tointeger(self) < 128
        and Accidental.flat <= self.accidentals
        and self.accidentals <= Accidental.sharp then
      local pitch_class_name = self.pitch_class.name:lower()
      local accidental = ''
      if self.accidentals == Accidental.flat then
        accidental = 'flat'
      elseif self.accidentals == Accidental.sharp then
        accidental = 'sharp'
      end
      return string.format(
          'Pitch.%s%s%s', pitch_class_name, accidental, tostring(self.octave))
    end

    local accidental_string
    if self.accidentals then
      local coeffecient = math.abs(self.accidentals)
      local coeffecient_string
      if coeffecient > 1 then
        coeffecient_string = string.format('%s * ', coeffecient)
      else
        coeffecient_string = ''
      end
      accidental_string = string.format(
          ', accidentals=%s%s', coeffecient_string,
          self.accidentals > 0 and 'Accidental.sharp' or 'Accidental.flat')
    else
      accidental_string = ''
    end
    return string.format('Pitch{pitch_class=%s, octave=%s%s}',
      self.pitch_class, self.octave, accidental_string)
  end,
}

local current_pitch = lowest_pitch_indices[PitchClass.A]
local current_octave = 0
local accidental_args = {
  {suffix='', accidental=Accidental.natural},
  {suffix='flat', accidental=Accidental.flat},
  {suffix='sharp', accidental=Accidental.sharp},
}

local pitch_classes = List{
  PitchClass.A,
  PitchClass.B,
  PitchClass.C,
  PitchClass.D,
  PitchClass.E,
  PitchClass.F,
  PitchClass.G,
}
while current_pitch < 128 do
  for i, pitch_class, interval in zip(pitch_classes, minor_pitch_intervals) do
    for unused, args in ipairs(accidental_args) do
      local pitch_name = pitch_class.name:lower() .. args.suffix .. current_octave
      Pitch[pitch_name] = Pitch{pitch_class=pitch_class,
                                octave=current_octave,
                                accidentals=args.accidental}
    end
    current_pitch = current_pitch + interval
  end
  current_octave = current_octave + 1
end

return _M
