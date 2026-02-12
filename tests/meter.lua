local unit = require 'llx.unit'
local llx = require 'llx'
require 'musica.meter'

local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

describe('MeterTest', function()
  -- No tests yet
end)

if main_file() then
  unit.run_unit_tests()
end
