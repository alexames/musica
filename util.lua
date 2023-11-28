-- Non-music utilities
require 'llx'

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

function multi_index(callback)
  return function(self, index)
    if isinstance(index, Number) then
      return callback(self, index)
    elseif isinstance(index, Table) then
      local results = List{}
      for i, v in ipairs(index) do
        results[i] = self[v]
      end
      return results
    else
      local __defaultindex = getmetafield(self, '__defaultindex')
      return __defaultindex(self, index)
    end
  end
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

-- function indices_to_intervals(indices)
--   return [int(i2) - int(i1) for i1, i2 in by_pairs(indices)]


function extended_index(index, indices, interval)
  local extension_index = index // #indices
  local extension_offset = interval * extension_index
  return indices[index % #indices + 1] + extension_offset
end

-- function extended_indices(indices, interval)
--   return [extended_index(index, indices, interval)
--           for index in indices]
