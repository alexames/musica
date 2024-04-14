-- Non-music utilities
local llx = require 'llx'
local List = require 'llx/types/list' . List
local tointeger = require 'llx/tointeger' . tointeger

local class = llx.class
local isinstance = llx.isinstance

-- For when I want a symbol that is unique, but whose value has no meaning.
-- Only used for testing equality.
UniqueSymbol = class 'UniqueSymbol' {
  __init = function(self, repr_str)
    self.repr_str = repr_str
  end,

  __repr = function(self)
    return self.repr_str
  end,
}

local function multi_index(callback)
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

local function ipairs0(t)
  local f, t, i = ipairs(t)
  return f, t, -1
end

-- function interleave(...)
--   return (val for pair in zip(*lists)
--               for val in pair)
-- end


-- function zip_tuple(*args)
--   return [t for t in zip(*args)]
-- end

--------------------------------------------------------------------------------
-- Music utilities


local function intervals_to_indices(intervals)
  local index = 0
  local indices = List{}
  for i, interval in ipairs(intervals) do
    indices:insert(index)
    index = index + tointeger(interval)
  end
  indices:insert(index)
  return indices
end

-- function indices_to_intervals(indices)
--   return [int(i2) - int(i1) for i1, i2 in by_pairs(indices)]


local function extended_index(index, indices, interval)
  local extension_index = index // #indices
  local extension_offset = interval * extension_index
  return indices[index % #indices + 1] + extension_offset
end

-- function extended_indices(indices, interval)
--   return [extended_index(index, indices, interval)
--           for index in indices]

return {
  UniqueSymbol = UniqueSymbol,
  multi_index = multi_index,
  ipairs0 = ipairs0,
  intervals_to_indices = intervals_to_indices,
  extended_index = extended_index,
}
