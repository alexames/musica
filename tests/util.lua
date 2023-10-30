require 'unit'
require 'musictheory/util'

test_class 'UtilTest' {
  [test 'reprArgs'] = function(self)
    -- Single unnamed arg
    -- EXPECT_EQ(reprArgs('Test', {{nil}}), 'Test(nil)')
    -- EXPECT_EQ(reprArgs('Test', {{100}}), 'Test(100)')
    -- EXPECT_EQ(reprArgs('Test', {{false}}), 'Test(false)')
    -- EXPECT_EQ(reprArgs('Test', {{true}}), 'Test(true)')
    -- EXPECT_EQ(reprArgs('Test', {{'string'}}), "Test('string')")
    -- Single named arg
  end,

  [test 'intervalsToIndices'] = function(self)
  end,

  [test 'indicesToIntervals'] = function(self)
  end,

  [test 'extendedIndex'] = function(self)
  end,

  [test 'extendedIndices'] = function(self)
  end,
}

test_class 'RingTest' {

}

test_class 'SpiralTest' {
  [test 'index'] = function(self)
    spiral = Spiral(0, 3, 5)
    EXPECT_EQ(spiral[-4], -10)
    EXPECT_EQ(spiral[-3], -7)
    EXPECT_EQ(spiral[-2], -5)
    EXPECT_EQ(spiral[-1], -2)
    EXPECT_EQ(spiral[0], 0)
    EXPECT_EQ(spiral[1], 3)
    EXPECT_EQ(spiral[2], 5)
    EXPECT_EQ(spiral[3], 8)
    EXPECT_EQ(spiral[4], 10)
  end
}
