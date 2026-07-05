-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Channel and figure placement for songs.
-- A Channel pairs an instrument with a list of FigureInstances,
-- each of which places a Figure at a point in time.
-- @module musica.channel

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

--- A Figure placed at a specific time.
-- @type FigureInstance
FigureInstance = class 'FigureInstance' {
  --- Creates a new FigureInstance.
  -- @function FigureInstance:__init
  -- @tparam FigureInstance self
  -- @tparam number time Start time in beats
  -- @tparam Figure figure The Figure to place at that time
  __init = function(self, time, figure)
    self.time = time
    self.figure = figure
  end,

  --- Iterates the figure's notes offset by the instance's time.
  -- @return Iterator yielding index, Note pairs whose times are
  -- shifted by the instance's start time
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

  --- Checks equality of two figure instances.
  -- @function FigureInstance:__eq
  -- @tparam FigureInstance self
  -- @tparam FigureInstance other Another FigureInstance
  -- @treturn boolean true if time and figure are equal
  __eq = function(self, other)
    return self.time == other.time and self.figure == other.figure
  end,

  --- Formats the figure instance for the tostringf system.
  -- @function FigureInstance:__tostringf
  -- @tparam FigureInstance self
  -- @tparam StringFormatter formatter The StringFormatter to use
  __tostringf = function(self, formatter)
    formatter:table_cons 'FigureInstance' {
      {'time', self.time},
      {'figure', self.figure},
    }
  end,

  --- Returns a string representation of the figure instance.
  -- @return String like "FigureInstance(0, Figure{...})"
  __tostring = function(self)
    return string.format('FigureInstance(%s, %s)', self.time, self.figure)
  end,
}

--- A single part in a song.
-- A Channel holds an instrument, the figure instances it plays, and
-- optional sheet music metadata (part name, clef, transposition).
-- @type Channel
Channel = class 'Channel' {
  --- Creates a new Channel.
  -- @function Channel:__init
  -- @tparam Channel self
  -- @tparam Instrument instrument The instrument for this channel
  -- @tparam[opt] table args Optional sheet music metadata
  -- @tparam[opt] string args.part_name Full part name
  -- (e.g., 'Flute I')
  -- @tparam[opt] string args.short_name Abbreviated part name
  -- @tparam[opt] string args.clef Clef name ('treble', 'bass',
  -- 'alto', 'tenor')
  -- @tparam[opt] PitchInterval args.transposition Transposition for
  -- transposing instruments
  __init = function(self, instrument, args)
    self.instrument = instrument
    self.figure_instances = llx.List{}
    -- Metadata for sheet music
    args = args or {}
    self.part_name = args.part_name or nil
    self.short_name = args.short_name or nil
    self.clef = args.clef or nil  -- e.g., 'treble', 'bass', 'alto', 'tenor'
    -- For transposing instruments
    self.transposition = args.transposition or nil
  end,

  --- Checks equality of two channels.
  -- @function Channel:__eq
  -- @tparam Channel self
  -- @tparam Channel other Another Channel
  -- @treturn boolean true if instrument, figures, and metadata match
  __eq = function(self, other)
    return self.instrument == other.instrument
           and self.figure_instances == other.figure_instances
           and self.part_name == other.part_name
           and self.short_name == other.short_name
           and self.clef == other.clef
           and self.transposition == other.transposition
  end,

  --- Formats the channel for the tostringf system.
  -- @function Channel:__tostringf
  -- @tparam Channel self
  -- @tparam StringFormatter formatter The StringFormatter to use
  __tostringf = function(self, formatter)
    formatter:table_cons 'Channel' {
      {'instrument', self.instrument},
      {'figure_instances', self.figure_instances},
    }
  end,

  --- Returns a string representation of the channel.
  -- @return String like "Channel{instrument=..., ...}"
  __tostring = function(self)
    return tostringf(self, styles.abbrev)
  end,
}

return _M
