-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local figure = require 'musica.figure'
local llx = require 'llx'
local note = require 'musica.note'
local tostringf_module = require 'llx.tostringf'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local Figure = figure.Figure
local Note = note.Note
local tostringf = tostringf_module.tostringf
local styles = tostringf_module.styles

FigureInstance = class 'FigureInstance' {
  __init = function(self, args)
    -- check_arguments{self=FigureInstance, time=Number, figure=Figure}

    self.time = args and args.time or 0
    self.figure = args and args.figure
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

  __tostringf = function(self, formatter)
    formatter:table_cons 'FigureInstance' {
      {'time', self.time},
      {'figure', self.figure},
    }
  end,

  __tostring = function(self)
    return tostringf(self, styles.abbrev)
  end,
}

Channel = class 'Channel' {
  __init = function(self, args)
    self.instrument = args.instrument
    self.figure_instances = args.figure_instances or llx.List{}
  end,

  __tostringf = function(self, formatter)
    formatter:table_cons 'Channel' {
      {'instrument', self.instrument},
      {'figure_instances', self.figure_instances},
    }
  end,

  __tostring = function(self)
    return tostringf(self, styles.abbrev)
  end,
}

return _M
