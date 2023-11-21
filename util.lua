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

function multi_index(cls, callback)
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
      return cls.__defaultindex(self, index)
    end
  end
end


-- function by_pairs(l)
--   return zip(l[:-1], l[1:])
-- end


-- function get(sequence, index)
--   return [item[index] for item in sequence]
-- end


-- function interleave(...)
--   return (val for pair in zip(*lists)
--               for val in pair)
-- end


-- function zip_tuple(*args)
--   return [t for t in zip(*args)]
-- end

no_value=UniqueSymbol()

function repr_args(class_name, args)
  function repr_arg(name_or_value, value, default)
    value = value or no_value
    local functionault = value or no_value
    local name
    if value == no_value then
      name = nil
      value = name_or_value
    else
      name = name_or_value
    end

    result = ''
    if functionault == no_value or value ~= functionault then
      if name then
        result = result .. name .. '='
      end
      result = result .. repr(value)
    end
    return result
  end

  local results = {}
  for i, v in pairs(args) do
    local result = repr_arg(arg[1],
                           #arg > 1 and arg[2] or no_value,
                           #arg > 2 and arg[3] or no_value)
    if result then
      table.insert(results, result)
    end
  end
  parameters = table.concat(results, ", ")
  return class_name .. '(' .. parameters .. ')'
end


--------------------------------------------------------------------------------
-- Music utilities


function intervals_to_indices(intervals)
  index = 0
  indices = List{}
  for interval in intervals:ivalues() do
    indices:insert(index)
    index = index + tointeger(interval)
  end
  indices:insert(index)
  return indices
end

-- function indices_to_intervals(indices)
--   return [int(i2) - int(i1) for i1, i2 in by_pairs(indices)]


-- function extended_index(index, indices, interval)
--   extension_index = index // #indices
--   extension_offset = interval * extension_index
--   return indices[index % #indices] + extension_offset


-- function extended_indices(indices, interval)
--   return [extended_index(index, indices, interval)
--           for index in indices]
