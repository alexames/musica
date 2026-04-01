-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'
local pitch = require 'musica.pitch'
local tostringf_module = require 'llx.tostringf'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local isinstance = llx.isinstance
local tointeger = llx.tointeger
local Pitch = pitch.Pitch
local tostringf = tostringf_module.tostringf
local styles = tostringf_module.styles

local dynamics_module = require 'musica.dynamics'
local Dynamic = dynamics_module.Dynamic

local NoteArgs = llx.Schema{
  __name='NoteArgs',
  type=llx.Table,
  properties={
    time={type=llx.Number},
    duration={type=llx.Number},
  },
  required={'pitch', 'duration'},
}

--- Coerce a pitch value to a number.
-- Accepts Pitch objects, enums, or plain numbers.
local function coerce_pitch(value)
  if isinstance(value, llx.Number) then return value end
  return tointeger(value)
end

--- Coerce a volume value to a number.
-- Accepts Dynamic objects or plain numbers.
local function coerce_volume(value)
  if value == nil then return 1.0 end
  if isinstance(value, Dynamic) then return value.volume end
  return value
end

--- A note, with a pitch, time, duration and volume
Note = class 'Note' {
  --- Initializes a Note.
  __init = function(self, arg)
    llx.check_arguments{self=Note, arg=NoteArgs}
    self.pitch = coerce_pitch(arg.pitch)
    self.time = arg.time or 0
    self.duration = arg.duration
    self.volume = coerce_volume(arg.volume)
  end,

  --- Returns a new Note whose duration ends at the given finish time.
  -- @tparam Note self
  -- @tparam number finish The desired finish time
  -- @treturn Note A new Note with adjusted duration
  with_finish = function(self, finish)
    return Note{pitch=self.pitch, time=self.time,
                duration=finish - self.time, volume=self.volume}
  end,

  --- Returns the time at which the note terminates.
  finish = function(self)
    return self.time + self.duration
  end,

  --- Check equality of two notes.
  __eq = function(self, other)
    llx.check_arguments{self=Note, other=Note}
    return self.pitch == other.pitch
           and self.time == other.time
           and self.duration == other.duration
           and self.volume == other.volume
  end,

  --- Less-than comparison.
  -- Ordered by time, pitch, duration, then volume.
  __lt = function(self, other)
    if self.time ~= other.time then
      return self.time < other.time
    end
    if self.pitch ~= other.pitch then
      return self.pitch < other.pitch
    end
    if self.duration ~= other.duration then
      return self.duration < other.duration
    end
    return self.volume < other.volume
  end,

  --- Less-than-or-equal comparison.
  __le = function(self, other)
    return self == other or self < other
  end,

  __tostringf = function(self, formatter)
    formatter:table_cons 'Note' {
      {'pitch', self.pitch},
      {'time', self.time},
      {'duration', self.duration},
      {'volume', self.volume},
    }
  end,

  --- Returns a string representation of the note.
  __tostring = function(self)
    return tostringf(self, styles.abbrev)
  end,
}

return _M
