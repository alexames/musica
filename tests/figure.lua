local unit = require 'unit'
require 'musictheory/figure'
require 'musictheory/note'

test_class 'FigureTest' {
  [test 'init' - 'notes'] = function(self)
    local notes = List{
      Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
      Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
      Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
    }
    local figure = Figure{duration=4, notes=notes}
    EXPECT_EQ(figure.notes, notes)
  end,

  [test 'init' - 'melody'] = function(self)
    local melody = List{
      {pitch=Pitch.c4, duration=1, volume=1.0},
      {pitch=Pitch.e4, duration=2, volume=1.0},
      {pitch=Pitch.g4, duration=1, volume=1.0},
    }
    local figure = Figure{duration=4, melody=melody}

    local expected_notes = List{
      Note{pitch=Pitch.c4, time=0, duration=1, volume=1.0},
      Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
      Note{pitch=Pitch.g4, time=3, duration=1, volume=1.0},
    }
    EXPECT_EQ(figure.notes, expected_notes)
  end,

  [test 'apply'] = function(self)
  end,

  [test 'add / merge'] = function(self)
    local figure_1 = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
      }
    }
    local figure_2 = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c5, time=0, duration=1, volume=1.0},
        Note{pitch=Pitch.e5, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.g5, time=0, duration=3, volume=1.0},
      }
    }
    local figure_3 = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c6, time=2, duration=2, volume=1.0},
        Note{pitch=Pitch.e6, time=2, duration=2, volume=1.0},
        Note{pitch=Pitch.g6, time=2, duration=2, volume=1.0},
      }
    }
    local expected_notes = List{
      Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
      Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
      Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
      Note{pitch=Pitch.c5, time=0, duration=1, volume=1.0},
      Note{pitch=Pitch.e5, time=0, duration=2, volume=1.0},
      Note{pitch=Pitch.g5, time=0, duration=3, volume=1.0},
      Note{pitch=Pitch.c6, time=2, duration=2, volume=1.0},
      Note{pitch=Pitch.e6, time=2, duration=2, volume=1.0},
      Note{pitch=Pitch.g6, time=2, duration=2, volume=1.0},
    }
    local merged_figure = figure_1 + figure_2 + figure_3
    EXPECT_EQ(merged_figure.duration, 4)
    EXPECT_EQ(merged_figure.notes, expected_notes)

    merged_figure = merge{figure_1, figure_2, figure_3}
    EXPECT_EQ(merged_figure.duration, 4)
    EXPECT_EQ(merged_figure.notes, expected_notes)
  end,

  [test 'concat / concatenate'] = function(self)
    local figure_1 = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
      }
    }
    local figure_2 = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c5, time=0, duration=1, volume=1.0},
        Note{pitch=Pitch.e5, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.g5, time=0, duration=3, volume=1.0},
      }
    }
    local figure_3 = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c6, time=2, duration=2, volume=1.0},
        Note{pitch=Pitch.e6, time=2, duration=2, volume=1.0},
        Note{pitch=Pitch.g6, time=2, duration=2, volume=1.0},
      }
    }
    local expected_notes = List{
      Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
      Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
      Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
      Note{pitch=Pitch.c5, time=4, duration=1, volume=1.0},
      Note{pitch=Pitch.e5, time=4, duration=2, volume=1.0},
      Note{pitch=Pitch.g5, time=4, duration=3, volume=1.0},
      Note{pitch=Pitch.c6, time=10, duration=2, volume=1.0},
      Note{pitch=Pitch.e6, time=10, duration=2, volume=1.0},
      Note{pitch=Pitch.g6, time=10, duration=2, volume=1.0},
    }
    local concatenated_figure = figure_1 .. figure_2 .. figure_3
    EXPECT_EQ(concatenated_figure.duration, 12)
    EXPECT_EQ(concatenated_figure.notes, expected_notes)

    concatenated_figure = concatenate{figure_1, figure_2, figure_3}
    EXPECT_EQ(concatenated_figure.duration, 12)
    EXPECT_EQ(concatenated_figure.notes, expected_notes)
  end,

  [test 'mul / repeat'] = function(self)
    local figure = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
      }
    }
    local expected_notes = List{
        Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
        Note{pitch=Pitch.c4, time=4, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=5, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=6, duration=2, volume=1.0},
        Note{pitch=Pitch.c4, time=8, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=9, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=10, duration=2, volume=1.0},
    }
    local repeated_figure = figure * 3
    EXPECT_EQ(repeated_figure.duration, 12)
    EXPECT_EQ(repeated_figure.notes, expected_notes)

    repeated_figure = repeat_figure(figure, 3)
    EXPECT_EQ(repeated_figure.duration, 12)
    EXPECT_EQ(repeated_figure.notes, expected_notes)
  end,

  [test 'tostring'] = function(self)
    local figure = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
      }
    }
    EXPECT_EQ(tovalue(tostring(figure)), figure)
  end,

  [test 'repeat_volta'] = function(self)
    local figure = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
      }
    }
    local volta_1 = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c5, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e5, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g5, time=2, duration=2, volume=1.0},
      }
    }
    local volta_2 = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c6, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e6, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g6, time=2, duration=2, volume=1.0},
      }
    }
    local expected_notes = List{
        Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
        Note{pitch=Pitch.c5, time=4, duration=2, volume=1.0},
        Note{pitch=Pitch.e5, time=5, duration=2, volume=1.0},
        Note{pitch=Pitch.g5, time=6, duration=2, volume=1.0},
        Note{pitch=Pitch.c4, time=8, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=9, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=10, duration=2, volume=1.0},
        Note{pitch=Pitch.c6, time=12, duration=2, volume=1.0},
        Note{pitch=Pitch.e6, time=13, duration=2, volume=1.0},
        Note{pitch=Pitch.g6, time=14, duration=2, volume=1.0},
    }
    local repeated_figure = repeat_volta(figure, {volta_1, volta_2})
    EXPECT_EQ(repeated_figure.duration, 16)
    EXPECT_EQ(repeated_figure.notes, expected_notes)
  end,
}

if main_file() then
  unit.run_unit_tests()
end
