local unit = require 'unit'
require 'llx'
require 'musictheory.transformations'

test_class 'TransformationsTest' {
}

if main_file() then
  unit.run_unit_tests()
end
