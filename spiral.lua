-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local multi_index = util.multi_index

Spiral = class 'Spiral' {
  __init = function(self, args)
    self._values = args
  end,

  __len = function(self)
    return #self._values - 1
  end,

  __eq = function(self, other)
    local a, b = self._values, other._values
    if #a ~= #b then return false end
    for i = 1, #a do
      if a[i] ~= b[i] then return false end
    end
    return true
  end,

  __index = multi_index(function(self, key)
    local values = rawget(self, '_values')
    local length = #values
    local multiplicative_operand = values[length]
    local modulus = length - 1
    local coefficient = key // modulus
    key = (key % modulus) + #self
    key = (key % modulus) + 1
    return values[key] + coefficient * multiplicative_operand
  end),

  __tostring = function(self)
    local strs = {}
    for i, v in ipairs(self._values) do
      strs[i] = tostring(v)
    end
    return "Spiral{".. table.concat(strs, ', ') .. '}'
  end,
}

return _M
