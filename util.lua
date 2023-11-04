-- Non-music utilities
require 'llx'

-- For when I want a symbol that is unique, but whose value has no meaning.
-- Only used for testing equality.
UniqueSymbol = class 'UniqueSymbol' {
  __init = function(self, reprStr)
    self.reprStr = reprStr
  end,

  __repr = function(self)
    return self.reprStr
  end,
}

-- Directions
down = -1
level = 0
same = 0
up = 1

function tern(cond, trueValue, falseValue)
  if cond then return trueValue
  else return falseValue
  end
end

function rotate(l, n)
  return l(n-1) + l(nil,n-1)
end

-- function byPairs(l)
--   return zip(l[:-1], l[1:])
-- end


-- function get(sequence, index)
--   return [item[index] for item in sequence]
-- end


-- function interleave(...)
--   return (val for pair in zip(*lists)
--               for val in pair)
-- end


-- function zipTuple(*args)
--   return [t for t in zip(*args)]
-- end

noValue=UniqueSymbol()

function reprArgs(className, args)
  function reprArg(nameOrValue, value, default)
    value = value or noValue
    local functionault = value or noValue
    local name
    if value == noValue then
      name = nil
      value = nameOrValue
    else
      name = nameOrValue
    end

    result = ''
    if functionault == noValue or value ~= functionault then
      if name then
        result = result .. name .. '='
      end
      result = result .. repr(value)
    end
    return result
  end

  results = list.generate{
      lambda=function(arg)
        return reprArg(arg[1],
                       #arg > 1 and arg[2] or noValue,
                       #arg > 2 and arg[3] or noValue)
      end,
      list=args}
  parameters = table.concat(filter(function(result)
                                     return result ~= nil
                                   end, results),
                            ", ")
  return className .. '(' .. parameters .. ')'
end

-- rings and spirals are 0 based!
Ring = class 'Ring' {
  __init = function(self, args)
    self._values = args
  end,

  __index = function(self, key)
    if type(key) == 'number' then
      local values = rawget(self, '_values')
      local length = #values
      key = (key % length) + #self
      key = (key % length) + 1
      return values[key]
    elseif type(key) == 'table' then
      local results = List{}
      for i, v in pairs(key) do
        results[i] = self[v]
      end
      return results
    else
      return self.__defaultindex(self, key)
    end
  end
}

Spiral = class 'Spiral' {
  __init = function(self, args)
    self._values = args
  end,

  __index = function(self, key)
    if type(key) == 'number' then
      local values = rawget(self, '_values')
      local length = #values
      local multiplicitive_operand = values[length]
      local modulus = length - 1
      local coefficient = key // modulus

      key = (key % modulus) + #self
      key = (key % modulus) + 1
      return values[key] + coefficient * multiplicitive_operand
    elseif type(key) == 'table' then
      local results = List{}
      for i, v in pairs(key) do
        results[i] = self[v]
      end
      return results
    else
      return self.__defaultindex(self, key)
    end
  end,

  -- __repr = function(self)
  --   values = self.values + (self.extensionInterval,)
  --   return reprArgs("Spiral", [(value,) for value in values])
  -- end,
}

--------------------------------------------------------------------------------
-- Music utilities


function intervalsToIndices(intervals)
  index = 0
  indices = List{}
  for interval in intervals:ivalues() do
    indices:insert(index)
    index = index + tointeger(interval)
  end
  indices:insert(index)
  return indices
end

-- function indicesToIntervals(indices)
--   return [int(i2) - int(i1) for i1, i2 in byPairs(indices)]


-- function extendedIndex(index, indices, interval)
--   extensionIndex = index // #indices
--   extensionOffset = interval * extensionIndex
--   return indices[index % #indices] + extensionOffset


-- function extendedIndices(indices, interval)
--   return [extendedIndex(index, indices, interval)
--           for index in indices]
