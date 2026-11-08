-- Loads musica.generation against the installed llx, without Z3.
-- Usage: lua tests/test_generator_load.lua
--
-- test_generator and test_rules need the native Z3 binding, which CI does
-- not install, so they are excluded there. This file stands in for them
-- on the one thing that needs no solver: that the generation modules'
-- class definitions evaluate. z3 is only called once a solve runs, so a
-- placeholder module is enough to load them.

local function placeholder()
  return setmetatable({}, {__index = function()
    return function() end
  end})
end
package.preload['z3'] = placeholder

local unit = require 'llx.unit'

local generator_module = require 'musica.generation.generator'

local _ENV = unit.create_test_env(_ENV)

describe('musica.generation.generator', function()
  it('should load against the installed llx', function()
    expect(generator_module.Generator).to_not.be_nil()
  end)

  it('should define generate_all as a decorated method', function()
    expect(type(generator_module.Generator.generate_all))
      .to.be_equal_to('function')
  end)
end)

run_unit_tests()
