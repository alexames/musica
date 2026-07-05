-- Smoke tests: every script in examples/ must run without errors, so the
-- examples in the repository can't rot as the API evolves.

local unit = require 'llx.unit'
local llx = require 'llx'

local main_file = llx.main_file

-- Locate the examples/ directory relative to this file, so the suite works
-- both from the repository root and from inside tests/.
local this_dir = arg and arg[0] and arg[0]:match('(.*[/\\])') or ''
local examples_dir = this_dir .. '../examples/'

_ENV = unit.create_test_env(_ENV)

describe('ExamplesTest', function()
  it('should run scales_and_chords.lua without errors', function()
    dofile(examples_dir .. 'scales_and_chords.lua')
  end)

  it('should run contours.lua without errors', function()
    dofile(examples_dir .. 'contours.lua')
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
