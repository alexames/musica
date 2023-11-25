local unit = require 'unit'
require 'llx'
require 'musictheory/direction'
require 'musictheory/mode'
require 'musictheory/pitch'
require 'musictheory/scale'

test_class 'ScaleTest' {
  [test 'get_pitches'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(scale:get_pitches(),
              List{Pitch.c4,
                   Pitch.d4,
                   Pitch.e4,
                   Pitch.f4,
                   Pitch.g4,
                   Pitch.a5,
                   Pitch.b5})
  end,

  [test 'to_pitch'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(scale:to_pitch(-8), Pitch.b3)
    EXPECT_EQ(scale:to_pitch(-7), Pitch.c3)
    EXPECT_EQ(scale:to_pitch(-6), Pitch.d3)
    EXPECT_EQ(scale:to_pitch(-5), Pitch.e3)
    EXPECT_EQ(scale:to_pitch(-4), Pitch.f3)
    EXPECT_EQ(scale:to_pitch(-3), Pitch.g3)
    EXPECT_EQ(scale:to_pitch(-2), Pitch.a4)
    EXPECT_EQ(scale:to_pitch(-1), Pitch.b4)
    EXPECT_EQ(scale:to_pitch(0), Pitch.c4)
    EXPECT_EQ(scale:to_pitch(1), Pitch.d4)
    EXPECT_EQ(scale:to_pitch(2), Pitch.e4)
    EXPECT_EQ(scale:to_pitch(3), Pitch.f4)
    EXPECT_EQ(scale:to_pitch(4), Pitch.g4)
    EXPECT_EQ(scale:to_pitch(5), Pitch.a5)
    EXPECT_EQ(scale:to_pitch(6), Pitch.b5)
    EXPECT_EQ(scale:to_pitch(7), Pitch.c5)
    EXPECT_EQ(scale:to_pitch(8), Pitch.d5)
  end,

  [test 'to_pitches'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(scale:to_pitches({-8, -7, -5, -3, -1, 0, 1, 3, 5, 7, 8}),
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
  end,

  [test 'to_scale_index'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(scale:to_scale_index(Pitch.a4), -2)
    EXPECT_EQ(scale:to_scale_index(Pitch.c4), 0)
    EXPECT_EQ(scale:to_scale_index(Pitch.e4), 2)
  end,

  [test 'relative'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(scale:relative{mode=Mode.minor},
              Scale{tonic=Pitch.a5, mode=Mode.minor})
    EXPECT_EQ(scale:relative{mode=Mode.minor, direction=Direction.down},
              Scale{tonic=Pitch.a4, mode=Mode.minor})
  end,

  [test 'parallel'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(scale:parallel(Mode.minor),
              Scale{tonic=Pitch.c4, mode=Mode.minor})
  end,

  [test 'len'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(#scale, 7)
  end,

  [test 'index'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(scale[-8], Pitch.b3)
    EXPECT_EQ(scale[-7], Pitch.c3)
    EXPECT_EQ(scale[-6], Pitch.d3)
    EXPECT_EQ(scale[-5], Pitch.e3)
    EXPECT_EQ(scale[-4], Pitch.f3)
    EXPECT_EQ(scale[-3], Pitch.g3)
    EXPECT_EQ(scale[-2], Pitch.a4)
    EXPECT_EQ(scale[-1], Pitch.b4)
    EXPECT_EQ(scale[0], Pitch.c4)
    EXPECT_EQ(scale[1], Pitch.d4)
    EXPECT_EQ(scale[2], Pitch.e4)
    EXPECT_EQ(scale[3], Pitch.f4)
    EXPECT_EQ(scale[4], Pitch.g4)
    EXPECT_EQ(scale[5], Pitch.a5)
    EXPECT_EQ(scale[6], Pitch.b5)
    EXPECT_EQ(scale[7], Pitch.c5)
    EXPECT_EQ(scale[8], Pitch.d5)
    EXPECT_EQ(scale[{-3, -2, -1, 0, 1, 2}],
                    List{Pitch.g3, Pitch.a4, Pitch.b4, Pitch.c4, Pitch.d4, Pitch.e4})
    EXPECT_EQ(scale[{-3, 0, 3}],
                    List{Pitch.g3, Pitch.c4, Pitch.f4})
  end,

  [test 'contains'] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_TRUE(scale:contains(Pitch.c4))
    EXPECT_TRUE(scale:contains(Pitch.d4))
    EXPECT_TRUE(scale:contains(Pitch.c5))
    EXPECT_TRUE(scale:contains(Pitch.a0))
    EXPECT_TRUE(scale:contains({Pitch.a0, Pitch.b1, Pitch.c2, Pitch.d3}))

    EXPECT_FALSE(scale:contains(Pitch.csharp4))
    EXPECT_FALSE(scale:contains({Pitch.asharp0, Pitch.b1, Pitch.c2, Pitch.d3}))
  end,

  [test 'tostring'] = function(self)
    local scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(tovalue(tostring(scale)), scale)
  end,

  -- [test 'findChord'] = function(self)
  --   EXPECT_TRUE(False)
  -- end,
}

if main_file() then
  unit.run_unit_tests()
end
