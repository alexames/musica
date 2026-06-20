-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Contour analysis: extract the shape of an existing melody.
-- These pure functions turn a melody (an array of notes with a `.pitch`) into a
-- numeric/relational sequence describing its movement, ignoring rhythm. They are
-- the substrate the Contour matching/scoring layer builds on. Pitch comparisons
-- use `tointeger(note.pitch)`, so they work whether pitches are Pitch objects or
-- already-coerced MIDI integers.
-- @module musica.contour.analysis

local direction = require 'musica.direction'
local llx = require 'llx'
local pitch_class = require 'musica.pitch_class'

local _ENV, _M = llx.environment.create_module_environment()

local Direction = direction.Direction
local PitchClass = pitch_class.PitchClass
local List = llx.List
local map = llx.functional.map
local tointeger = llx.tointeger

-- Semitone (0-11) -> diatonic letter-class index (1=C .. 7=B). Black keys are
-- spelled as the sharp of the lower natural. Used to recover a pitch class from
-- a melody whose notes carry a coerced MIDI integer rather than a Pitch object.
local SEMITONE_TO_LETTER = {
  [0]=1, [1]=1, [2]=2, [3]=2, [4]=3, [5]=4, [6]=4, [7]=5, [8]=5, [9]=6, [10]=6, [11]=7,
}

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
    contour:insert(cmp(
      tointeger(next_note.pitch),
      tointeger(previous_note.pitch)))
  end
  return contour
end

-- Gives series of arbitrary indices that represent the
-- relative pitches of the notes
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
  return map(function(note) return tointeger(note.pitch) end, List(melody))
end

-- Gives the contour of a melody in scale indices
function scale_index_contour(melody, scale)
  return map(
    function(note) return scale:to_scale_index(note.pitch) end,
    List(melody))
end

-- Gives the contour of a melody in pitch classes. Works on Pitch objects
-- (exact spelling via .pitch_class) and on coerced MIDI integers (best-effort
-- letter via SEMITONE_TO_LETTER).
function pitch_class_contour(melody)
  return map(function(note)
    local p = note.pitch
    if type(p) == 'table' and p.pitch_class then
      return p.pitch_class
    end
    return PitchClass[SEMITONE_TO_LETTER[tointeger(p) % 12]]
  end, List(melody))
end

return _M
