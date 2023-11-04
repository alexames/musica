local unit = require 'unit'
require 'llx'
require 'musictheory/meter'

test_class 'MeterTest' {
}

if main_file() then
  unit.run_unit_tests()
end
