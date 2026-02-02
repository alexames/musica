local unit = require 'llx.unit'
require 'llx'
require 'musica.transformations'

_ENV = unit.create_test_env(_ENV)

describe('TransformationsTest', function()
  -- No tests yet
end)

if main_file() then
  unit.run_unit_tests()
end
