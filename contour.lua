require 'llx'
require 'musictheory/direction'
require 'musictheory/note'
require 'musictheory/scale'
require 'musictheory/util'

-- Only lists whether notes are higher, lower, or the same as previous notes
local function directional_contour(melody)
  local contour = List{same}
  for i=2, #melody do
    local previous_note = melody[i-1]
    local next_note = melody[i]
    contour:insert(cmp(next_note.pitch, previous_note.pitch))
  end
  return contour
end

-- Gives series of abitrary indices that represent the relative pitches of the notes
local function relative_contour(melody)
  local pitch_set = Set{}
  for i, note in ipairs(melody) do
    pitch_set:insert(tointeger(note.pitch))
  end
  local pitch_list = pitch_set:tolist()
  pitch_list:sort()
  local index_mapping = {}
  for index, key in ipairs(pitch_list) do
    index_mapping[key] = index
  end
  local contour = List{}
  for i, note in ipairs(melody) do
    contour[i] = index_mapping[tointeger(note.pitch)]
  end
  return contour
end

-- Gives the contour of a melody in pitch indices
local function pitch_index_contour(melody)
  local contour = List{}
  for i, v in ipairs(melody) do
    contour[i] = tointeger(note.pitch)
  end
  return contour
end

-- Gives the contour of a melody in pitch indices
local function scale_index_contour(melody, scale)
  local contour = List{}
  for i, v in ipairs(melody) do
    contour[i] = scale.to_scale_index(note.pitch)
  end
  return contour
end

-- Gives the contour of a melody in pitch indices
local function pitch_class_contour(melody)
  local contour = List{}
  for i, v in ipairs(melody) do
    contour[i] = note.pitch.pitch_class
  end
  return contour
end

return {
  contours = {
    directional_contour=directional_contour,
    relative_contour=relative_contour,
    pitch_index_contour=pitch_index_contour,
    scale_index_contour=scale_index_contour,
    pitch_class_contour=pitch_class_contour,
  },
}