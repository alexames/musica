local unit = require 'unit'
require 'llx'
require 'musictheory.song'

test_class 'SongTest' {
}

if main_file() then
  unit.run_unit_tests()
end
