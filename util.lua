-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Non-music utilities.
-- Provides general utility functions and classes used throughout musica.
-- @module musica.util

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local isinstance = llx.isinstance
local List = llx.List
local tointeger = llx.tointeger

--- A unique symbol for testing equality.
-- For when you want a symbol that is unique, but whose value has no meaning.
-- @type UniqueSymbol
UniqueSymbol = class 'UniqueSymbol' {
  __init = function(self, repr_str)
    self.repr_str = repr_str
  end,

  __repr = function(self)
    return self.repr_str
  end,
}

--- Creates a multi-index function for class indexing.
-- @param callback The callback to invoke for numeric indices
-- @return The multi-index function
function multi_index(callback)
  return function(self, index)
    if isinstance(index, llx.Number) then
      return callback(self, index)
    elseif isinstance(index, llx.Table) then
      local results = List{}
      for i, v in ipairs(index) do
        results[i] = self[v]
      end
      return results
    else
      local __defaultindex = llx.getmetafield(self, '__defaultindex')
      return __defaultindex(self, index)
    end
  end
end

--- Converts a list of intervals to cumulative indices.
-- @param intervals List of interval values
-- @return List of cumulative indices
function intervals_to_indices(intervals)
  local index = 0
  local indices = List{}
  for i, interval in ipairs(intervals) do
    indices:insert(index)
    index = index + tointeger(interval)
  end
  indices:insert(index)
  return indices
end

--- Gets an extended index that wraps around with interval offset.
-- @param index The index to look up
-- @param indices The list of base indices
-- @param interval The interval to add for each wrap
-- @return The extended index value
function extended_index(index, indices, interval)
  local extension_index = index // #indices
  local extension_offset = interval * extension_index
  return indices[index % #indices + 1] + extension_offset
end

return _M
