require 'unit'
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
    EXPECT_EQ(Pitch.cflat4, Pitch{pitch_class=PitchClass.C, pitch_index=71})
    EXPECT_EQ(Pitch{pitch_class=PitchClass.C, octave=4, accidentals=2 * sharp},
              Pitch{pitch_class=PitchClass.C, pitch_index=74})
  end,

  [test 'init'] = function(self)
  end,

  [test 'is_enharmonic'] = function(self)
    EXPECT_TRUE(Pitch.c4:is_enharmonic(Pitch.c4))
    EXPECT_TRUE(Pitch.c4:is_enharmonic(Pitch.bsharp4))
    EXPECT_TRUE(Pitch.gsharp4:is_enharmonic(Pitch.aflat5))
    EXPECT_FALSE(Pitch.c4:is_enharmonic(Pitch.d4))
  end,

  -- [test 'int'] = function(self)
  -- end,

  -- [test 'eq'] = function(self)
  -- end,

  -- [test 'ne'] = function(self)
  -- end,

  -- [test 'gt'] = function(self)
  -- end,

  -- [test 'ge'] = function(self)
  -- end,

  -- [test 'lt'] = function(self)
  -- end,

  -- [test 'le'] = function(self)
  -- end,

  [test 'add'] = function(self)
    EXPECT_EQ(Pitch.c4 + PitchInterval.major_third, Pitch.e4)
    EXPECT_EQ(Pitch.c4 + PitchInterval.octave, Pitch.c5)
    EXPECT_EQ(Pitch.c4 + PitchInterval.augmented_third, Pitch.esharp4)
  end,

  [test 'subPitch'] = function(self)
    EXPECT_EQ(Pitch.c4 - Pitch.a4, PitchInterval.minor_third)
    EXPECT_EQ(Pitch.e4 - Pitch.c4, PitchInterval.major_third)
    EXPECT_EQ(Pitch.c5 - Pitch.c4, PitchInterval.octave)
    EXPECT_EQ(Pitch.esharp4 - Pitch.c4, PitchInterval.augmented_third)
  end,

  [test 'subPitchInterval'] = function(self)
    EXPECT_EQ(Pitch.e4 - PitchInterval.major_third, Pitch.c4)
    EXPECT_EQ(Pitch.c5 - PitchInterval.octave, Pitch.c4)
    EXPECT_EQ(Pitch.esharp4 - PitchInterval.augmented_third, Pitch.c4)
  end,

  -- [test 'repr'] = function(self)
  -- end,
}
