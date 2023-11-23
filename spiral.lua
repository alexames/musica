require 'llx'
require 'musictheory/util'

Spiral = class 'Spiral' {
  __init = function(self, args)
    self._values = args
  end,

  __index = multi_index(function(self, key)
    local values = rawget(self, '_values')
    local length = #values
    local multiplicitive_operand = values[length]
    local modulus = length - 1
    local coefficient = key // modulus
    key = (key % modulus) + #self
    key = (key % modulus) + 1
    return values[key] + coefficient * multiplicitive_operand
  end),

  __tostring = function(self)
    return "Spiral{".. table.concat(self._values, ', ') .. '}'
  end,
}
