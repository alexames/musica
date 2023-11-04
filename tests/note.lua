local unit = require 'unit'
require 'llx'
require 'musictheory/note'

test_class 'NoteTest' {
  [test 'setStart'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'start'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'setEnd'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'end'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'writeFile'] = function(self)
    EXPECT_TRUE(False)
  end;

  [test 'repr'] = function(self)
    EXPECT_TRUE(False)
  end;
}

if main_file() then
  unit.run_unit_tests()
end
