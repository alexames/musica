local unit = require 'unit'
require 'llx'
require 'musictheory.quality'

test_class 'QualityTest' {
  [test('init')] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    EXPECT_EQ(Quality{pitches=scale:pitches(0, 2, 4)}, Quality.major)

    scale = Scale{tonic=Pitch.c4, mode=Mode.minor}
    EXPECT_EQ(Quality{pitches=scale:pitches(0, 2, 4)}, Quality.minor)
  end;

  [test('pitch_intervals')] = function(self)
    EXPECT_EQ(Quality.major.pitch_intervals,
              List{PitchInterval.unison,
                   PitchInterval.majorThird,
                   PitchInterval.perfectFifth})
  end;

  [test('eq')] = function(self)
    scale = Scale{tonic=Pitch.c4, mode=Mode.minor}
    self.assertTrue(Quality{pitches=scale:pitches(0, 2, 4)} == Quality.minor)
  end;

  [test('len')] = function(self)
    EXPECT_EQ(#Quality.major, 3)
  end;

  [test('repr')] = function(self)
    EXPECT_EQ(eval(repr(Quality.major)), Quality.major)
  end;
}

if main_file() then
  unit.run_unit_tests()
end
