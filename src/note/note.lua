-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Note representation.
-- A Note combines a pitch with a start time, duration, and volume.
-- Pitches may be given as Pitch objects or plain numbers; volumes
-- as Dynamic objects or numbers in [0, 1].
-- @module musica.note

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

--- Schema for Note construction arguments.
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
-- @type Note
Note = class 'Note' {
  --- Initializes a Note.
  -- @function Note:__init
  -- @tparam Note self
  -- @tparam table arg Table with construction parameters
  -- @tparam Pitch|number arg.pitch The note's pitch
  -- @tparam[opt=0] number arg.time Start time in beats
  -- @tparam number arg.duration Length of the note in beats
  -- @tparam[opt=1.0] Dynamic|number arg.volume Volume in [0, 1]
  -- @usage
  -- local n = Note{pitch=Pitch.c4, time=0, duration=1, volume=0.7}
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
  -- @return Time in beats at which the note ends
  finish = function(self)
    return self.time + self.duration
  end,

  --- Check equality of two notes.
  -- Notes are equal if pitch, time, duration, and volume all match.
  -- @function Note:__eq
  -- @tparam Note self
  -- @tparam Note other Another Note
  -- @treturn boolean true if equal
  __eq = function(self, other)
    llx.check_arguments{self=Note, other=Note}
    return self.pitch == other.pitch
           and self.time == other.time
           and self.duration == other.duration
           and self.volume == other.volume
  end,

  --- Less-than comparison.
  -- Ordered by time, pitch, duration, then volume.
  -- @function Note:__lt
  -- @tparam Note self
  -- @tparam Note other Another Note
  -- @treturn boolean true if self orders before other
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
  -- @function Note:__le
  -- @tparam Note self
  -- @tparam Note other Another Note
  -- @treturn boolean true if self orders before or equals other
  __le = function(self, other)
    return self == other or self < other
  end,

  --- Formats the note for the tostringf system.
  -- @function Note:__tostringf
  -- @tparam Note self
  -- @tparam StringFormatter formatter The StringFormatter to use
  __tostringf = function(self, formatter)
    formatter:table_cons 'Note' {
      {'pitch', self.pitch},
      {'time', self.time},
      {'duration', self.duration},
      {'volume', self.volume},
    }
  end,

  --- Returns a string representation of the note.
  -- @return String like "Note{pitch=..., time=..., ...}"
  __tostring = function(self)
    return tostringf(self, styles.abbrev)
  end,
}

return _M
