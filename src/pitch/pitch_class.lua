-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Pitch class representation for musical note letters.
-- A PitchClass represents one of the seven letter names (C, D, E, F,
-- G, A, B) without octave or accidental information. The seven
-- instances are predefined and can be looked up by name
-- (PitchClass.C) or by index (PitchClass[1]).
-- @module musica.pitch_class

local llx = require 'llx'

local class, environment = llx { 'class', 'environment' }

local _ENV, _M = llx.environment.create_module_environment()

--- Represents a musical pitch letter name (C-B).
-- A PitchClass pairs a letter name with a 1-based index (C=1 through
-- B=7). Pitch classes are ordered by index and support the relational
-- operators. Prefer the predefined constants over new instances.
-- @type PitchClass
PitchClass = class 'PitchClass' {
  --- Creates a new PitchClass.
  -- Prefer the predefined constants (PitchClass.C through
  -- PitchClass.B) over constructing new instances.
  -- @function PitchClass:__init
  -- @tparam PitchClass self
  -- @tparam table args Table with construction parameters
  -- @tparam string args.name Letter name ('C' through 'B')
  -- @tparam number args.index 1-based index (C=1 through B=7)
  -- @usage
  -- local c = PitchClass.C   -- lookup by name
  -- local d = PitchClass[2]  -- lookup by index
  __init = function(self, args)
    self.name = args.name
    self.index = args.index
  end,

  --- Checks equality of two pitch classes.
  -- Pitch classes are equal if they have the same index.
  -- @function PitchClass:__eq
  -- @tparam PitchClass self
  -- @tparam PitchClass other Another PitchClass
  -- @treturn boolean true if equal
  __eq = function(self, other)
    return self.index == other.index
  end,

  --- Less-than comparison.
  -- Ordered by index (C=1 through B=7).
  -- @function PitchClass:__lt
  -- @tparam PitchClass self
  -- @tparam PitchClass other Another PitchClass
  -- @treturn boolean true if self orders before other
  __lt = function(self, other)
    return self.index < other.index
  end,

  --- Less-than-or-equal comparison.
  -- @function PitchClass:__le
  -- @tparam PitchClass self
  -- @tparam PitchClass other Another PitchClass
  -- @treturn boolean true if self orders before or equals other
  __le = function(self, other)
    return self.index <= other.index
  end,

  --- Returns a string representation of the pitch class.
  -- @return String like "PitchClass.C"
  __tostring = function(self)
    local fmt = 'PitchClass.%s'
    return fmt:format(self.name)
  end,
}

-- The seven named pitch classes, indexable by name (PitchClass.C)
-- and by 1-based index (PitchClass[1]).
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
