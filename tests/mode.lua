local unit = require 'unit'
require 'llx'
require 'musictheory/mode'

test_class 'ModeTest' {
  [test 'init'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'relative'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'rotate'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'getitem'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'len'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'repr'] = function(self)
    EXPECT_TRUE(False)
  end;
}

if main_file() then
  unit.run_unit_tests()
end
