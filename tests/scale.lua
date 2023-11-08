local unit = require 'unit'
require 'llx'
require 'musictheory/scale'

test_class 'ScaleTest' {
  [test 'getPitches'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQUAL(scale.getPitches(),
                     List{Pitch.c4, Pitch.d4, Pitch.e4, Pitch.f4, Pitch.g4, Pitch.a5, Pitch.b5})
  end;

  [test 'toPitch' - 'teslktj'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQUAL(scale.toPitch(-8), Pitch.b3)
    EXPECT_EQUAL(scale.toPitch(-7), Pitch.c3)
    EXPECT_EQUAL(scale.toPitch(-6), Pitch.d3)
    EXPECT_EQUAL(scale.toPitch(-5), Pitch.e3)
    EXPECT_EQUAL(scale.toPitch(-4), Pitch.f3)
    EXPECT_EQUAL(scale.toPitch(-3), Pitch.g3)
    EXPECT_EQUAL(scale.toPitch(-2), Pitch.a4)
    EXPECT_EQUAL(scale.toPitch(-1), Pitch.b4)
    EXPECT_EQUAL(scale.toPitch(0), Pitch.c4)
    EXPECT_EQUAL(scale.toPitch(1), Pitch.d4)
    EXPECT_EQUAL(scale.toPitch(2), Pitch.e4)
    EXPECT_EQUAL(scale.toPitch(3), Pitch.f4)
    EXPECT_EQUAL(scale.toPitch(4), Pitch.g4)
    EXPECT_EQUAL(scale.toPitch(5), Pitch.a5)
    EXPECT_EQUAL(scale.toPitch(6), Pitch.b5)
    EXPECT_EQUAL(scale.toPitch(7), Pitch.c5)
    EXPECT_EQUAL(scale.toPitch(8), Pitch.d5)
  end;

  [test 'toPitches'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQUAL(scale.toPitches({-8, -7, -5, -3, -1, 0, 1, 3, 5, 7, 8}),
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
  end;

  [test 'toScaleIndex'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQUAL(scale.toScaleIndex(Pitch.a4), -2)
    EXPECT_EQUAL(scale.toScaleIndex(Pitch.c4), 0)
    EXPECT_EQUAL(scale.toScaleIndex(Pitch.e4), 2)
  end;

  [test 'relative'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQUAL(scale.relative{mode=Mode.minor},
                     Scale{tonic=Pitch.a5, mode=Mode.minor})
    EXPECT_EQUAL(scale.relative{mode=Mode.minor, direction=down},
                     Scale{tonic=Pitch.a4, mode=Mode.minor})
  end;

  [test 'parallel'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQUAL(scale.parallel{mode=Mode.minor},
                     Scale{tonic=Pitch.c4, mode=Mode.minor})
  end;

  [test 'len'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQUAL(#scale, 7)
  end;

  [test 'getitem'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQUAL(scale[-8], Pitch.b3)
    EXPECT_EQUAL(scale[-7], Pitch.c3)
    EXPECT_EQUAL(scale[-6], Pitch.d3)
    EXPECT_EQUAL(scale[-5], Pitch.e3)
    EXPECT_EQUAL(scale[-4], Pitch.f3)
    EXPECT_EQUAL(scale[-3], Pitch.g3)
    EXPECT_EQUAL(scale[-2], Pitch.a4)
    EXPECT_EQUAL(scale[-1], Pitch.b4)
    EXPECT_EQUAL(scale[0], Pitch.c4)
    EXPECT_EQUAL(scale[1], Pitch.d4)
    EXPECT_EQUAL(scale[2], Pitch.e4)
    EXPECT_EQUAL(scale[3], Pitch.f4)
    EXPECT_EQUAL(scale[4], Pitch.g4)
    EXPECT_EQUAL(scale[5], Pitch.a5)
    EXPECT_EQUAL(scale[6], Pitch.b5)
    EXPECT_EQUAL(scale[7], Pitch.c5)
    EXPECT_EQUAL(scale[8], Pitch.d5)
    -- EXPECT_EQUAL(scale[-3:3],
    --                  [Pitch.g3, Pitch.a4, Pitch.b4, Pitch.c4, Pitch.d4, Pitch.e4])
    -- EXPECT_EQUAL(scale[-3, 0, 3],
    --                  [Pitch.g3, Pitch.c4, Pitch.f4])
  end;

  [test 'contains'] = function(self)
    -- scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    -- EXPECT_TRUE(Pitch.c4 in scale)
    -- EXPECT_TRUE(Pitch.d4 in scale)
    -- EXPECT_TRUE(Pitch.c5 in scale)
    -- EXPECT_TRUE(Pitch.a0 in scale)
    -- EXPECT_TRUE([Pitch.a0, Pitch.b1, Pitch.c2, Pitch.d3] in scale)

    -- EXPECT_FALSE(Pitch.cSharp4 in scale)
    -- EXPECT_FALSE([Pitch.aSharp0, Pitch.b1, Pitch.c2, Pitch.d3] in scale)  end;
  end;

  [test 'repr'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQUAL(eval(repr(scale)), scale)
  end;

  [test 'findChord'] = function(self)
    EXPECT_TRUE(False)
  end;
}

if main_file() then
  unit.run_unit_tests()
end
