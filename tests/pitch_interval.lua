require 'musictheory/pitch'
require 'musictheory/pitch_interval'
require 'unit'

test_class 'PitchIntervalTest' {
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

  [test 'add_pitch_interval'] = function(self)
    EXPECT_EQ(PitchInterval.major_third + PitchInterval.minor_third,
              PitchInterval.perfect_fifth)
    EXPECT_EQ(PitchInterval.minor_third + PitchInterval.major_third,
              PitchInterval.perfect_fifth)
    EXPECT_EQ(PitchInterval.major_third + PitchInterval.major_third,
              PitchInterval.augmented_fifth)
    EXPECT_EQ(PitchInterval.major_second + PitchInterval.octave,
              PitchInterval{number=8})
  end,

  [test 'add_pitch'] = function(self)
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

  [test 'subPitchInterval'] = function(self)
    EXPECT_EQ(PitchInterval.major_third - PitchInterval.minor_third,
              PitchInterval.augmented_unison)
    EXPECT_EQ(PitchInterval.octave - PitchInterval.perfect_fifth,
              PitchInterval.perfect_fourth)
  end,

  -- [test 'int'] = function(self)
  -- end,

  -- [test 'repr'] = function(self)
  -- end,
}
