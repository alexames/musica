local unit = require 'llx.unit'
require 'llx'
require 'musica.song'

_ENV = unit.create_test_env(_ENV)

describe('SongTest', function()
  -- No tests yet
end)

if main_file() then
  unit.run_unit_tests()
end
