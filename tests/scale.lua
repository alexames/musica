local unit = require 'unit'
require 'llx'
require 'musica.direction'
require 'musica.mode'
require 'musica.pitch'
require 'musica.scale'

_ENV = unit.create_test_env(_ENV)

describe('ScaleTest', function()
  it('should return correct pitches for major scale', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:get_pitches()).to.be_equal_to(
      List{Pitch.c4,
           Pitch.d4,
           Pitch.e4,
           Pitch.f4,
           Pitch.g4,
           Pitch.a5,
           Pitch.b5})
  end)

  it('should return b3 for index -8', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(-8)).to.be_equal_to(Pitch.b3)
  end)

  it('should return c3 for index -7', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(-7)).to.be_equal_to(Pitch.c3)
  end)

  it('should return d3 for index -6', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(-6)).to.be_equal_to(Pitch.d3)
  end)

  it('should return e3 for index -5', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(-5)).to.be_equal_to(Pitch.e3)
  end)

  it('should return f3 for index -4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(-4)).to.be_equal_to(Pitch.f3)
  end)

  it('should return g3 for index -3', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(-3)).to.be_equal_to(Pitch.g3)
  end)

  it('should return a4 for index -2', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(-2)).to.be_equal_to(Pitch.a4)
  end)

  it('should return b4 for index -1', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(-1)).to.be_equal_to(Pitch.b4)
  end)

  it('should return c4 for index 0', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(0)).to.be_equal_to(Pitch.c4)
  end)

  it('should return d4 for index 1', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(1)).to.be_equal_to(Pitch.d4)
  end)

  it('should return e4 for index 2', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(2)).to.be_equal_to(Pitch.e4)
  end)

  it('should return f4 for index 3', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(3)).to.be_equal_to(Pitch.f4)
  end)

  it('should return g4 for index 4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(4)).to.be_equal_to(Pitch.g4)
  end)

  it('should return a5 for index 5', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(5)).to.be_equal_to(Pitch.a5)
  end)

  it('should return b5 for index 6', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(6)).to.be_equal_to(Pitch.b5)
  end)

  it('should return c5 for index 7', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(7)).to.be_equal_to(Pitch.c5)
  end)

  it('should return d5 for index 8', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitch(8)).to.be_equal_to(Pitch.d5)
  end)

  it('should return correct pitches for multiple indices', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_pitches({-8, -7, -5, -3, -1, 0, 1, 3, 5, 7, 8})).to.be_equal_to(
      List{Pitch.b3,
           Pitch.c3,
           Pitch.e3,
           Pitch.g3,
           Pitch.b4,
           Pitch.c4,
           Pitch.d4,
           Pitch.f4,
           Pitch.a5,
           Pitch.c5,
           Pitch.d5})
  end)

  it('should return -2 for scale index of a4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_scale_index(Pitch.a4)).to.be_equal_to(-2)
  end)

  it('should return 0 for scale index of c4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_scale_index(Pitch.c4)).to.be_equal_to(0)
  end)

  it('should return 2 for scale index of e4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:to_scale_index(Pitch.e4)).to.be_equal_to(2)
  end)

  it('should return relative minor scale going up', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:relative{mode=Mode.minor}).to.be_equal_to(
      Scale{tonic=Pitch.a5, mode=Mode.minor})
  end)

  it('should return relative minor scale going down', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:relative{mode=Mode.minor, direction=Direction.down}).to.be_equal_to(
      Scale{tonic=Pitch.a4, mode=Mode.minor})
  end)

  it('should return parallel minor scale', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:parallel(Mode.minor)).to.be_equal_to(
      Scale{tonic=Pitch.c4, mode=Mode.minor})
  end)

  it('should return length of 7 for major scale', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(#scale).to.be_equal_to(7)
  end)

  it('should return b3 for index -8', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[-8]).to.be_equal_to(Pitch.b3)
  end)

  it('should return c3 for index -7', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[-7]).to.be_equal_to(Pitch.c3)
  end)

  it('should return d3 for index -6', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[-6]).to.be_equal_to(Pitch.d3)
  end)

  it('should return e3 for index -5', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[-5]).to.be_equal_to(Pitch.e3)
  end)

  it('should return f3 for index -4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[-4]).to.be_equal_to(Pitch.f3)
  end)

  it('should return g3 for index -3', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[-3]).to.be_equal_to(Pitch.g3)
  end)

  it('should return a4 for index -2', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[-2]).to.be_equal_to(Pitch.a4)
  end)

  it('should return b4 for index -1', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[-1]).to.be_equal_to(Pitch.b4)
  end)

  it('should return c4 for index 0', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[0]).to.be_equal_to(Pitch.c4)
  end)

  it('should return d4 for index 1', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[1]).to.be_equal_to(Pitch.d4)
  end)

  it('should return e4 for index 2', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[2]).to.be_equal_to(Pitch.e4)
  end)

  it('should return f4 for index 3', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[3]).to.be_equal_to(Pitch.f4)
  end)

  it('should return g4 for index 4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[4]).to.be_equal_to(Pitch.g4)
  end)

  it('should return a5 for index 5', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[5]).to.be_equal_to(Pitch.a5)
  end)

  it('should return b5 for index 6', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[6]).to.be_equal_to(Pitch.b5)
  end)

  it('should return c5 for index 7', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[7]).to.be_equal_to(Pitch.c5)
  end)

  it('should return d5 for index 8', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[8]).to.be_equal_to(Pitch.d5)
  end)

  it('should return list of pitches for list index', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[{-3, -2, -1, 0, 1, 2}]).to.be_equal_to(
      List{Pitch.g3, Pitch.a4, Pitch.b4, Pitch.c4, Pitch.d4, Pitch.e4})
  end)

  it('should return list of pitches for another list index', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale[{-3, 0, 3}]).to.be_equal_to(
      List{Pitch.g3, Pitch.c4, Pitch.f4})
  end)

  it('should return true when scale contains c4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:contains(Pitch.c4)).to.be_truthy()
  end)

  it('should return true when scale contains d4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:contains(Pitch.d4)).to.be_truthy()
  end)

  it('should return true when scale contains c5', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:contains(Pitch.c5)).to.be_truthy()
  end)

  it('should return true when scale contains a0', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:contains(Pitch.a0)).to.be_truthy()
  end)

  it('should return true when scale contains all pitches in list', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:contains({Pitch.a0, Pitch.b1, Pitch.c2, Pitch.d3})).to.be_truthy()
  end)

  it('should return false when scale does not contain csharp4', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:contains(Pitch.csharp4)).to.be_falsy()
  end)

  it('should return false when scale does not contain all pitches in list', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(scale:contains({Pitch.asharp0, Pitch.b1, Pitch.c2, Pitch.d3})).to.be_falsy()
  end)

  it('should convert scale to string and back to same scale', function()
    local scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(tovalue(tostring(scale))).to.be_equal_to(scale)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
