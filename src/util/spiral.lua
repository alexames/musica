-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Repeating sequence that offsets each cycle.
-- A Spiral is like a Ring, except each complete cycle adds a
-- multiplicative operand to the base values: indexing past the end
-- returns the base values offset by (cycles * operand). Indexing is
-- zero-based, and negative indices subtract the operand per cycle.
-- Models structures such as scales, where each octave repeats the
-- same pattern one octave higher.
-- @module musica.spiral

local llx = require 'llx'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local multi_index = util.multi_index

--- A cyclic sequence whose values shift by an operand per cycle.
-- The stored sequence holds the base values followed by the
-- multiplicative operand. Integer indices wrap around the base
-- values (zero-based), adding the operand once per completed cycle.
-- Indexing with a table of integers returns a List of the
-- corresponding values.
-- @type Spiral
Spiral = class 'Spiral' {
  --- Creates a new Spiral.
  -- The last element of args is the multiplicative operand added
  -- once per complete cycle; the preceding elements are the base
  -- values.
  -- @function Spiral:__init
  -- @tparam Spiral self
  -- @tparam table args Base values followed by the multiplicative
  -- operand (at least two elements)
  -- @usage
  -- local spiral = Spiral{0, 3, 5}  -- bases {0, 3}, operand 5
  -- spiral[0]   -- 0
  -- spiral[1]   -- 3
  -- spiral[2]   -- 5 (0 + 5, second cycle)
  -- spiral[-1]  -- -2 (3 - 5, previous cycle)
  __init = function(self, args)
    assert(
      #args > 1,
      'Spiral requires at least two values'
        .. ' (base values and a multiplicative operand)'
    )
    self._values = args
  end,

  --- Returns the number of base values in one cycle.
  -- Excludes the multiplicative operand.
  -- @function Spiral:__len
  -- @tparam Spiral self
  -- @treturn number Count of base values
  __len = function(self)
    return #self._values - 1
  end,

  --- Checks equality of two spirals.
  -- Spirals are equal if their base values and multiplicative
  -- operands all match.
  -- @function Spiral:__eq
  -- @tparam Spiral self
  -- @tparam Spiral other Another Spiral
  -- @treturn boolean true if equal
  __eq = function(self, other)
    local a, b = self._values, other._values
    if #a ~= #b then return false end
    for i = 1, #a do
      if a[i] ~= b[i] then return false end
    end
    return true
  end,

  --- Indexes the spiral with wraparound and per-cycle offset.
  -- Integer keys map onto the base values modulo the cycle length
  -- (zero-based), plus the operand times the number of completed
  -- cycles; a table of integers returns a List of lookups; other
  -- keys fall back to normal class access.
  -- @function Spiral:__index
  -- @tparam Spiral self
  -- @tparam number|table key Integer index or table of indices
  -- @return The offset value at the wrapped index, or a List
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

  --- Returns a string representation of the spiral.
  -- Includes the base values and the trailing operand.
  -- @return String like "Spiral{0, 3, 5}"
  __tostring = function(self)
    local strs = {}
    for i, v in ipairs(self._values) do
      strs[i] = tostring(v)
    end
    return "Spiral{".. table.concat(strs, ', ') .. '}'
  end,
}

return _M
