local unit = require 'llx.unit'
require 'llx'
require 'musica.pitch'
require 'musica.pitch_interval'
require 'musica.quality'

_ENV = unit.create_test_env(_ENV)

describe('PitchIntervalTest', function()
  it('should create major third when constructed with number and quality', function()
    expect(PitchInterval{number=2, quality=Quality.major}).to.be_equal_to(
      PitchInterval.major_third)
  end)

  it('should create major third when constructed with number and semitone interval', function()
    expect(PitchInterval{number=2, semitone_interval=4}).to.be_equal_to(
      PitchInterval.major_third)
  end)

  it('should create major third when constructed with number and accidentals 0', function()
    expect(PitchInterval{number=2, accidentals=0}).to.be_equal_to(
      PitchInterval.major_third)
  end)

  it('should create major third when constructed with number and natural accidental', function()
    expect(PitchInterval{number=2, accidentals=Accidental.natural}).to.be_equal_to(
      PitchInterval.major_third)
  end)

  it('should return true when unison is perfect', function()
    expect(PitchInterval.unison:is_perfect()).to.be_truthy()
  end)

  it('should return false when major second is not perfect', function()
    expect(PitchInterval.major_second:is_perfect()).to.be_falsy()
  end)

  it('should return false when major third is not perfect', function()
    expect(PitchInterval.major_third:is_perfect()).to.be_falsy()
  end)

  it('should return true when perfect fourth is perfect', function()
    expect(PitchInterval.perfect_fourth:is_perfect()).to.be_truthy()
  end)

  it('should return true when perfect fifth is perfect', function()
    expect(PitchInterval.perfect_fifth:is_perfect()).to.be_truthy()
  end)

  it('should return false when major sixth is not perfect', function()
    expect(PitchInterval.major_sixth:is_perfect()).to.be_falsy()
  end)

  it('should return false when major seventh is not perfect', function()
    expect(PitchInterval.major_seventh:is_perfect()).to.be_falsy()
  end)

  it('should return true when octave is perfect', function()
    expect(PitchInterval.octave:is_perfect()).to.be_truthy()
  end)

  it('should return false when interval with number 8 is not perfect', function()
    expect(PitchInterval{number=8}:is_perfect()).to.be_falsy()
  end)

  it('should return false when interval with number 9 is not perfect', function()
    expect(PitchInterval{number=9}:is_perfect()).to.be_falsy()
  end)

  it('should return true when interval with number 10 is perfect', function()
    expect(PitchInterval{number=10}:is_perfect()).to.be_truthy()
  end)

  it('should return true when interval with number 11 is perfect', function()
    expect(PitchInterval{number=11}:is_perfect()).to.be_truthy()
  end)

  it('should return false when interval with number 12 is not perfect', function()
    expect(PitchInterval{number=12}:is_perfect()).to.be_falsy()
  end)

  it('should return false when interval with number 13 is not perfect', function()
    expect(PitchInterval{number=13}:is_perfect()).to.be_falsy()
  end)

  it('should return true when augmented second is enharmonic to itself', function()
    expect(PitchInterval.augmented_second:is_enharmonic(
      PitchInterval.augmented_second)).to.be_truthy()
  end)

  it('should return true when augmented second is enharmonic to minor third', function()
    expect(PitchInterval.augmented_second:is_enharmonic(
      PitchInterval.minor_third)).to.be_truthy()
  end)

  it('should return false when minor third is not enharmonic to major third', function()
    expect(PitchInterval.minor_third:is_enharmonic(
      PitchInterval.major_third)).to.be_falsy()
  end)

  it('should add major third and minor third to get perfect fifth', function()
    expect(PitchInterval.major_third + PitchInterval.minor_third).to.be_equal_to(
      PitchInterval.perfect_fifth)
  end)

  it('should add minor third and major third to get perfect fifth', function()
    expect(PitchInterval.minor_third + PitchInterval.major_third).to.be_equal_to(
      PitchInterval.perfect_fifth)
  end)

  it('should add major third and major third to get augmented fifth', function()
    expect(PitchInterval.major_third + PitchInterval.major_third).to.be_equal_to(
      PitchInterval.augmented_fifth)
  end)

  it('should add major second and octave to get compound interval', function()
    expect(PitchInterval.major_second + PitchInterval.octave).to.be_equal_to(
      PitchInterval{number=8})
  end)

  it('should add pitch and major third interval correctly', function()
    expect(Pitch.c4 + PitchInterval.major_third).to.be_equal_to(Pitch.e4)
  end)

  it('should add major third interval and pitch correctly', function()
    expect(PitchInterval.major_third + Pitch.c4).to.be_equal_to(Pitch.e4)
  end)

  it('should add pitch and minor third interval correctly', function()
    expect(Pitch.c4 + PitchInterval.minor_third).to.be_equal_to(Pitch.eflat4)
  end)

  it('should add minor third interval and pitch correctly', function()
    expect(PitchInterval.minor_third + Pitch.c4).to.be_equal_to(Pitch.eflat4)
  end)

  it('should set pitch class correctly when adding minor third to pitch', function()
    eflat4 = PitchInterval.minor_third + Pitch.c4
    expect(eflat4.pitch_class).to.be_equal_to(PitchClass.E)
  end)

  it('should set octave correctly when adding minor third to pitch', function()
    eflat4 = PitchInterval.minor_third + Pitch.c4
    expect(eflat4.octave).to.be_equal_to(4)
  end)

  it('should set accidentals correctly when adding minor third to pitch', function()
    eflat4 = PitchInterval.minor_third + Pitch.c4
    expect(eflat4.accidentals).to.be_equal_to(-1)
  end)

  it('should add pitch and octave interval correctly', function()
    expect(Pitch.c4 + PitchInterval.octave).to.be_equal_to(Pitch.c5)
  end)

  it('should add octave interval and pitch correctly', function()
    expect(PitchInterval.octave + Pitch.c4).to.be_equal_to(Pitch.c5)
  end)

  it('should subtract minor third from major third to get augmented unison', function()
    expect(PitchInterval.major_third - PitchInterval.minor_third).to.be_equal_to(
      PitchInterval.augmented_unison)
  end)

  it('should subtract perfect fifth from octave to get perfect fourth', function()
    expect(PitchInterval.octave - PitchInterval.perfect_fifth).to.be_equal_to(
      PitchInterval.perfect_fourth)
  end)

  it('should multiply major second by 2 to get major third', function()
    expect(PitchInterval.major_second * 2).to.be_equal_to(PitchInterval.major_third)
  end)

  it('should multiply 2 by major second to get major third', function()
    expect(2 * PitchInterval.major_second).to.be_equal_to(PitchInterval.major_third)
  end)

  it('should return true when perfect fourth equals interval with same values', function()
    expect(PitchInterval.perfect_fourth
      == PitchInterval{number=3, accidentals=0}).to.be_truthy()
  end)

  it('should return true when augmented fifth equals interval with same values', function()
    expect(PitchInterval.augmented_fifth
      == PitchInterval{number=4, accidentals=1}).to.be_truthy()
  end)

  it('should convert unison to integer 0', function()
    expect(tointeger(PitchInterval.unison)).to.be_equal_to(0)
  end)

  it('should convert augmented unison to integer 1', function()
    expect(tointeger(PitchInterval.augmented_unison)).to.be_equal_to(1)
  end)

  it('should convert diminished second to integer 0', function()
    expect(tointeger(PitchInterval.diminished_second)).to.be_equal_to(0)
  end)

  it('should convert minor second to integer 1', function()
    expect(tointeger(PitchInterval.minor_second)).to.be_equal_to(1)
  end)

  it('should convert major second to integer 2', function()
    expect(tointeger(PitchInterval.major_second)).to.be_equal_to(2)
  end)

  it('should convert augmented second to integer 3', function()
    expect(tointeger(PitchInterval.augmented_second)).to.be_equal_to(3)
  end)

  it('should convert diminished third to integer 2', function()
    expect(tointeger(PitchInterval.diminished_third)).to.be_equal_to(2)
  end)

  it('should convert minor third to integer 3', function()
    expect(tointeger(PitchInterval.minor_third)).to.be_equal_to(3)
  end)

  it('should convert major third to integer 4', function()
    expect(tointeger(PitchInterval.major_third)).to.be_equal_to(4)
  end)

  it('should convert augmented third to integer 5', function()
    expect(tointeger(PitchInterval.augmented_third)).to.be_equal_to(5)
  end)

  it('should convert diminished fourth to integer 4', function()
    expect(tointeger(PitchInterval.diminished_fourth)).to.be_equal_to(4)
  end)

  it('should convert perfect fourth to integer 5', function()
    expect(tointeger(PitchInterval.perfect_fourth)).to.be_equal_to(5)
  end)

  it('should convert augmented fourth to integer 6', function()
    expect(tointeger(PitchInterval.augmented_fourth)).to.be_equal_to(6)
  end)

  it('should convert diminished fifth to integer 6', function()
    expect(tointeger(PitchInterval.diminished_fifth)).to.be_equal_to(6)
  end)

  it('should convert perfect fifth to integer 7', function()
    expect(tointeger(PitchInterval.perfect_fifth)).to.be_equal_to(7)
  end)

  it('should convert augmented fifth to integer 8', function()
    expect(tointeger(PitchInterval.augmented_fifth)).to.be_equal_to(8)
  end)

  it('should convert diminished sixth to integer 7', function()
    expect(tointeger(PitchInterval.diminished_sixth)).to.be_equal_to(7)
  end)

  it('should convert minor sixth to integer 8', function()
    expect(tointeger(PitchInterval.minor_sixth)).to.be_equal_to(8)
  end)

  it('should convert major sixth to integer 9', function()
    expect(tointeger(PitchInterval.major_sixth)).to.be_equal_to(9)
  end)

  it('should convert augmented sixth to integer 10', function()
    expect(tointeger(PitchInterval.augemented_sixth)).to.be_equal_to(10)
  end)

  it('should convert diminished seventh to integer 9', function()
    expect(tointeger(PitchInterval.dimished_seventh)).to.be_equal_to(9)
  end)

  it('should convert minor seventh to integer 10', function()
    expect(tointeger(PitchInterval.minor_seventh)).to.be_equal_to(10)
  end)

  it('should convert major seventh to integer 11', function()
    expect(tointeger(PitchInterval.major_seventh)).to.be_equal_to(11)
  end)

  it('should convert augmented seventh to integer 12', function()
    expect(tointeger(PitchInterval.augmented_seventh)).to.be_equal_to(12)
  end)

  it('should convert diminished octave to integer 11', function()
    expect(tointeger(PitchInterval.dimished_octave)).to.be_equal_to(11)
  end)

  it('should convert octave to integer 12', function()
    expect(tointeger(PitchInterval.octave)).to.be_equal_to(12)
  end)

  it('should convert major third to string and back', function()
    expect(tovalue(tostring(PitchInterval.major_third))).to.be_equal_to(
      PitchInterval.major_third)
  end)

  it('should convert perfect fifth to string and back', function()
    expect(tovalue(tostring(PitchInterval.perfect_fifth))).to.be_equal_to(
      PitchInterval.perfect_fifth)
  end)

  it('should convert unison to string and back', function()
    expect(tovalue(tostring(PitchInterval.unison))).to.be_equal_to(PitchInterval.unison)
  end)

  it('should convert octave to string and back', function()
    expect(tovalue(tostring(PitchInterval.octave))).to.be_equal_to(PitchInterval.octave)
  end)

  it('should convert double diminished fifth to string and back', function()
    local double_diminished_fifth = PitchInterval{number=4, accidentals=-2}
    expect(tovalue(tostring(double_diminished_fifth))).to.be_equal_to(
      double_diminished_fifth)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
