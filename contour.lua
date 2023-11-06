require 'llx'
require 'musictheory/note'
require 'musictheory/util'
require 'musictheory/scale'

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
-- function pitchIndex_contour(melody)
--   return [tointeger(note.pitch) for note in melody]
-- end

-- -- Gives the contour of a melody in pitch indices
-- function scaleIndex_contour(melody, scale)
--   return [scale.toScaleIndex(note.pitch) for note in melody]
-- end

-- -- Gives the contour of a melody in pitch indices
-- function chord_contour(melody)
--   pass
-- end

-- -- Gives the contour of a melody in pitch indices
-- function pitchClass_contour(melody)
--   return [note.pitch.pitchClass for note in melody]
-- end
