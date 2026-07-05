-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Figure representation: a reusable phrase of notes.
-- A Figure is a collection of notes with a total duration. Figures
-- can be merged to play together (+), concatenated end to end (..),
-- and repeated (*), via operators or the module functions.
-- @module musica.figure

local llx = require 'llx'
local note = require 'musica.note'
local tostringf_module = require 'llx.tostringf'
local tostringf = tostringf_module.tostringf
local styles = tostringf_module.styles

local _ENV, _M = llx.environment.create_module_environment()

local check_arguments = llx.check_arguments
local class = llx.class
local map = llx.functional.map
local Note = note.Note

--- Schema for Figure construction arguments.
local FigureArgs = llx.Schema{
  __name='FigureArgs',
  type=llx.Table,
  properties={
    duration={type=llx.Number},
    notes={type=llx.Table, items={type=llx.Table}},
    melody={type=llx.Table, items={type=llx.Table}},
  },
}

--- Represents a musical figure (a phrase of notes).
-- @type Figure
Figure = class 'Figure' {
  --- Creates a new Figure.
  -- Notes may be given explicitly with start times, or as a melody
  -- whose notes are laid out one after another.
  -- @function Figure:__init
  -- @tparam Figure self
  -- @tparam table args Construction arguments
  -- @tparam[opt] number args.duration Total duration in beats
  -- @tparam[opt] table args.notes List of Note construction tables
  -- @tparam[opt] table args.melody List of note tables placed
  -- sequentially (each starts when the previous one ends)
  -- @usage
  -- local fig = Figure{duration=2, melody={
  --   {pitch=Pitch.c4, duration=1},
  --   {pitch=Pitch.d4, duration=1},
  -- }}
  __init = function(self, args)
    check_arguments{self=Figure, args=FigureArgs}
    self.duration = args.duration
    local notes = args.notes
    local melody = args.melody
    local new_notes = llx.List{}
    if notes then
      for i, note in ipairs(notes) do
        new_notes[i] = Note(note)
      end
    elseif melody then
      local time = 0
      for i, note in ipairs(melody) do
        new_notes[i] = Note{pitch=note.pitch, time=time,
                            duration=note.duration, volume=note.volume}
        time = time + new_notes[i].duration
      end
    end
    self.notes = new_notes
  end,

  --- Applies a transformation to every note in the figure.
  -- @function Figure:apply
  -- @tparam Figure self
  -- @tparam function transformation Function mapping a Note to a
  -- new Note
  -- @treturn Figure New Figure with the transformed notes
  apply = function(self, transformation)
    return Figure{duration=self.duration, notes=map(transformation, self.notes)}
  end,

  --- Merges two figures so their notes play simultaneously.
  -- Both figures must have the same duration.
  -- @function Figure:__add
  -- @tparam Figure self
  -- @tparam Figure other Another Figure
  -- @treturn Figure New Figure containing both figures' notes
  __add = function(self, other)
    return merge({self, other})
  end,

  --- Repeats the figure the given number of times.
  -- @function Figure:__mul
  -- @tparam Figure self
  -- @tparam number repetitions Number of repetitions
  -- @treturn Figure New Figure with the repetitions in sequence
  __mul = function(self, repetitions)
    return repeat_figure(self, repetitions)
  end,

  --- Concatenates two figures end to end.
  -- @function Figure:__concat
  -- @tparam Figure self
  -- @tparam Figure other The Figure to play after this one
  -- @treturn Figure New Figure with the combined duration
  __concat = function(self, other)
    return concatenate({self, other})
  end,

  --- Checks equality of two figures.
  -- @function Figure:__eq
  -- @tparam Figure self
  -- @tparam Figure other Another Figure
  -- @treturn boolean true if duration and notes are equal
  __eq = function(self, other)
    return self.duration == other.duration and self.notes == other.notes
  end,

  --- Formats the figure for the tostringf system.
  -- @function Figure:__tostringf
  -- @tparam Figure self
  -- @tparam StringFormatter formatter The StringFormatter to use
  __tostringf = function(self, formatter)
    formatter:table_cons 'Figure' {
      {'duration', self.duration},
      {'notes', self.notes, element_style=styles.abbrev},
    }
  end,

  --- Returns a string representation of the figure.
  -- @return String like "Figure{duration=..., notes=...}"
  __tostring = function(self)
    return tostringf(self, styles.abbrev)
  end,
}

--- Merges figures so their notes play simultaneously.
-- All figures must have the same duration.
-- @param figures List of Figures
-- @return Figure containing every note from every figure
function merge(figures)
  local duration = nil
  local result = llx.List{}
  for _, figure in ipairs(figures) do
    if duration == nil then
      duration = figure.duration
    elseif duration ~= figure.duration then
      error('Cannot merge figures with different durations: '
            .. duration .. ' ~= ' .. figure.duration, 2)
    end

    for i, note in ipairs(figure.notes) do
      result:insert(Note(note))
    end
  end
  return Figure{duration=duration, notes=result}
end

--- Concatenates figures end to end.
-- Each figure's notes are offset by the durations of the figures
-- before it.
-- @param figures List of Figures
-- @return Figure whose duration is the sum of the inputs
function concatenate(figures)
  local offset = 0
  local result = llx.List{}
  for i, figure in ipairs(figures) do
    for j, note in ipairs(figure.notes) do
      result:insert(Note{pitch=note.pitch, time=note.time + offset,
                         duration=note.duration, volume=note.volume})
    end
    offset = offset + figure.duration
  end
  return Figure{duration=offset, notes=result}
end

--- Repeats a figure a number of times in sequence.
-- @param figure The Figure to repeat
-- @param repeat_count Number of repetitions (default: 2)
-- @return Figure containing the repetitions
function repeat_figure(figure, repeat_count)
  repeat_count = repeat_count or 2
  return concatenate(llx.List{figure} * repeat_count)
end

--- Repeats a figure with alternate endings (volta repeats).
-- Plays figure, endings[1], figure, endings[2], and so on.
-- @param figure The Figure to repeat
-- @param endings List of ending Figures
-- @return Figure containing the repeated sequence
function repeat_volta(figure, endings)
  local figures = llx.List{}
  for i, ending in ipairs(endings) do
    figures:extend({figure, ending})
  end
  return concatenate(figures)
end

return _M
