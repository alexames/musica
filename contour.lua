require 'llx'
require 'musictheory/direction'
require 'musictheory/note'
require 'musictheory/scale'
require 'musictheory/util'

-- Only lists whether notes are higher, lower, or the same as previous notes
function directional_contour(melody)
  local contour = List{same}
  for i=2, #melody do
    local previous_note = melody[i-1]
    local next_note = melody[i]
    contour:insert(cmp(next_note.pitch, previous_note.pitch))
  end
  return contour
end

-- Gives series of abitrary indices that represent the relative pitches of the notes
function relative_contour(melody)
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

-- -- Gives the contour of a melody in pitch indices
-- function pitch_index_contour(melody)
--   return [tointeger(note.pitch) for note in melody]
-- end

-- -- Gives the contour of a melody in pitch indices
-- function scale_index_contour(melody, scale)
--   return [scale.to_scale_index(note.pitch) for note in melody]
-- end

-- -- Gives the contour of a melody in pitch indices
-- function chord_contour(melody)
--   pass
-- end

-- -- Gives the contour of a melody in pitch indices
-- function pitch_class_contour(melody)
--   return [note.pitch.pitch_class for note in melody]
-- end
