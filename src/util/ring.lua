-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Circular sequence with modular indexing.
-- A Ring wraps a non-empty sequence so that any integer index maps
-- onto it modulo its length. Indexing is zero-based: ring[0] is the
-- first value, ring[#ring] wraps back to it, and negative indices
-- count backward from the end. Useful for cyclic musical structures
-- such as pitch classes and scale degrees.
-- @module musica.ring

local llx = require 'llx'
local util = require 'musica.util'

local _ENV, _M = llx.environment.create_module_environment()

local multi_index = util.multi_index

--- A fixed sequence indexed modulo its length.
-- Integer indices (including zero and negatives) wrap around the
-- sequence, so every integer resolves to one of the stored values.
-- Indexing with a table of integers returns a List of the
-- corresponding values.
-- @type Ring
Ring = llx.class 'Ring' {
  --- Creates a new Ring.
  -- @function Ring:__init
  -- @tparam Ring self
  -- @tparam table args Non-empty sequence of values to cycle over
  -- @usage
  -- local ring = Ring{3, 6, 9}
  -- ring[0]   -- 3 (indexing is zero-based)
  -- ring[3]   -- 3 (wraps around)
  -- ring[-1]  -- 9 (negative indices count backward)
  __init = function(self, args)
    assert(#args > 0, 'Ring requires a non-empty sequence')
    self._values = args
  end,

  --- Returns the number of values in one cycle of the ring.
  -- @function Ring:__len
  -- @tparam Ring self
  -- @treturn number Length of the underlying sequence
  __len = function(self)
    return #self._values
  end,

  --- Checks equality of two rings.
  -- Rings are equal if they have the same length and equal values
  -- at every position.
  -- @function Ring:__eq
  -- @tparam Ring self
  -- @tparam Ring other Another Ring
  -- @treturn boolean true if equal
  __eq = function(self, other)
    local a, b = self._values, other._values
    if #a ~= #b then return false end
    for i = 1, #a do
      if a[i] ~= b[i] then return false end
    end
    return true
  end,

  --- Returns a string representation of the ring.
  -- @return String like "Ring{3, 6, 9}"
  __tostring = function(self)
    local strs = {}
    for i, v in ipairs(self._values) do
      strs[i] = tostring(v)
    end
    return "Ring{" .. table.concat(strs, ', ') .. '}'
  end,

  --- Indexes the ring with wraparound.
  -- Integer keys map onto the sequence modulo its length
  -- (zero-based); a table of integers returns a List of lookups;
  -- other keys fall back to normal class access.
  -- @function Ring:__index
  -- @tparam Ring self
  -- @tparam number|table key Integer index or table of indices
  -- @return The value at the wrapped index, or a List of values
  __index = multi_index(function(self, key)
    local values = self._values
    local length = #values
    key = (key % length) + #self
    key = (key % length) + 1
    return values[key]
  end),

  --- Returns the first count values, cycling as needed.
  -- Starts from the first stored value and repeats the sequence
  -- until count values have been collected.
  -- @function Ring:take
  -- @tparam Ring self
  -- @tparam number count How many values to return
  -- @treturn table Sequence of count values
  -- @usage
  -- Ring{3, 6, 9}:take(5)  -- {3, 6, 9, 3, 6}
  take = function(self, count)
    local result = {}
    local values = self._values
    local length = #values
    for i = 1, count do
      result[i] = values[((i - 1) % length) + 1]
    end
    return result
  end,
}

return _M
