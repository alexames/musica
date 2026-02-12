local unit = require 'llx.unit'
local llx = require 'llx'
local chord_module = require 'musica.chord'
local pitch_module = require 'musica.pitch'
local quality_module = require 'musica.quality'

local Chord = chord_module.Chord
local Pitch = pitch_module.Pitch
local Quality = quality_module.Quality
local List = llx.List
local tovalue = llx.tovalue
local main_file = llx.main_file

_G.Chord = Chord
_G.Pitch = Pitch
_G.Quality = Quality

_ENV = unit.create_test_env(_ENV)

describe('ChordTest', function()
  it('should set root when constructed with root and quality', function()
    local chord = Chord{root=Pitch.c4, quality=Quality.major}
    expect(chord.root).to.be_equal_to(Pitch.c4)
  end)

  it('should set quality when constructed with root and quality', function()
    local chord = Chord{root=Pitch.c4, quality=Quality.major}
    expect(chord.quality).to.be_equal_to(Quality.major)
  end)

  it('should set root from pitches when constructed with pitches', function()
    local chord = Chord{pitches=List{Pitch.c5, Pitch.eflat5, Pitch.g5}}
    expect(chord.root).to.be_equal_to(Pitch.c5)
  end)

  it('should infer quality from pitches when constructed'
    .. ' with pitches', function()
    local chord = Chord{pitches=List{Pitch.c5, Pitch.eflat5, Pitch.g5}}
    expect(chord.quality).to.be_equal_to(Quality.minor)
  end)

  it('should return quality when get_quality is called', function()
    local chord = Chord{root=Pitch.c4, quality=Quality.major}
    expect(chord.quality).to.be_equal_to(Quality.major)
  end)

  it('should return root pitch for index 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:to_pitch(0)).to.be_equal_to(Pitch.c4)
  end)

  it('should return third pitch for index 1', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:to_pitch(1)).to.be_equal_to(Pitch.e4)
  end)

  it('should return fifth pitch for index 2', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:to_pitch(2)).to.be_equal_to(Pitch.g4)
  end)

  it('should throw error when accessing index beyond chord size', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(function() c_major:to_pitch(3) end).to.throw()
  end)

  it('should return root pitch for extended index 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:to_extended_pitch(0)).to.be_equal_to(Pitch.c4)
  end)

  it('should return third pitch for extended index 1', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:to_extended_pitch(1)).to.be_equal_to(Pitch.e4)
  end)

  it('should return fifth pitch for extended index 2', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:to_extended_pitch(2)).to.be_equal_to(Pitch.g4)
  end)

  it('should return root for inversion 0 at index 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv0 = c_major:inversion(0)
    expect(c_major_inv0:to_pitch(0)).to.be_equal_to(Pitch.c4)
  end)

  it('should return third for inversion 0 at index 1', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv0 = c_major:inversion(0)
    expect(c_major_inv0:to_pitch(1)).to.be_equal_to(Pitch.e4)
  end)

  it('should return fifth for inversion 0 at index 2', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv0 = c_major:inversion(0)
    expect(c_major_inv0:to_pitch(2)).to.be_equal_to(Pitch.g4)
  end)

  it('should return third for inversion 1 at index 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv1 = c_major:inversion(1)
    expect(c_major_inv1:to_pitch(0)).to.be_equal_to(Pitch.e4)
  end)

  it('should return fifth for inversion 1 at index 1', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv1 = c_major:inversion(1)
    expect(c_major_inv1:to_pitch(1)).to.be_equal_to(Pitch.g4)
  end)

  it('should return root octave up for inversion 1 at index 2', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv1 = c_major:inversion(1)
    expect(c_major_inv1:to_pitch(2)).to.be_equal_to(Pitch.c5)
  end)

  it('should return fifth for inversion 2 at index 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv2 = c_major:inversion(2)
    expect(c_major_inv2:to_pitch(0)).to.be_equal_to(Pitch.g4)
  end)

  it('should return root octave up for inversion 2 at index 1', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv2 = c_major:inversion(2)
    expect(c_major_inv2:to_pitch(1)).to.be_equal_to(Pitch.c5)
  end)

  it('should return third octave up for inversion 2 at index 2', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv2 = c_major:inversion(2)
    expect(c_major_inv2:to_pitch(2)).to.be_equal_to(Pitch.e5)
  end)

  it('should return root octave up for inversion 3 at index 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv3 = c_major:inversion(3)
    expect(c_major_inv3:to_pitch(0)).to.be_equal_to(Pitch.c5)
  end)

  it('should return third octave up for inversion 3 at index 1', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv3 = c_major:inversion(3)
    expect(c_major_inv3:to_pitch(1)).to.be_equal_to(Pitch.e5)
  end)

  it('should return fifth octave up for inversion 3 at index 2', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv3 = c_major:inversion(3)
    expect(c_major_inv3:to_pitch(2)).to.be_equal_to(Pitch.g5)
  end)

  it('should return third octave up for inversion 4 at index 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv4 = c_major:inversion(4)
    expect(c_major_inv4:to_pitch(0)).to.be_equal_to(Pitch.e5)
  end)

  it('should return fifth octave up for inversion 4 at index 1', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv4 = c_major:inversion(4)
    expect(c_major_inv4:to_pitch(1)).to.be_equal_to(Pitch.g5)
  end)

  it('should return root two octaves up for inversion 4 at index 2', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv4 = c_major:inversion(4)
    expect(c_major_inv4:to_pitch(2)).to.be_equal_to(Pitch.c6)
  end)

  it('should return fifth octave down for negative'
    .. ' inversion -1 at index 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv0 = c_major:inversion(-1)
    expect(c_major_inv0:to_pitch(0)).to.be_equal_to(Pitch.g3)
  end)

  it('should return root for negative inversion -1 at index 1', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv0 = c_major:inversion(-1)
    expect(c_major_inv0:to_pitch(1)).to.be_equal_to(Pitch.c4)
  end)

  it('should return third for negative inversion -1 at index 2', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_major_inv0 = c_major:inversion(-1)
    expect(c_major_inv0:to_pitch(2)).to.be_equal_to(Pitch.e4)
  end)

  it('should add bass note above when using over operator', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_maj7 = c_major / Pitch.b5
    expect(c_maj7[{0, 1, 2, 3}]).to.be_equal_to(
      List{Pitch.c4, Pitch.e4, Pitch.g4, Pitch.b5})
  end)

  it('should add bass note below when using over operator', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local c_maj_over_b = c_major / Pitch.b2
    expect(c_maj_over_b[{0, 1, 2, 3}]).to.be_equal_to(
      List{Pitch.b2, Pitch.c4, Pitch.e4, Pitch.g4})
  end)

  it('should return length of 3 for major chord', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(#c_major).to.be_equal_to(3)
  end)

  it('should return root for index 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major[0]).to.be_equal_to(Pitch.c4)
  end)

  it('should return third for index 1', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major[1]).to.be_equal_to(Pitch.e4)
  end)

  it('should return fifth for index 2', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major[2]).to.be_equal_to(Pitch.g4)
  end)

  it('should return list of pitches for list index', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major[{0, 1, 2}]).to.be_equal_to({Pitch.c4, Pitch.e4, Pitch.g4})
  end)

  it('should return true when chord contains root', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:contains(Pitch.c4)).to.be_truthy()
  end)

  it('should return true when chord contains third', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:contains(Pitch.e4)).to.be_truthy()
  end)

  it('should return true when chord contains fifth', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:contains(Pitch.g4)).to.be_truthy()
  end)

  it('should return false when chord does not contain pitch', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:contains(Pitch.d4)).to.be_falsy()
  end)

  it('should return false when chord does not contain another pitch', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:contains(Pitch.f4)).to.be_falsy()
  end)

  it('should return false when chord does not contain'
    .. ' pitch in different octave', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(c_major:contains(Pitch.c5)).to.be_falsy()
  end)

  it('should convert chord to string and back to same chord', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    expect(tovalue(tostring(c_major))).to.be_equal_to(c_major)
  end)

  it('should return a new chord for inversion 0', function()
    local c_major = Chord{root=Pitch.c4, quality=Quality.major}
    local inv0 = c_major:inversion(0)
    expect(inv0).to.be_equal_to(c_major)
    expect(rawequal(inv0, c_major)).to.be_falsy()
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
