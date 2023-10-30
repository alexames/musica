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

function int(value)
  if type(value) == 'number' then
    return math.floor(value)
  else
    return value:__int()
  end
end


function tern(cond, trueValue, falseValue)
  if cond then return trueValue
  else return falseValue
  end
end


function rotate(l, n)
  -- print(valueToString(l))
  -- print(valueToString(n-1))
  -- print(valueToString(l(n-1)))
  -- print(valueToString(l(nil, n-1)))
  -- print(valueToString(getmetatable(l(n-1))))
  -- print(valueToString(getmetatable(l(nil, n-1))))

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

Ring = class 'Ring' {
  __init = function(self, ...)
    self.values = list(args)
  end,

  __index = function(self, key)
    return self.values[key % #self.values]

    -- if type(key) == 'number' then
    --   return self.values[key % #self.values]
    -- else
    --   return [self[index] for index in range(key.start, key.stop, key.step)]
    -- end
  end
}

Spiral = class 'Spiral' {
  __init = function(self, ...)
    self.extensionInterval = arg[#arg]
    self.modulus = #arg - 1
    self.values = {}
    for i=1, self.modulus do
      self.values[i-1] = arg[i]
    end
  end,

  __len = function(self)
    return self.modulus
  end,

  __index = function(self, key)
    local extensionOffset = math.floor(key / self.modulus)
    return self.values[key % self.modulus] + self.extensionInterval * extensionOffset
    -- if isinstance(key, int) then
    --   extensionOffset = key // #self
    --   return self.values[key % #self] + self.extensionInterval * extensionOffset
    -- else
    --   return [self[index] for index in range(key.start, key.stop, key.step)]
    -- end
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
    index = index + int(interval)
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
