-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local direction = require 'musica.direction'
local llx = require 'llx'
local scale = require 'musica.scale'

local _ENV, _M = llx.environment.create_module_environment()

local Direction = direction.Direction
local List = llx.List
local tointeger = llx.tointeger

--- Compares two pitch integers, returning a Direction constant.
local function cmp(a, b)
  if a > b then return Direction.up
  elseif a < b then return Direction.down
  else return Direction.same
  end
end

-- Only lists whether notes are higher, lower, or the same as previous notes
function directional_contour(melody)
  local contour = List{Direction.same}
  for i=2, #melody do
    local previous_note = melody[i-1]
    local next_note = melody[i]
    contour:insert(cmp(tointeger(next_note.pitch), tointeger(previous_note.pitch)))
  end
  return contour
end

-- Gives series of arbitrary indices that represent the relative pitches of the notes
function relative_contour(melody)
  local pitch_values = {}
  local seen = {}
  for i, note in ipairs(melody) do
    local val = tointeger(note.pitch)
    if not seen[val] then
      seen[val] = true
      pitch_values[#pitch_values + 1] = val
    end
  end
  table.sort(pitch_values)
  local index_mapping = {}
  for index, key in ipairs(pitch_values) do
    index_mapping[key] = index
  end
  local contour = List{}
  for i, note in ipairs(melody) do
    contour[i] = index_mapping[tointeger(note.pitch)]
  end
  return contour
end

-- Gives the contour of a melody in pitch indices
function pitch_index_contour(melody)
  local contour = List{}
  for i, v in ipairs(melody) do
    contour[i] = tointeger(v.pitch)
  end
  return contour
end

-- Gives the contour of a melody in scale indices
function scale_index_contour(melody, scale)
  local contour = List{}
  for i, v in ipairs(melody) do
    contour[i] = scale:to_scale_index(v.pitch)
  end
  return contour
end

-- Gives the contour of a melody in pitch classes
function pitch_class_contour(melody)
  local contour = List{}
  for i, v in ipairs(melody) do
    contour[i] = v.pitch.pitch_class
  end
  return contour
end

return _M
