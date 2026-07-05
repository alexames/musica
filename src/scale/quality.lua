-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Chord quality representation.
-- A Quality is the pattern of intervals that defines a chord type
-- (major, minor, and so on), independent of any root pitch. Named
-- constants are provided for the four common triad qualities.
-- @module musica.quality

local llx = require 'llx'
local pitch = require 'musica.pitch'
local pitch_interval = require 'musica.pitch_interval'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local multi_index = util.multi_index
local Pitch = pitch.Pitch
local PitchInterval = pitch_interval.PitchInterval

--- Schema for constructing a quality from explicit pitches.
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

--- Schema for constructing a quality from pitch intervals.
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

--- Represents a chord quality (a pattern of intervals).
-- Intervals are normalized so the first is always a unison.
-- Indexing a Quality with a one-based index yields its
-- PitchIntervals.
-- @type Quality
Quality = llx.class 'Quality' {
  --- Creates a new Quality.
  -- Can be constructed either from a list of pitch intervals or
  -- from a list of pitches (whose intervals above the lowest pitch
  -- are taken).
  -- @function Quality:__init
  -- @tparam Quality self
  -- @tparam table args Construction arguments
  -- @tparam[opt] List args.pitch_intervals List of PitchIntervals
  -- @tparam[opt] List args.pitches List of Pitch objects
  -- @tparam[opt] string args.name Name for the quality
  -- @usage
  -- local q = Quality{pitches=llx.List{Pitch.c4, Pitch.e4, Pitch.g4}}
  -- q == Quality.major  -- true
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

  --- Allows indexing the quality to get pitch intervals.
  -- @param index One-based index (or a table of indices)
  -- @return PitchInterval at that index
  __index = multi_index(function(self, index)
    return self.pitch_intervals[index]
  end),

  --- Checks equality of two qualities.
  -- Qualities are equal if their pitch intervals are equal.
  -- @function Quality:__eq
  -- @tparam Quality self
  -- @tparam Quality other Another Quality
  -- @treturn boolean true if the interval patterns are equal
  __eq = function(self, other)
    return self.pitch_intervals == other.pitch_intervals
  end,

  --- Less-than comparison.
  -- Ordered lexicographically by pitch intervals, then by length.
  -- @function Quality:__lt
  -- @tparam Quality self
  -- @tparam Quality other Another Quality
  -- @treturn boolean true if self orders before other
  __lt = function(self, other)
    local a, b = self.pitch_intervals, other.pitch_intervals
    local n = math.min(#a, #b)
    for i = 1, n do
      if a[i] ~= b[i] then return a[i] < b[i] end
    end
    return #a < #b
  end,

  --- Less-than-or-equal comparison.
  -- @function Quality:__le
  -- @tparam Quality self
  -- @tparam Quality other Another Quality
  -- @treturn boolean true if self orders before or equals other
  __le = function(self, other)
    return self == other or self < other
  end,

  --- Returns the number of notes in the quality.
  -- @return Number of pitch intervals
  __len = function(self)
    return #self.pitch_intervals
  end;

  --- Returns a string representation of the quality.
  -- @return String like "Quality.major" or
  -- "Quality{pitch_intervals=...}"
  __tostring = function(self)
    if self.name then
      return string.format("Quality.%s", self.name)
    end
    return string.format("Quality{pitch_intervals=%s}", self.pitch_intervals)
  end;
}

--- The major triad quality (root, major third, perfect fifth).
Quality.major = Quality{
  name='major',
  pitch_intervals=llx.List{
    PitchInterval.unison,
    PitchInterval.major_third,
    PitchInterval.perfect_fifth,
  },
}
--- The minor triad quality (root, minor third, perfect fifth).
Quality.minor = Quality{
  name='minor',
  pitch_intervals=llx.List{
    PitchInterval.unison,
    PitchInterval.minor_third,
    PitchInterval.perfect_fifth,
  },
}
--- The augmented triad quality (root, major third, augmented fifth).
Quality.augmented = Quality{
  name='augmented',
  pitch_intervals=llx.List{
    PitchInterval.unison,
    PitchInterval.major_third,
    PitchInterval.augmented_fifth,
  },
}
--- The diminished triad quality (root, minor third,
-- diminished fifth).
Quality.diminished = Quality{
  name='diminished',
  pitch_intervals=llx.List{
    PitchInterval.unison,
    PitchInterval.minor_third,
    PitchInterval.diminished_fifth,
  },
}

return _M
