require 'unit'
require 'llx'
require 'musica.contour'
require 'musica.direction'
require 'musica.note'
require 'musica.mode'
require 'musica.modes'

-- Mary had a little lamb
local mary = {
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.c4, duration=1},
  Note{pitch=Pitch.d4, duration=1},

  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=2},

  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.d4, duration=2},

  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.g4, duration=1},
  Note{pitch=Pitch.g4, duration=2},

  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.c4, duration=1},
  Note{pitch=Pitch.d4, duration=1},

  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.e4, duration=1},

  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.d4, duration=1},
  Note{pitch=Pitch.e4, duration=1},
  Note{pitch=Pitch.d4, duration=1},

  Note{pitch=Pitch.c4, duration=4},
}

test_class 'ContourTest' {
  [test 'directional_contour'] = function(self)
    contour = directional_contour(mary)
    EXPECT_EQ(contour,
              {same, down, down,   up,
                 up, same, same,
               down, same, same,
                 up,   up, same,
               down, down, down,   up,
                 up, same, same, same,
               down, same,   up, down,
               down})
  end;

  [test 'relative_contour'] = function(self)
    contour = relative_contour(mary)
    EXPECT_EQ(contour,
              {2, 1, 0, 1,
               2, 2, 2,
               1, 1, 1,
               2, 3, 3,
               2, 1, 0, 1,
               2, 2, 2, 2,
               1, 1, 2, 1,
               0})
  end;

  [test 'pitch_index_contour'] = function(self)
    contour = pitch_index_contour(mary)
    EXPECT_EQ(contour,
              {76, 74, 72, 74,
               76, 76, 76,
               74, 74, 74,
               76, 79, 79,
               76, 74, 72, 74,
               76, 76, 76, 76,
               74, 74, 76, 74,
               72})
  end;

  [test 'scale_index_contour'] = function(self)
    contour = scale_index_contour(mary,
                                  Scale{tonic=Pitch.c4, mode=Mode.major})
    EXPECT_EQ(contour,
              {2, 1, 0, 1,
               2, 2, 2,
               1, 1, 1,
               2, 4, 4,
               2, 1, 0, 1,
               2, 2, 2, 2,
               1, 1, 2, 1,
               0})
  end;

  [test 'pitch_class_contour'] = function(self)
    contour = pitch_class_contour(mary)
    EXPECT_EQ(contour,
              {E, D, C, D,
               E, E, E,
               D, D, D,
               E, G, G,
               E, D, C, D,
               E, E, E, E,
               D, D, E, D,
               C})
  end;
}

if main_file() then
  unit.run_unit_tests()
end
