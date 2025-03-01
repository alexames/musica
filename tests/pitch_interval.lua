local unit = require 'unit'
require 'llx'
require 'musictheory.pitch'
require 'musictheory.pitch_interval'
require 'musictheory.quality'

test_class 'PitchIntervalTest' {
  [test 'init'] = function(self)
    EXPECT_EQ(PitchInterval{number=2, quality=Quality.major},
              PitchInterval.major_third)

    EXPECT_EQ(PitchInterval{number=2, semitone_interval=4},
              PitchInterval.major_third)

    EXPECT_EQ(PitchInterval{number=2, accidentals=0},
              PitchInterval.major_third)
    EXPECT_EQ(PitchInterval{number=2, accidentals=Accidental.natural},
              PitchInterval.major_third)
  end,

  [test 'is_perfect'] = function(self)
    EXPECT_TRUE(PitchInterval.unison:is_perfect())
    EXPECT_FALSE(PitchInterval.major_second:is_perfect())
    EXPECT_FALSE(PitchInterval.major_third:is_perfect())
    EXPECT_TRUE(PitchInterval.perfect_fourth:is_perfect())
    EXPECT_TRUE(PitchInterval.perfect_fifth:is_perfect())
    EXPECT_FALSE(PitchInterval.major_sixth:is_perfect())
    EXPECT_FALSE(PitchInterval.major_seventh:is_perfect())
    EXPECT_TRUE(PitchInterval.octave:is_perfect())

    EXPECT_FALSE(PitchInterval{number=8}:is_perfect())
    EXPECT_FALSE(PitchInterval{number=9}:is_perfect())
    EXPECT_TRUE(PitchInterval{number=10}:is_perfect())
    EXPECT_TRUE(PitchInterval{number=11}:is_perfect())
    EXPECT_FALSE(PitchInterval{number=12}:is_perfect())
    EXPECT_FALSE(PitchInterval{number=13}:is_perfect())
  end,

  [test 'is_enharmonic'] = function(self)
    EXPECT_TRUE(PitchInterval.augmented_second:is_enharmonic(
                PitchInterval.augmented_second))
    EXPECT_TRUE(PitchInterval.augmented_second:is_enharmonic(
                PitchInterval.minor_third))

    EXPECT_FALSE(PitchInterval.minor_third:is_enharmonic(
                 PitchInterval.major_third))
  end,

  [test 'add' - 'PitchInterval'] = function(self)
    EXPECT_EQ(PitchInterval.major_third + PitchInterval.minor_third,
              PitchInterval.perfect_fifth)
    EXPECT_EQ(PitchInterval.minor_third + PitchInterval.major_third,
              PitchInterval.perfect_fifth)
    EXPECT_EQ(PitchInterval.major_third + PitchInterval.major_third,
              PitchInterval.augmented_fifth)
    EXPECT_EQ(PitchInterval.major_second + PitchInterval.octave,
              PitchInterval{number=8})
  end,

  [test 'add' - 'Pitch'] = function(self)
    EXPECT_EQ(Pitch.c4 + PitchInterval.major_third, Pitch.e4)
    EXPECT_EQ(PitchInterval.major_third + Pitch.c4, Pitch.e4)

    EXPECT_EQ(Pitch.c4 + PitchInterval.minor_third, Pitch.eflat4)
    EXPECT_EQ(PitchInterval.minor_third + Pitch.c4, Pitch.eflat4)

    eflat4 = PitchInterval.minor_third + Pitch.c4
    EXPECT_EQ(eflat4.pitch_class, PitchClass.E)
    EXPECT_EQ(eflat4.octave, 4)
    EXPECT_EQ(eflat4.accidentals, -1)

    EXPECT_EQ(Pitch.c4 + PitchInterval.octave, Pitch.c5)
    EXPECT_EQ(PitchInterval.octave + Pitch.c4, Pitch.c5)
  end,

  [test 'sub' - 'PitchInterval'] = function(self)
    EXPECT_EQ(PitchInterval.major_third - PitchInterval.minor_third,
              PitchInterval.augmented_unison)
    EXPECT_EQ(PitchInterval.octave - PitchInterval.perfect_fifth,
              PitchInterval.perfect_fourth)
  end,

  [test 'mul'] = function(self)
    EXPECT_EQ(PitchInterval.major_second * 2, PitchInterval.major_third)
    EXPECT_EQ(2 * PitchInterval.major_second, PitchInterval.major_third)
  end,

  [test 'eq'] = function(self)
    EXPECT_TRUE(PitchInterval.perfect_fourth
                == PitchInterval{number=3, accidentals=0})
    EXPECT_TRUE(PitchInterval.augmented_fifth
                == PitchInterval{number=4, accidentals=1})
  end,

  [test 'tointeger'] = function(self)
    EXPECT_EQ(tointeger(PitchInterval.unison), 0)
    EXPECT_EQ(tointeger(PitchInterval.augmented_unison), 1)
    EXPECT_EQ(tointeger(PitchInterval.diminished_second), 0)
    EXPECT_EQ(tointeger(PitchInterval.minor_second), 1)
    EXPECT_EQ(tointeger(PitchInterval.major_second), 2)
    EXPECT_EQ(tointeger(PitchInterval.augmented_second), 3)
    EXPECT_EQ(tointeger(PitchInterval.diminished_third), 2)
    EXPECT_EQ(tointeger(PitchInterval.minor_third), 3)
    EXPECT_EQ(tointeger(PitchInterval.major_third), 4)
    EXPECT_EQ(tointeger(PitchInterval.augmented_third), 5)
    EXPECT_EQ(tointeger(PitchInterval.diminished_fourth), 4)
    EXPECT_EQ(tointeger(PitchInterval.perfect_fourth), 5)
    EXPECT_EQ(tointeger(PitchInterval.augmented_fourth), 6)
    EXPECT_EQ(tointeger(PitchInterval.diminished_fifth), 6)
    EXPECT_EQ(tointeger(PitchInterval.perfect_fifth), 7)
    EXPECT_EQ(tointeger(PitchInterval.augmented_fifth), 8)
    EXPECT_EQ(tointeger(PitchInterval.diminished_sixth), 7)
    EXPECT_EQ(tointeger(PitchInterval.minor_sixth), 8)
    EXPECT_EQ(tointeger(PitchInterval.major_sixth), 9)
    EXPECT_EQ(tointeger(PitchInterval.augemented_sixth), 10)
    EXPECT_EQ(tointeger(PitchInterval.dimished_seventh), 9)
    EXPECT_EQ(tointeger(PitchInterval.minor_seventh), 10)
    EXPECT_EQ(tointeger(PitchInterval.major_seventh), 11)
    EXPECT_EQ(tointeger(PitchInterval.augmented_seventh), 12)
    EXPECT_EQ(tointeger(PitchInterval.dimished_octave), 11)
    EXPECT_EQ(tointeger(PitchInterval.octave), 12)
  end,

  [test 'tostring'] = function(self)
    EXPECT_EQ(tovalue(tostring(PitchInterval.major_third)),
              PitchInterval.major_third)
    EXPECT_EQ(tovalue(tostring(PitchInterval.perfect_fifth)),
              PitchInterval.perfect_fifth)
    EXPECT_EQ(tovalue(tostring(PitchInterval.unison)), PitchInterval.unison)
    EXPECT_EQ(tovalue(tostring(PitchInterval.octave)), PitchInterval.octave)

    local double_diminished_fifth = PitchInterval{number=4, accidentals=-2}
    EXPECT_EQ(tovalue(tostring(double_diminished_fifth)),
              double_diminished_fifth)
  end,
}

if main_file() then
  unit.run_unit_tests()
end
