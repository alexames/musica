local unit = require 'llx.unit'
local llx = require 'llx'
local contour_module = require 'musica.contour'
local direction_module = require 'musica.direction'
local note_module = require 'musica.note'
local mode_module = require 'musica.mode'
require 'musica.modes'
local pitch_module = require 'musica.pitch'
local pitch_class_module = require 'musica.pitch_class'
local scale_module = require 'musica.scale'

local directional_contour = contour_module.directional_contour
local relative_contour = contour_module.relative_contour
local pitch_index_contour = contour_module.pitch_index_contour
local scale_index_contour = contour_module.scale_index_contour
local pitch_class_contour = contour_module.pitch_class_contour
local Direction = direction_module.Direction
local same = Direction.same
local up = Direction.up
local down = Direction.down
local Note = note_module.Note
local Pitch = pitch_module.Pitch
local PitchClass = pitch_class_module.PitchClass
local C = PitchClass.C
local D = PitchClass.D
local E = PitchClass.E
local G = PitchClass.G
local Mode = mode_module.Mode
local Scale = scale_module.Scale
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

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

describe('ContourTest', function()
  it('should generate directional contour correctly', function()
    contour = directional_contour(mary)
    expect(contour).to.be_equal_to(
      {same, down, down,   up,
         up, same, same,
       down, same, same,
         up,   up, same,
       down, down, down,   up,
         up, same, same, same,
       down, same,   up, down,
       down})
  end)

  it('should generate relative contour correctly', function()
    contour = relative_contour(mary)
    expect(contour).to.be_equal_to(
      {3, 2, 1, 2,
       3, 3, 3,
       2, 2, 2,
       3, 4, 4,
       3, 2, 1, 2,
       3, 3, 3, 3,
       2, 2, 3, 2,
       1})
  end)

  it('should generate pitch index contour correctly', function()
    contour = pitch_index_contour(mary)
    expect(contour).to.be_equal_to(
      {76, 74, 72, 74,
       76, 76, 76,
       74, 74, 74,
       76, 79, 79,
       76, 74, 72, 74,
       76, 76, 76, 76,
       74, 74, 76, 74,
       72})
  end)

  it('should generate scale index contour correctly', function()
    contour = scale_index_contour(mary,
                                  Scale{tonic=Pitch.c4, mode=Mode.major})
    expect(contour).to.be_equal_to(
      {2, 1, 0, 1,
       2, 2, 2,
       1, 1, 1,
       2, 4, 4,
       2, 1, 0, 1,
       2, 2, 2, 2,
       1, 1, 2, 1,
       0})
  end)

  it('should generate pitch class contour correctly', function()
    contour = pitch_class_contour(mary)
    expect(contour).to.be_equal_to(
      {E, D, C, D,
       E, E, E,
       D, D, D,
       E, G, G,
       E, D, C, D,
       E, E, E, E,
       D, D, E, D,
       C})
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
