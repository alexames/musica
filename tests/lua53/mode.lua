-- Copyright 2026 Alexander Ames <Alexander.Ames@gmail.com>
--
-- The Mode tests that spell rotation with the Lua 5.3 shift operators,
-- which no earlier Lua can parse. tests/init.lua loads this file only on
-- Lua 5.3 and later.

local unit = require 'llx.unit'
local mode_module = require 'musica.mode'
require 'musica.modes'

local Mode = mode_module.Mode

_ENV = unit.create_test_env(_ENV)

describe('ModeTest (Lua 5.3+ operators)', function()
  it('should rotate left with <<', function()
    expect(Mode.major << 5).to.be_equal_to(Mode.major:rotate_left(5))
  end)

  it('should rotate right with >>', function()
    expect(Mode.major >> 2).to.be_equal_to(Mode.major:rotate_right(2))
  end)
end)
