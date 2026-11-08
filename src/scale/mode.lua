-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'
local compat = require 'llx.compat'
local pitch = require 'musica.pitch'
local pitch_interval= require 'musica.pitch_interval'
local spiral = require 'musica.spiral'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local List = llx.List
local Pitch = pitch.Pitch
local PitchInterval = pitch_interval.PitchInterval
local Spiral = spiral.Spiral
local multi_index = util.multi_index
local intervals_to_indices = util.intervals_to_indices

Mode = class 'Mode' {
  __init = function(self, semitone_intervals)
    self.semitone_intervals = semitone_intervals
    local pitch_intervals = {}
    for i, v in ipairs(intervals_to_indices(semitone_intervals)) do
      pitch_intervals[i] = PitchInterval{number=i - 1,
                                         semitone_interval=v}
    end
    self.pitch_intervals = Spiral(pitch_intervals)
  end,

  relative = function(self, mode)
    for i=1, #self.semitone_intervals do
      local relative_intervals = List.__shl(self.semitone_intervals, i)
      if relative_intervals == mode.semitone_intervals then
        return i
      end
    end
    return nil
  end,

  octave_interval = function(self)
    return self[compat.len(self)]
  end,

  --- The mode that starts n degrees later: `Mode.major:rotate_left(5)` is
  -- `Mode.minor`. Also spelled `mode << n` on Lua 5.3 and later.
  -- @param n The number of degrees; a negative n rotates right.
  -- @return A new Mode.
  rotate_left = function(self, n)
    return Mode(List.__shl(self.semitone_intervals, n))
  end,

  --- The mode that starts n degrees earlier: `Mode.major:rotate_right(2)`
  -- is `Mode.minor`. Also spelled `mode >> n` on Lua 5.3 and later.
  -- @param n The number of degrees; a negative n rotates left.
  -- @return A new Mode.
  rotate_right = function(self, n)
    return Mode(List.__shr(self.semitone_intervals, n))
  end,

  __shr = function(self, n)
    return self:rotate_right(n)
  end,

  __shl = function(self, n)
    return self:rotate_left(n)
  end,

  __eq = function(self, other)
    return self.semitone_intervals == other.semitone_intervals
  end,

  __len = function(self)
    return #self.semitone_intervals
  end,

  __index = multi_index(function(self, index)
      return self.pitch_intervals[index]
    end),

  __tostring = function(self)
    return compat.format('Mode(%s)',
                         self.semitone_intervals)
  end,
}

return _M
