-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'
local note = require 'musica.note'
local tostringf_module = require 'llx.tostringf'
local tostringf = tostringf_module.tostringf
local styles = tostringf_module.styles

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local map = llx.functional.map
local Note = note.Note

local FigureArgs = llx.Schema{
  __name='FigureArgs',
  type=llx.Table,
  properties={
    duration={type=llx.Number},
    notes={type=llx.List, items={type=llx.Table}},
    melody={type=llx.List, items={type=llx.Table}},
  },
}

Figure = class 'Figure' {
  __init = function(self, args)
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

  apply = function(self, transformation)
    return Figure{duration=self.duration, notes=map(transformation, self.notes)}
  end,

  __add = function(self, other)
    return merge({self, other})
  end,

  __mul = function(self, repetitions)
    return repeat_figure(self, repetitions)
  end,

  __concat = function(self, other)
    return concatenate({self, other})
  end,

  __eq = function(self, other)
    return self.duration == other.duration and self.notes == other.notes
  end,

  __tostringf = function(self, formatter)
    formatter:table_cons 'Figure' {
      {'duration', self.duration},
      {'notes', self.notes, element_style=styles.abbrev},
    }
  end,

  __tostring = function(self)
    return tostringf(self, styles.abbrev)
  end,
}

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

function repeat_figure(figure, repeat_count)
  repeat_count = repeat_count or 2
  return concatenate(llx.List{figure} * repeat_count)
end

function repeat_volta(figure, endings)
  local figures = llx.List{}
  for i, ending in ipairs(endings) do
    figures:extend({figure, ending})
  end
  return concatenate(figures)
end

return _M
