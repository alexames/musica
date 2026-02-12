-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'
local pitch = require 'musica.pitch'
local pitch_interval = require 'musica.pitch_interval'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local multi_index = util.multi_index
local Pitch = pitch.Pitch
local PitchInterval = pitch_interval.PitchInterval

local QualityByPitches = llx.Schema{
  __name='QualityByPitches',
  type=llx.Table,
  properties={
    pitches={
      type=llx.List,
      items={type=Pitch},
    },
    name={type=llx.String},
  },
  required={'pitches'},
}

local QualityByPitchIntervals = llx.Schema{
  __name='QualityByPitchIntervals',
  type=llx.Table,
  properties={
    pitch_intervals={
      type=llx.List,
      items={type=PitchInterval},
    },
    name={type=llx.String},
  },
  required={'pitch_intervals'},
}

Quality = llx.class 'Quality' {
  __init = function(self, args)
    self.name = args.name
    local pitch_intervals = args.pitch_intervals
    local pitches = args.pitches
    if pitch_intervals then
      -- Defensive copy to avoid mutating the caller's list
      pitch_intervals = llx.List(pitch_intervals)
      if pitch_intervals[1] ~= PitchInterval.unison then
        local first_interval = pitch_intervals[1]
        for i, interval in ipairs(pitch_intervals) do
          pitch_intervals[i] = interval - first_interval
        end
      end
    elseif pitches then
      pitch_intervals = llx.List{}
      -- Defensive copy to avoid mutating the caller's list
      pitches = llx.List(pitches)
      table.sort(pitches)
      local first_pitch = pitches[1]
      for i, pitch in ipairs(pitches) do
        pitch_intervals[i] = pitch - first_pitch
      end
    end
    self.pitch_intervals = pitch_intervals
  end,

  __index = multi_index(function(self, index)
    return self.pitch_intervals[index]
  end),

  __eq = function(self, other)
    return self.pitch_intervals == other.pitch_intervals
  end;

  __len = function(self)
    return #self.pitch_intervals
  end;

  __tostring = function(self)
    if self.name then
      return string.format("Quality.%s", self.name)
    end
    return string.format("Quality{pitch_intervals=%s}", self.pitch_intervals)
  end;
}

Quality.major = Quality{name='major', pitch_intervals=llx.List{PitchInterval.unison, PitchInterval.major_third, PitchInterval.perfect_fifth}}
Quality.minor = Quality{name='minor', pitch_intervals=llx.List{PitchInterval.unison, PitchInterval.minor_third, PitchInterval.perfect_fifth}}
Quality.augmented = Quality{name='augmented', pitch_intervals=llx.List{PitchInterval.unison, PitchInterval.major_third, PitchInterval.augmented_fifth}}
Quality.diminished = Quality{name='diminished', pitch_intervals=llx.List{PitchInterval.unison, PitchInterval.minor_third, PitchInterval.diminished_fifth}}

return _M
