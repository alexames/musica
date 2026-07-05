-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Mode representation for scales.
-- A Mode is the pattern of intervals that defines a scale's shape,
-- independent of any tonic (e.g., major, dorian, whole tone). Modes
-- can be rotated with the << and >> operators to derive related
-- modes. Named constants are installed by the musica.modes module.
-- @module musica.mode

local llx = require 'llx'
local pitch = require 'musica.pitch'
local pitch_interval= require 'musica.pitch_interval'
local spiral = require 'musica.spiral'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local Pitch = pitch.Pitch
local PitchInterval = pitch_interval.PitchInterval
local Spiral = spiral.Spiral
local multi_index = util.multi_index
local intervals_to_indices = util.intervals_to_indices

--- Represents a scale mode (a pattern of intervals).
-- Indexing a Mode with a zero-based index yields the PitchInterval
-- from the tonic to that degree; indices wrap through octaves.
-- @type Mode
Mode = class 'Mode' {
  --- Creates a new Mode.
  -- @function Mode:__init
  -- @tparam Mode self
  -- @tparam List semitone_intervals List of PitchIntervals giving
  -- the step between each degree and the next
  -- @usage
  -- local major = Mode(llx.List{
  --   PitchInterval.whole, PitchInterval.whole, PitchInterval.half,
  --   PitchInterval.whole, PitchInterval.whole, PitchInterval.whole,
  --   PitchInterval.half,
  -- })
  __init = function(self, semitone_intervals)
    self.semitone_intervals = semitone_intervals
    local pitch_intervals = {}
    for i, v in ipairs(intervals_to_indices(semitone_intervals)) do
      pitch_intervals[i] = PitchInterval{number=i - 1,
                                         semitone_interval=v}
    end
    self.pitch_intervals = Spiral(pitch_intervals)
  end,

  --- Finds the rotation relating this mode to another.
  -- @function Mode:relative
  -- @tparam Mode self
  -- @tparam Mode mode Another Mode
  -- @treturn number|nil Number of degrees to rotate this mode left
  -- to obtain the given mode, or nil if the modes are unrelated
  relative = function(self, mode)
    for i=1, #self.semitone_intervals do
      local relative_intervals = self.semitone_intervals << i
      if relative_intervals == mode.semitone_intervals then
        return i
      end
    end
    return nil
  end,

  --- Returns the interval spanning one full cycle of the mode.
  -- @return PitchInterval from the tonic to the tonic an octave up
  octave_interval = function(self)
    return self[#self]
  end,

  --- Rotates the mode right by n degrees.
  -- @function Mode:__shr
  -- @tparam Mode self
  -- @tparam number n Number of degrees to rotate
  -- @treturn Mode New Mode starting n degrees earlier
  __shr = function(self, n)
    return Mode(self.semitone_intervals >> n)
  end,

  --- Rotates the mode left by n degrees.
  -- Rotating the major mode left yields its diatonic relatives
  -- (dorian, phrygian, and so on).
  -- @function Mode:__shl
  -- @tparam Mode self
  -- @tparam number n Number of degrees to rotate
  -- @treturn Mode New Mode starting n degrees later
  __shl = function(self, n)
    return Mode(self.semitone_intervals << n)
  end,

  --- Checks equality of two modes.
  -- Modes are equal if their semitone interval patterns are equal.
  -- @function Mode:__eq
  -- @tparam Mode self
  -- @tparam Mode other Another Mode
  -- @treturn boolean true if the interval patterns are equal
  __eq = function(self, other)
    return self.semitone_intervals == other.semitone_intervals
  end,

  --- Returns the number of degrees in the mode.
  -- @return Number of intervals in the mode
  __len = function(self)
    return #self.semitone_intervals
  end,

  --- Allows indexing the mode to get pitch intervals.
  -- @param index Zero-based degree index (or a table of indices)
  -- @return PitchInterval from the tonic to that degree
  __index = multi_index(function(self, index)
      return self.pitch_intervals[index]
    end),

  --- Returns a string representation of the mode.
  -- @return String like "Mode({...})"
  __tostring = function(self)
    return string.format('Mode(%s)',
                         self.semitone_intervals)
  end,
}

return _M
