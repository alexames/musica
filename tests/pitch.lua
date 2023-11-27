local unit = require 'unit'
require 'llx'
require 'musictheory/pitch'

test_class 'PitchTest' {
  [test 'init'] = function(self)
    EXPECT_EQ(Pitch.c4, Pitch{pitch_class=PitchClass.C, octave=4, accidentals=natural})
    EXPECT_EQ(Pitch.c4, Pitch{pitch_class=PitchClass.C, octave=4})
    EXPECT_EQ(Pitch.c4.pitch_class, PitchClass.C)
    EXPECT_EQ(Pitch.c4.octave, 4)
    EXPECT_EQ(Pitch.c4.accidentals, 0)
    EXPECT_EQ(Pitch.c4, Pitch{pitch_class=PitchClass.C, pitch_index=72})
    EXPECT_EQ(Pitch.csharp4, Pitch{pitch_class=PitchClass.C, pitch_index=73})
    EXPECT_EQ(Pitch.csharp4.accidentals, 1)
    EXPECT_EQ((Pitch.c4 + PitchInterval.augmented_unison).accidentals, 1)
    EXPECT_EQ(Pitch.cflat4, Pitch{pitch_class=PitchClass.C, pitch_index=71})
    EXPECT_EQ(Pitch{pitch_class=PitchClass.C, octave=4, accidentals=2 * Accidental.sharp},
              Pitch{pitch_class=PitchClass.C, pitch_index=74})
  end,

  [test 'is_enharmonic'] = function(self)
    EXPECT_TRUE(Pitch.c4:is_enharmonic(Pitch.c4))
    EXPECT_TRUE(Pitch.c4:is_enharmonic(Pitch.bsharp4))
    EXPECT_TRUE(Pitch.gsharp4:is_enharmonic(Pitch.aflat5))
    EXPECT_FALSE(Pitch.c4:is_enharmonic(Pitch.d4))
  end,

  [test 'tointeger'] = function(self)
    EXPECT_EQ(tointeger(Pitch.a0), 21)
    EXPECT_EQ(tointeger(Pitch.c4), 72)

    EXPECT_EQ(tointeger(Pitch.csharp4), 73)
    EXPECT_EQ(tointeger(Pitch.dflat4), 73)
  end,

  [test 'eq'] = function(self)
    EXPECT_TRUE(Pitch.c4 == Pitch.c4)
    EXPECT_TRUE(Pitch.c4 == Pitch.bsharp4)
    EXPECT_TRUE(Pitch.c4 == Pitch{pitch_class=PitchClass.C,
                                  octave=4,
                                  accidentals=0})
  end,

  [test 'lt'] = function(self)
    EXPECT_TRUE(Pitch.c4 < Pitch.d4)
    EXPECT_TRUE(Pitch.c4 < Pitch.csharp4)
    EXPECT_TRUE(Pitch.c4 < Pitch{pitch_class=PitchClass.D,
                                 octave=4,
                                 accidentals=0})
    EXPECT_TRUE(Pitch.c4 < Pitch{pitch_class=PitchClass.C,
                                 octave=5,
                                 accidentals=0})
    EXPECT_TRUE(Pitch.c4 < Pitch{pitch_class=PitchClass.C,
                                 octave=4,
                                 accidentals=Accidental.sharp})

    EXPECT_FALSE(Pitch.c4 < Pitch.b4)
    EXPECT_FALSE(Pitch.c4 < Pitch.cflat4)
    EXPECT_FALSE(Pitch.c4 < Pitch{pitch_class=PitchClass.B,
                                  octave=4,
                                  accidentals=0})
    EXPECT_FALSE(Pitch.c4 < Pitch{pitch_class=PitchClass.C,
                                  octave=3,
                                  accidentals=0})
    EXPECT_FALSE(Pitch.c4 < Pitch{pitch_class=PitchClass.C,
                                  octave=4,
                                  accidentals=Accidental.flat})
  end,

  [test 'le'] = function(self)
    EXPECT_TRUE(Pitch.c4 <= Pitch.d4)
    EXPECT_TRUE(Pitch.c4 <= Pitch.csharp4)
    EXPECT_TRUE(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                                  octave=4,
                                  accidentals=0})
    EXPECT_TRUE(Pitch.c4 <= Pitch{pitch_class=PitchClass.D,
                                  octave=4,
                                  accidentals=0})
    EXPECT_TRUE(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                                  octave=5,
                                  accidentals=0})
    EXPECT_TRUE(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                                  octave=4,
                                  accidentals=Accidental.sharp})

    EXPECT_FALSE(Pitch.c4 <= Pitch.b4)
    EXPECT_FALSE(Pitch.c4 <= Pitch.cflat4)
    EXPECT_FALSE(Pitch.c4 <= Pitch{pitch_class=PitchClass.B,
                                   octave=4,
                                   accidentals=0})
    EXPECT_FALSE(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                                   octave=3,
                                   accidentals=0})
    EXPECT_FALSE(Pitch.c4 <= Pitch{pitch_class=PitchClass.C,
                                   octave=4,
                                   accidentals=Accidental.flat})
  end,

  [test 'add'] = function(self)
    EXPECT_EQ(Pitch.c4 + PitchInterval.major_third, Pitch.e4)
    EXPECT_EQ(Pitch.c4 + PitchInterval.octave, Pitch.c5)
    EXPECT_EQ(Pitch.c4 + PitchInterval.augmented_third, Pitch.esharp4)
  end,

  [test 'sub' - 'Pitch'] = function(self)
    EXPECT_EQ(Pitch.c4 - Pitch.a4, PitchInterval.minor_third)
    EXPECT_EQ(Pitch.e4 - Pitch.c4, PitchInterval.major_third)
    EXPECT_EQ(Pitch.c5 - Pitch.c4, PitchInterval.octave)
    EXPECT_EQ(Pitch.esharp4 - Pitch.c4, PitchInterval.augmented_third)
  end,

  [test 'sub' - 'PitchInterval'] = function(self)
    EXPECT_EQ(Pitch.e4 - PitchInterval.major_third, Pitch.c4)
    EXPECT_EQ(Pitch.c5 - PitchInterval.octave, Pitch.c4)
    EXPECT_EQ(Pitch.esharp4 - PitchInterval.augmented_third, Pitch.c4)
  end,

  [test 'tostring'] = function(self)
    EXPECT_EQ(tovalue(tostring(Pitch.c4)), Pitch.c4)
    EXPECT_EQ(tovalue(tostring(Pitch.csharp4)), Pitch.csharp4)
    EXPECT_EQ(tovalue(tostring(Pitch.cflat4)), Pitch.cflat4)

    local pitch = Pitch{pitch_class=PitchClass.C,
                        octave=4,
                        accidentals=-5}
    EXPECT_EQ(tovalue(tostring(pitch)), pitch)
  end,
}

if main_file() then
  unit.run_unit_tests()
end
