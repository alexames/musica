require 'llx'
require 'musictheory/util'

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
      return Spiral.__defaultindex(self, key)
    end
  end,

  __tostring = function(self)
    return "Spiral{".. table.concat(self._values, ', ') .. '}'
  end,
}
