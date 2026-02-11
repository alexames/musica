local unit = require 'llx.unit'
local llx = require 'llx'
local pitch_module = require 'musica.pitch'
local pitch_class_module = require 'musica.pitch_class'
local pitch_interval_module = require 'musica.pitch_interval'
local accidental_module = require 'musica.accidental'

local Pitch = pitch_module.Pitch
local PitchClass = pitch_class_module.PitchClass
local PitchInterval = pitch_interval_module.PitchInterval
local Accidental = accidental_module.Accidental
local natural = Accidental.natural
local tointeger = llx.tointeger
local tovalue = llx.tovalue
local main_file = llx.main_file

-- tovalue uses load() which executes in the global environment
_G.Pitch = Pitch

_ENV = unit.create_test_env(_ENV)

describe('PitchTest', function()
  it('should create pitch equal to c4 when constructed with pitch class, octave, and natural accidentals', function()
    expect(Pitch.c4).to.be_equal_to(Pitch{pitch_class=PitchClass.C, octave=4, accidentals=natural})
  end)

  it('should create pitch equal to c4 when constructed with pitch class and octave only', function()
    expect(Pitch.c4).to.be_equal_to(Pitch{pitch_class=PitchClass.C, octave=4})
  end)

  it('should set pitch class correctly', function()
    expect(Pitch.c4.pitch_class).to.be_equal_to(PitchClass.C)
  end)

  it('should set octave correctly', function()
    expect(Pitch.c4.octave).to.be_equal_to(4)
  end)

  it('should default accidentals to 0', function()
    expect(Pitch.c4.accidentals).to.be_equal_to(0)
  end)

  it('should create pitch equal to c4 when constructed with pitch class and pitch index', function()
    expect(Pitch.c4).to.be_equal_to(Pitch{pitch_class=PitchClass.C, pitch_index=72})
  end)

  it('should create csharp4 when constructed with pitch index 73', function()
    expect(Pitch.csharp4).to.be_equal_to(Pitch{pitch_class=PitchClass.C, pitch_index=73})
  end)

  it('should set accidentals to 1 for csharp4', function()
    expect(Pitch.csharp4.accidentals).to.be_equal_to(1)
  end)

  it('should add augmented unison correctly', function()
    expect((Pitch.c4 + PitchInterval.augmented_unison).accidentals).to.be_equal_to(1)
  end)

  it('should create cflat4 when constructed with pitch index 71', function()
    expect(Pitch.cflat4).to.be_equal_to(Pitch{pitch_class=PitchClass.C, pitch_index=71})
  end)

  it('should create pitch with double sharp when constructed with accidentals', function()
    expect(Pitch{pitch_class=PitchClass.C, octave=4, accidentals=2 * Accidental.sharp}).to.be_equal_to(
      Pitch{pitch_class=PitchClass.C, pitch_index=74})
  end)

  it('should return true when pitch is enharmonic to itself', function()
    expect(Pitch.c4:is_enharmonic(Pitch.c4)).to.be_truthy()
  end)

  it('should return true when c4 is enharmonic to bsharp4', function()
    expect(Pitch.c4:is_enharmonic(Pitch.bsharp4)).to.be_truthy()
  end)

  it('should return true when gsharp4 is enharmonic to aflat5', function()
    expect(Pitch.gsharp4:is_enharmonic(Pitch.aflat5)).to.be_truthy()
  end)

  it('should return false when c4 is not enharmonic to d4', function()
    expect(Pitch.c4:is_enharmonic(Pitch.d4)).to.be_falsy()
  end)

  it('should convert a0 to integer 21', function()
    expect(tointeger(Pitch.a0)).to.be_equal_to(21)
  end)

  it('should convert c4 to integer 72', function()
    expect(tointeger(Pitch.c4)).to.be_equal_to(72)
  end)

  it('should convert csharp4 to integer 73', function()
    expect(tointeger(Pitch.csharp4)).to.be_equal_to(73)
  end)

  it('should convert dflat4 to integer 73', function()
    expect(tointeger(Pitch.dflat4)).to.be_equal_to(73)
  end)

  it('should return true when c4 equals c4', function()
    expect(Pitch.c4 == Pitch.c4).to.be_truthy()
  end)

  it('should return true when c4 is enharmonic to bsharp4', function()
    expect(Pitch.c4:is_enharmonic(Pitch.bsharp4)).to.be_truthy()
  end)

  it('should return true when c4 equals pitch constructed with same values', function()
    expect(Pitch.c4 == Pitch{pitch_class=PitchClass.C,
                              octave=4,
                              accidentals=0}).to.be_truthy()
  end)

  it('should return true when c4 is less than d4', function()
    expect(Pitch.c4 < Pitch.d4).to.be_truthy()
  end)

  it('should return true when c4 is less than csharp4', function()
    expect(Pitch.c4 < Pitch.csharp4).to.be_truthy()
  end)

  it('should return true when c4 is less than pitch with higher pitch class', function()
    expect(Pitch.c4 < Pitch{pitch_class=PitchClass.D,
                            octave=4,
                            accidentals=0}).to.be_truthy()
  end)

  it('should return true when c4 is less than pitch with higher octave', function()
    expect(Pitch.c4 < Pitch{pitch_class=PitchClass.C,
                            octave=5,
                            accidentals=0}).to.be_truthy()
  end)

  it('should return true when c4 is less than pitch with sharp accidental', function()
    expect(Pitch.c4 < Pitch{pitch_class=PitchClass.C,
                            octave=4,
                            accidentals=Accidental.sharp}).to.be_truthy()
  end)

  it('should return false when c4 is not less than b4', function()
    expect(Pitch.c4 < Pitch.b4).to.be_falsy()
  end)

  it('should return false when c4 is not less than cflat4', function()
    expect(Pitch.c4 < Pitch.cflat4).to.be_falsy()
  end)

  it('should return false when c4 is not less than pitch with lower pitch class', function()
    expect(Pitch.c4 < Pitch{pitch_class=PitchClass.B,
                            octave=4,
                            accidentals=0}).to.be_falsy()
  end)

  it('should return false when c4 is not less than pitch with lower octave', function()
    expect(Pitch.c4 < Pitch{pitch_class=PitchClass.C,
                            octave=3,
                            accidentals=0}).to.be_falsy()
  end)

  it('should return false when c4 is not less than pitch with flat accidental', function()
    expect(Pitch.c4 < Pitch{pitch_class=PitchClass.C,
                            octave=4,
                            accidentals=Accidental.flat}).to.be_falsy()
  end)

  it('should return true when c4 is less than or equal to d4', function()
    expect(Pitch.c4 <= Pitch.d4).to.be_truthy()
  end)

  it('should return true when c4 is less than or equal to csharp4', function()
    expect(Pitch.c4 <= Pitch.csharp4).to.be_truthy()
  end)

  it('should return true when c4 is less than or equal to itself', function()
    expect(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                             octave=4,
                             accidentals=0}).to.be_truthy()
  end)

  it('should return true when c4 is less than or equal to pitch with higher pitch class', function()
    expect(Pitch.c4 <= Pitch{pitch_class=PitchClass.D,
                             octave=4,
                             accidentals=0}).to.be_truthy()
  end)

  it('should return true when c4 is less than or equal to pitch with higher octave', function()
    expect(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                             octave=5,
                             accidentals=0}).to.be_truthy()
  end)

  it('should return true when c4 is less than or equal to pitch with sharp accidental', function()
    expect(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                             octave=4,
                             accidentals=Accidental.sharp}).to.be_truthy()
  end)

  it('should return false when c4 is not less than or equal to b4', function()
    expect(Pitch.c4 <= Pitch.b4).to.be_falsy()
  end)

  it('should return false when c4 is not less than or equal to cflat4', function()
    expect(Pitch.c4 <= Pitch.cflat4).to.be_falsy()
  end)

  it('should return false when c4 is not less than or equal to pitch with lower pitch class', function()
    expect(Pitch.c4 <= Pitch{pitch_class=PitchClass.B,
                             octave=4,
                             accidentals=0}).to.be_falsy()
  end)

  it('should return false when c4 is not less than or equal to pitch with lower octave', function()
    expect(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                             octave=3,
                             accidentals=0}).to.be_falsy()
  end)

  it('should return false when c4 is not less than or equal to pitch with flat accidental', function()
    expect(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                             octave=4,
                             accidentals=Accidental.flat}).to.be_falsy()
  end)

  it('should add major third correctly', function()
    expect(Pitch.c4 + PitchInterval.major_third).to.be_equal_to(Pitch.e4)
  end)

  it('should add octave correctly', function()
    expect(Pitch.c4 + PitchInterval.octave).to.be_equal_to(Pitch.c5)
  end)

  it('should add augmented third correctly', function()
    expect(Pitch.c4 + PitchInterval.augmented_third).to.be_equal_to(Pitch.esharp4)
  end)

  it('should subtract pitch to get minor third interval', function()
    expect(Pitch.c4 - Pitch.a4).to.be_equal_to(PitchInterval.minor_third)
  end)

  it('should subtract pitch to get major third interval', function()
    expect(Pitch.e4 - Pitch.c4).to.be_equal_to(PitchInterval.major_third)
  end)

  it('should subtract pitch to get octave interval', function()
    expect(Pitch.c5 - Pitch.c4).to.be_equal_to(PitchInterval.octave)
  end)

  it('should subtract pitch to get augmented third interval', function()
    expect(Pitch.esharp4 - Pitch.c4).to.be_equal_to(PitchInterval.augmented_third)
  end)

  it('should subtract major third interval to get lower pitch', function()
    expect(Pitch.e4 - PitchInterval.major_third).to.be_equal_to(Pitch.c4)
  end)

  it('should subtract octave interval to get lower pitch', function()
    expect(Pitch.c5 - PitchInterval.octave).to.be_equal_to(Pitch.c4)
  end)

  it('should subtract augmented third interval to get lower pitch', function()
    expect(Pitch.esharp4 - PitchInterval.augmented_third).to.be_equal_to(Pitch.c4)
  end)

  it('should convert c4 to string and back to same pitch', function()
    expect(tovalue(tostring(Pitch.c4))).to.be_equal_to(Pitch.c4)
  end)

  it('should convert csharp4 to string and back to same pitch', function()
    expect(tovalue(tostring(Pitch.csharp4))).to.be_equal_to(Pitch.csharp4)
  end)

  it('should convert cflat4 to string and back to same pitch', function()
    expect(tovalue(tostring(Pitch.cflat4))).to.be_equal_to(Pitch.cflat4)
  end)

  it('should convert pitch with multiple flats to string and back', function()
    local pitch = Pitch{pitch_class=PitchClass.C,
                        octave=4,
                        accidentals=-5}
    expect(tovalue(tostring(pitch))).to.be_equal_to(pitch)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
