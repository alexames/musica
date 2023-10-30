require 'unit'
require 'musictheory/contour'

-- Mary had a little lamb
local mary = [
  Note(pitch=Pitch.e4, duration=1),
  Note(pitch=Pitch.d4, duration=1),
  Note(pitch=Pitch.c4, duration=1),
  Note(pitch=Pitch.d4, duration=1),

  Note(pitch=Pitch.e4, duration=1),
  Note(pitch=Pitch.e4, duration=1),
  Note(pitch=Pitch.e4, duration=2),

  Note(pitch=Pitch.d4, duration=1),
  Note(pitch=Pitch.d4, duration=1),
  Note(pitch=Pitch.d4, duration=2),

  Note(pitch=Pitch.e4, duration=1),
  Note(pitch=Pitch.g4, duration=1),
  Note(pitch=Pitch.g4, duration=2),

  Note(pitch=Pitch.e4, duration=1),
  Note(pitch=Pitch.d4, duration=1),
  Note(pitch=Pitch.c4, duration=1),
  Note(pitch=Pitch.d4, duration=1),

  Note(pitch=Pitch.e4, duration=1),
  Note(pitch=Pitch.e4, duration=1),
  Note(pitch=Pitch.e4, duration=1),
  Note(pitch=Pitch.e4, duration=1),

  Note(pitch=Pitch.d4, duration=1),
  Note(pitch=Pitch.d4, duration=1),
  Note(pitch=Pitch.e4, duration=1),
  Note(pitch=Pitch.d4, duration=1),

  Note(pitch=Pitch.c4, duration=4),
]

test_class 'ChordTest' {
  [test 'directionalContour'] = function(self)
    contour = directionalContour(melody=mary)
    EXPECT_EQ(contour,
              [same, down, down,   up,
                 up, same, same,
               down, same, same,
                 up,   up, same,
               down, down, down,   up,
                 up, same, same, same,
               down, same,   up, down,
               down])
  end;

  [test 'relativeContour'] = function(self)
    contour = relativeContour(melody=mary)
    EXPECT_EQ(contour,
              [2, 1, 0, 1,
               2, 2, 2,
               1, 1, 1,
               2, 3, 3,
               2, 1, 0, 1,
               2, 2, 2, 2,
               1, 1, 2, 1,
               0])
  end;

  [test 'pitchIndexContour'] = function(self)
    contour = pitchIndexContour(melody=mary)
    EXPECT_EQ(contour,
              [76, 74, 72, 74,
               76, 76, 76,
               74, 74, 74,
               76, 79, 79,
               76, 74, 72, 74,
               76, 76, 76, 76,
               74, 74, 76, 74,
               72])
  end;

  [test 'scaleIndexContour'] = function(self)
    contour = scaleIndexContour(melody=mary,
                                scale=Scale(tonic=Pitch.c4, mode=Mode.major))
    EXPECT_EQ(contour,
              [2, 1, 0, 1,
               2, 2, 2,
               1, 1, 1,
               2, 4, 4,
               2, 1, 0, 1,
               2, 2, 2, 2,
               1, 1, 2, 1,
               0])
  end;

  [test 'pitchClassContour'] = function(self)
    contour = pitchClassContour(melody=mary)
    EXPECT_EQ(contour,
              [E, D, C, D,
               E, E, E,
               D, D, D,
               E, G, G,
               E, D, C, D,
               E, E, E, E,
               D, D, E, D,
               C])
  end;
}