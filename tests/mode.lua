local unit = require 'unit'
require 'llx'
require 'musictheory.mode'
require 'musictheory.modes'

test_class 'ModeTest' {
  [test 'init'] = function(self)
    EXPECT_EQ(Mode.ionian, Mode.major)
    EXPECT_EQ(Mode.ionian.semitone_intervals, List{
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
    })
  end,

  [test 'relative'] = function(self)
    EXPECT_EQ(Mode.major:relative(Mode.minor), 5)
    EXPECT_EQ(Mode.minor:relative(Mode.major), 2)
  end,

  [test 'octave_interval'] = function(self)
  end,

  [test 'rotate'] = function(self)
    EXPECT_EQ(Mode.major << 5, Mode.minor)
    EXPECT_EQ(Mode.minor << 2, Mode.major)
    EXPECT_EQ(Mode.major >> 2, Mode.minor)
    EXPECT_EQ(Mode.minor >> 5, Mode.major)
  end,

  [test 'eq'] = function(self)
    EXPECT_TRUE(Mode.ionian == Mode(List{
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
    }))

    EXPECT_FALSE(Mode.ionian == Mode(List{
      PitchInterval.whole,
      PitchInterval.half,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
      PitchInterval.whole,
    }))
  end,

  [test 'len'] = function(self)
    EXPECT_EQ(#Mode.major, 7)
  end,

  [test 'index'] = function(self)
    EXPECT_EQ(Mode.major[0], PitchInterval.unison)
    EXPECT_EQ(Mode.major[1], PitchInterval.major_second)
    EXPECT_EQ(Mode.major[2], PitchInterval.major_third)
    EXPECT_EQ(Mode.major[3], PitchInterval.perfect_fourth)
    EXPECT_EQ(Mode.major[4], PitchInterval.perfect_fifth)
    EXPECT_EQ(Mode.major[5], PitchInterval.major_sixth)
    EXPECT_EQ(Mode.major[6], PitchInterval.major_seventh)
    EXPECT_EQ(Mode.major[7], PitchInterval.octave)
    EXPECT_EQ(Mode.major[14], 2 * PitchInterval.octave)

    EXPECT_EQ(Mode.minor[0], PitchInterval.unison)
    EXPECT_EQ(Mode.minor[1], PitchInterval.major_second)
    EXPECT_EQ(Mode.minor[2], PitchInterval.minor_third)
    EXPECT_EQ(Mode.minor[3], PitchInterval.perfect_fourth)
    EXPECT_EQ(Mode.minor[4], PitchInterval.perfect_fifth)
    EXPECT_EQ(Mode.minor[5], PitchInterval.minor_sixth)
    EXPECT_EQ(Mode.minor[6], PitchInterval.minor_seventh)
    EXPECT_EQ(Mode.minor[7], PitchInterval.octave)
    EXPECT_EQ(Mode.minor[14], 2 * PitchInterval.octave)
  end,

  [test 'tostring'] = function(self)
    local mode = Mode.major
    EXPECT_EQ(tovalue(tostring(mode)), mode)
  end,
}

if main_file() then
  unit.run_unit_tests()
end
