local unit = require 'unit'
require 'llx'
require 'musica.song'

test_class 'SongTest' {
}

if main_file() then
  unit.run_unit_tests()
end
