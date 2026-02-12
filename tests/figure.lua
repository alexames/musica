local unit = require 'llx.unit'
local llx = require 'llx'
local figure_module = require 'musica.figure'
local note_module = require 'musica.note'
local pitch_module = require 'musica.pitch'

local Figure = figure_module.Figure
local merge = figure_module.merge
local concatenate = figure_module.concatenate
local repeat_figure = figure_module.repeat_figure
local repeat_volta = figure_module.repeat_volta
local Note = note_module.Note
local Pitch = pitch_module.Pitch
local List = llx.List
local tovalue = llx.tovalue
local main_file = llx.main_file

_G.Figure = Figure
_G.Note = Note
_G.Pitch = Pitch

_ENV = unit.create_test_env(_ENV)

describe('FigureTest', function()
  it('should set notes when constructed with notes', function()
    local notes = List{
      Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
      Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
      Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
    }
    local figure = Figure{duration=4, notes=notes}
    expect(figure.notes).to.be_equal_to(notes)
  end)

  it('should create notes from melody when constructed with melody', function()
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
    expect(figure.notes).to.be_equal_to(expected_notes)
  end)

  it('should merge figures correctly when using add operator', function()
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
    expect(merged_figure.duration).to.be_equal_to(4)
    expect(merged_figure.notes).to.be_equal_to(expected_notes)
  end)

  it('should merge figures correctly when using merge function', function()
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
    merged_figure = merge{figure_1, figure_2, figure_3}
    expect(merged_figure.duration).to.be_equal_to(4)
    expect(merged_figure.notes).to.be_equal_to(expected_notes)
  end)

  it('should concatenate figures correctly when using'
    .. ' concat operator', function()
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
    expect(concatenated_figure.duration).to.be_equal_to(12)
    expect(concatenated_figure.notes).to.be_equal_to(expected_notes)
  end)

  it('should concatenate figures correctly when using'
    .. ' concatenate function', function()
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
    concatenated_figure = concatenate{figure_1, figure_2, figure_3}
    expect(concatenated_figure.duration).to.be_equal_to(12)
    expect(concatenated_figure.notes).to.be_equal_to(expected_notes)
  end)

  it('should repeat figure correctly when using mul operator', function()
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
    expect(repeated_figure.duration).to.be_equal_to(12)
    expect(repeated_figure.notes).to.be_equal_to(expected_notes)
  end)

  it('should repeat figure correctly when using'
    .. ' repeat_figure function', function()
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
    repeated_figure = repeat_figure(figure, 3)
    expect(repeated_figure.duration).to.be_equal_to(12)
    expect(repeated_figure.notes).to.be_equal_to(expected_notes)
  end)

  it('should convert figure to string and back to same figure', function()
    local figure = Figure{
      duration=4,
      notes=List{
        Note{pitch=Pitch.c4, time=0, duration=2, volume=1.0},
        Note{pitch=Pitch.e4, time=1, duration=2, volume=1.0},
        Note{pitch=Pitch.g4, time=2, duration=2, volume=1.0},
      }
    }
    expect(tovalue(tostring(figure))).to.be_equal_to(figure)
  end)

  it('should repeat figure with voltas correctly', function()
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
    expect(repeated_figure.duration).to.be_equal_to(16)
    expect(repeated_figure.notes).to.be_equal_to(expected_notes)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
