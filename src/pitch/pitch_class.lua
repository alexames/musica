-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'

local class, environment = llx { 'class', 'environment' }

local _ENV, _M = llx.environment.create_module_environment()

PitchClass = class 'PitchClass' {
  __init = function(self, args)
    self.name = args.name
    self.index = args.index
  end,

  __eq = function(self, other)
    return self.index == other.index
  end,

  __lt = function(self, other)
    return self.index < other.index
  end,

  __le = function(self, other)
    return self.index <= other.index
  end,

  __tostring = function(self)
    local fmt = 'PitchClass.%s'
    return fmt:format(self.name)
  end,
}

PitchClass.C = PitchClass{name='C', index=1}
PitchClass.D = PitchClass{name='D', index=2}
PitchClass.E = PitchClass{name='E', index=3}
PitchClass.F = PitchClass{name='F', index=4}
PitchClass.G = PitchClass{name='G', index=5}
PitchClass.A = PitchClass{name='A', index=6}
PitchClass.B = PitchClass{name='B', index=7}
PitchClass[1] = PitchClass.C
PitchClass[2] = PitchClass.D
PitchClass[3] = PitchClass.E
PitchClass[4] = PitchClass.F
PitchClass[5] = PitchClass.G
PitchClass[6] = PitchClass.A
PitchClass[7] = PitchClass.B

return _M
