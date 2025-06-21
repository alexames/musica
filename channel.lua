-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local figure = require 'musictheory.figure'
local llx = require 'llx'
local note = require 'musictheory.note'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local Figure = figure.Figure
local Note = note.Note

FigureInstance = class 'FigureInstance' {
  __init = function(self, time, figure)
    -- check_arguments{self=FigureInstance, time=Number, figure=Figure}
    self.time = time
    self.figure = figure
  end,

  time_adjusted_notes = function(self)
    return function(instance, i)
      i = i + 1
      local note = instance.figure.notes[i]
      return note and i, note and Note{
        pitch = note.pitch,
        time = note.time + instance.time,
        duration = note.duration,
        volume = note.volume,
      }
    end, self, 0
  end,

  __tostring = function(self)
    return string.format('FigureInstance(%s, %s)', self.time, self.figure)
  end,
}

Channel = class 'Channel' {
  __init = function(self, instrument)
    self.instrument = instrument
    self.figure_instances = llx.List{}
  end,

  __tostring = function(self)
    return string.format('Channel{instrument=%s, figure_instances=%s}',
        self.instrument, self.figure_instances)
  end,
}

return _M
