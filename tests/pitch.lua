require 'unit'
require 'musictheory/pitch'

test_class 'PitchIntervalTest' {
  [test 'init'] = function(self)
    EXPECT_EQ(Pitch.c4, Pitch{pitchClass=PitchClass.C, octave=4, accidentals=natural})
    EXPECT_EQ(Pitch.c4, Pitch{pitchClass=PitchClass.C, octave=4})
    EXPECT_EQ(Pitch.c4.pitchClass, PitchClass.C)
    EXPECT_EQ(Pitch.c4.octave, 4)
    EXPECT_EQ(Pitch.c4.accidentals, 0)
    EXPECT_EQ(Pitch.c4, Pitch{pitchClass=PitchClass.C, pitchIndex=72})
    EXPECT_EQ(Pitch.cSharp4, Pitch{pitchClass=PitchClass.C, pitchIndex=73})
    EXPECT_EQ(Pitch.cFlat4, Pitch{pitchClass=PitchClass.C, pitchIndex=71})
    EXPECT_EQ(Pitch{pitchClass=PitchClass.C, octave=4, accidentals=2 * sharp},
              Pitch{pitchClass=PitchClass.C, pitchIndex=74})
  end;

  [test 'isPerfect'] = function(self)
    EXPECT_TRUE(PitchInterval.unison:isPerfect())
    EXPECT_FALSE(PitchInterval.majorSecond:isPerfect())
    EXPECT_FALSE(PitchInterval.majorThird:isPerfect())
    EXPECT_TRUE(PitchInterval.perfectFourth:isPerfect())
    EXPECT_TRUE(PitchInterval.perfectFifth:isPerfect())
    EXPECT_FALSE(PitchInterval.majorSixth:isPerfect())
    EXPECT_FALSE(PitchInterval.majorSeventh:isPerfect())
    EXPECT_TRUE(PitchInterval.octave:isPerfect())

    EXPECT_FALSE(PitchInterval{number=8}:isPerfect())
    EXPECT_FALSE(PitchInterval{number=9}:isPerfect())
    EXPECT_TRUE(PitchInterval{number=10}:isPerfect())
    EXPECT_TRUE(PitchInterval{number=11}:isPerfect())
    EXPECT_FALSE(PitchInterval{number=12}:isPerfect())
    EXPECT_FALSE(PitchInterval{number=13}:isPerfect())
  end;

  [test 'addPitchInterval'] = function(self)
    EXPECT_EQ(PitchInterval.majorThird + PitchInterval.minorThird,
              PitchInterval.perfectFifth)
    EXPECT_EQ(PitchInterval.minorThird + PitchInterval.majorThird,
              PitchInterval.perfectFifth)
    EXPECT_EQ(PitchInterval.majorThird + PitchInterval.majorThird,
              PitchInterval.augmentedFifth)
    EXPECT_EQ(PitchInterval.majorSecond + PitchInterval.octave,
              PitchInterval{number=8})
  end;

  [test 'addPitch'] = function(self)
    EXPECT_EQ(Pitch.c4 + PitchInterval.majorThird, Pitch.e4)
    EXPECT_EQ(PitchInterval.majorThird + Pitch.c4, Pitch.e4)

    EXPECT_EQ(Pitch.c4 + PitchInterval.minorThird, Pitch.eFlat4)
    EXPECT_EQ(PitchInterval.minorThird + Pitch.c4, Pitch.eFlat4)

    eFlat4 = PitchInterval.minorThird + Pitch.c4
    EXPECT_EQ(eFlat4.pitchClass, PitchClass.E)
    EXPECT_EQ(eFlat4.octave, 4)
    EXPECT_EQ(eFlat4.accidentals, flat)

    EXPECT_EQ(Pitch.c4 + PitchInterval.octave, Pitch.c5)
    EXPECT_EQ(PitchInterval.octave + Pitch.c4, Pitch.c5)
  end;

  [test 'subPitchInterval'] = function(self)
    EXPECT_EQ(PitchInterval.majorThird - PitchInterval.minorThird,
              PitchInterval.augmentedUnison)
    EXPECT_EQ(PitchInterval.octave - PitchInterval.perfectFifth,
              PitchInterval.perfectFourth)
  end;

  [test 'int'] = function(self)
  end;

  [test 'repr'] = function(self)
  end;
}

test_class 'PitchTest' {
  [test 'init'] = function(self)
  end;

  [test 'isEnharmonic'] = function(self)
    EXPECT_TRUE(Pitch.c4:isEnharmonic(Pitch.c4))
    -- EXPECT_TRUE(Pitch.c4:isEnharmonic(Pitch.bSharp4))
    -- EXPECT_TRUE(Pitch.gSharp4:isEnharmonic(Pitch.aFlat5))

    -- EXPECT_FALSE(Pitch.c4:isEnharmonic(Pitch.d4))
  end;

  [test 'int'] = function(self)
  end;

  [test 'eq'] = function(self)
  end;

  [test 'ne'] = function(self)
  end;

  [test 'gt'] = function(self)
  end;

  [test 'ge'] = function(self)
  end;

  [test 'lt'] = function(self)
  end;

  [test 'le'] = function(self)
  end;

  [test 'add'] = function(self)
    EXPECT_EQ(Pitch.c4 + PitchInterval.majorThird, Pitch.e4)
    EXPECT_EQ(Pitch.c4 + PitchInterval.octave, Pitch.c5)
    EXPECT_EQ(Pitch.c4 + PitchInterval.augmentedThird, Pitch.eSharp4)
  end;

  [test 'subPitch'] = function(self)
    EXPECT_EQ(Pitch.c4 - Pitch.a4, PitchInterval.minorThird)
    EXPECT_EQ(Pitch.e4 - Pitch.c4, PitchInterval.majorThird)
    EXPECT_EQ(Pitch.c5 - Pitch.c4, PitchInterval.octave)
    EXPECT_EQ(Pitch.eSharp4 - Pitch.c4, PitchInterval.augmentedThird)
  end;

  [test 'subPitchInterval'] = function(self)
    EXPECT_EQ(Pitch.e4 - PitchInterval.majorThird, Pitch.c4)
    EXPECT_EQ(Pitch.c5 - PitchInterval.octave, Pitch.c4)
    EXPECT_EQ(Pitch.eSharp4 - PitchInterval.augmentedThird, Pitch.c4)
  end;

  [test 'repr'] = function(self)
  end;
}
