require 'unit'
require 'musictheory/chord'

test_class 'ChordTest' {
  [test 'init'] = function(self)
    local chord = Chord{root=Pitch.c4, quality=Quality.major}
    -- EXPECT_TRUE(False)
  end,

  [test 'get_pitches'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'get_quality'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'to_pitch'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'to_pitches'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'to_extended_pitch'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'to_extended_pitches'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'inversion'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'call'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'truediv'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'len'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'getitem'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'contains'] = function(self)
    -- EXPECT_TRUE(False)
  end,

  [test 'repr'] = function(self)
    -- EXPECT_TRUE(False)
  end,
}

if main_file() then
  unit.run_unit_tests()
end
