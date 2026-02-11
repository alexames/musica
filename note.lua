-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'
local pitch = require 'musica.pitch'
local tostringf_module = require 'llx.tostringf'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local Pitch = pitch.Pitch
local tostringf = tostringf_module.tostringf
local styles = tostringf_module.styles

local NoteArgs = llx.Schema{
  __name='NoteArgs',
  type=llx.Table,
  properties={
    -- pitch={type=llx.Union{Pitch,llx.Integer}},
    time={type=llx.Number},
    duration={type=llx.Number},
    volume={type=llx.Number},
  },
}

--- A note, with a pitch, time, duration and volume
Note = class 'Note' {
  --- Initializes a Note.
  __init = function(self, arg)
    self.pitch = arg.pitch
    self.time = arg.time
    self.duration = arg.duration
    self.volume = arg.volume or 1.0
  end,

  --- Returns a new Note whose duration ends at the given finish time.
  -- @tparam Note self
  -- @tparam number finish The desired finish time
  -- @treturn Note A new Note with adjusted duration
  with_finish = function(self, finish)
    return Note{pitch=self.pitch, time=self.time,
                duration=finish - self.time, volume=self.volume}
  end,

  --- Mutates the duration so that the note finishes at the given time.
  -- Prefer with_finish for new code; this mutates in place.
  set_finish = function(self, finish)
    self.duration = finish - self.time
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
  -- Ordered by time first, then by pitch (MIDI number).
  __lt = function(self, other)
    if self.time ~= other.time then
      return self.time < other.time
    end
    return self.pitch < other.pitch
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
