require 'llx'
require 'musictheory/note'

Cell = class 'Cell' {
  __init = function(self)
    self.notes = List{}
  end;
}

-- aka Motif
-- Should this really be distinct from a part?
Figure = class 'Figure' {
  -- __init = function(self, args)
  --   -- duration=0, *, notes=nil, melody=nil
  --   self.duration = duration
  --   if notes then
  --     -- self.notes = [deepcopy(note) for note in notes]
  --   elseif melody then
  --     time = 0
  --     self.notes = List{}
  --     for note in melody do
  --       self.notes:insert(
  --         Note(note.pitch, time, note.duration, note.volume))
  --       time = time + note.duration
  --     end
  --   else
  --     self.notes = list{}
  --   end
  -- end;

  -- addFigure = function(self, figure, start)
  --   start = start or 0
  --   for i, note in ipairs(figure.notes) do
  --     newNote = deepcopy(note)
  --     newNote.time = newNote.time + start
  --     self.notes:insert(newNote)
  -- end;

  -- appendFigure = function(self, figure)
  --   for i, note in ipairs(figure.notes) do
  --     newNote = deepcopy(note)
  --     newNote.time = newNote.time + self.duration
  --     self.notes:insert(newNote)
  --   end
  --   self.duration = self.duration + figure.duration
  -- end;

  -- apply = function(self, transformation)
  --   return Figure{self.duration, notes=map(transformation, self.notes)}
  -- end;

  -- __add = function(self, other)
  --   return merge({self, other})
  -- end;

  -- __mul = function(self, other)
  --   return concatenate({self, other})
  -- end;

  -- __getitem = function(self, key)
  --   return self.notes[key]
  -- end;

  -- __repr = function(self)
  --   return string.format("Figure(duration=%s, notes=%s)", self.duration, repr(self.notes))
  -- end;
}

function merge(figures)
  local result = List{}
  local duration = nil
  for _, figure in ipairs(figures) do
    if duration == nil then
      duration = figure.duration
    elseif duration ~= figure.duration then
      error(ValueError())
    end
    for i, note in ipairs(figure) do
      result.append(deepcopy(note))
    end
  end
  return Figure{duration, notes=result}
end

function concatenate(figures)
  local offset = 0
  local result = List{}
  for _, figure in ipairs(figures) do
    for _, note in ipairs(figure) do
      newNote = deepcopy(note)
      newNote.time = newNote.time +offset
      result.append(newNote)
    end
    offset = offset + figure.duration
  end
  return Figure{duration=offset, notes=result}
end

function repeatfigure(figure, repeatCount, endings)
  if endings then
    local result = Figure{0, notes=List{}}
    for _, ending in ipairs(endings) do
      result = concatenate({result, figure, ending})
    end
    return result
  else
    repeatCount = repeatCount or 2
    return concatenate(List{figure} * repeatCount)
  end
end

function repeatToFill(duration, figure)
  local repeats = int(duration // figure.duration)
  local result = Figure(0)
  for index in range(repeats) do
    result.addFigure(figure, index * figure.duration)
  end
  return result
end