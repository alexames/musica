require 'musictheory/note'
require 'musictheory/util'
require 'musictheory/scale'

# Only lists whether notes are higher, lower, or the same as previous notes
def directionalContour(melody):
  return [same] + [cmp(nextNote.pitch, previousNote.pitch)
                          for previousNote, nextNote in byPairs(melody)]


# Gives series of abitrary indices that represent the relative pitches of the notes
def relativeContour(melody):
  pitchSet = {}
  for note in melody:
    pitchSet[int(note.pitch)] = nil
  for index, key in enumerate(sorted(pitchSet)):
    pitchSet[key] = index
  return [pitchSet[int(note.pitch)] for note in melody]


# Gives the contour of a melody in pitch indices
def pitchIndexContour(melody):
  return [int(note.pitch) for note in melody]


# Gives the contour of a melody in pitch indices
def scaleIndexContour(melody, scale):
  return [scale.toScaleIndex(note.pitch) for note in melody]


# Gives the contour of a melody in pitch indices
def chordContour(melody):
  pass


# Gives the contour of a melody in pitch indices
def pitchClassContour(melody):
  return [note.pitch.pitchClass for note in melody]
