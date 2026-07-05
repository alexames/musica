-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Dynamics: named volume levels.
-- A Dynamic is a named volume marking (piano, forte, and so on).
-- The dynamics table maps both long and short names to Dynamic
-- values, which may be used anywhere a note volume is expected.
-- @module musica.dynamics

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

--- Represents a dynamic marking.
-- Dynamics are ordered by volume, so they can be compared with the
-- < and <= operators.
-- @type Dynamic
Dynamic = llx.class 'Dynamic' {
  --- Creates a new Dynamic.
  -- @function Dynamic:__init
  -- @tparam Dynamic self
  -- @tparam string long_name Full name (e.g., 'piano')
  -- @tparam string short_name Abbreviation (e.g., 'p')
  -- @tparam number volume Volume level in [0, 1]
  __init = function(self, long_name, short_name, volume)
    self.long_name = long_name
    self.short_name = short_name
    self.volume = volume
  end,

  --- Checks equality of two dynamics.
  -- @function Dynamic:__eq
  -- @tparam Dynamic self
  -- @tparam Dynamic other Another Dynamic
  -- @treturn boolean true if names and volume are equal
  __eq = function(self, other)
    return self.long_name == other.long_name
           and self.short_name == other.short_name
           and self.volume == other.volume
  end,

  --- Less-than comparison.
  -- Ordered by volume, then long name, then short name.
  -- @function Dynamic:__lt
  -- @tparam Dynamic self
  -- @tparam Dynamic other Another Dynamic
  -- @treturn boolean true if self is quieter (or orders earlier)
  __lt = function(self, other)
    if self.volume ~= other.volume then
      return self.volume < other.volume
    end
    if self.long_name ~= other.long_name then
      return self.long_name < other.long_name
    end
    return self.short_name < other.short_name
  end,

  --- Less-than-or-equal comparison.
  -- @function Dynamic:__le
  -- @tparam Dynamic self
  -- @tparam Dynamic other Another Dynamic
  -- @treturn boolean true if self orders before or equals other
  __le = function(self, other)
    return self == other or self < other
  end,

  --- Returns a string representation of the dynamic.
  -- @return String like "Dynamic.mf"
  __tostring = function(self)
    return string.format('Dynamic.%s', self.short_name)
  end,
}

--- The standard dynamic markings, ordered from niente (silence)
-- to fortissississimo (maximum volume).
local dynamics_list = llx.List{
  -- Meaning "nothing". May be used at the start of a
  -- crescendo to indicate "start from nothing" or at the
  -- end of a diminuendo to indicate "fade out to nothing".
  Dynamic('niente', 'n', 0.0),
  -- Extremely soft. Softer dynamics occur very
  -- infrequently and would be specified with additional ps.
  Dynamic('pianissississimo', 'pppp', 0.1),
  -- Extremely soft. Softer dynamics occur very
  -- infrequently and would be specified with additional ps.
  Dynamic('pianississimo', 'ppp', 0.2),
  -- Very soft.
  Dynamic('pianissimo', 'pp', 0.3),
  -- Soft; louder than pianissimo.
  Dynamic('piano', 'p', 0.4),
  -- Moderately soft; louder than piano.
  Dynamic('mezzo_piano', 'mp', 0.5),
  -- Moderately loud; softer than forte. If no dynamic
  -- appears, mezzo-forte is assumed to be the prevailing
  -- dynamic level.
  Dynamic('mezzo_forte', 'mf', 0.6),
  -- Loud.
  Dynamic('forte', 'f', 0.7),
  -- Very loud.
  Dynamic('fortissimo', 'ff', 0.8),
  -- Extremely loud. Louder dynamics occur very
  -- infrequently and would be specified with additional fs.
  Dynamic('fortississimo', 'fff', 0.9),
  -- Extremely loud. Louder dynamics occur very
  -- infrequently and would be specified with additional fs.
  Dynamic('fortissississimo', 'ffff', 1.0),
}

--- Map of dynamic names to Dynamic values.
-- Indexed by both long name ('mezzo_forte') and short name ('mf').
-- @table dynamics
-- @usage
-- local n = Note{pitch=Pitch.c4, duration=1, volume=dynamics.mf}
dynamics = {}
for i, dynamic in dynamics_list do
  dynamics[dynamic.long_name] = dynamic
  dynamics[dynamic.short_name] = dynamic
end

return _M

-- -- Literally "forced", denotes an abrupt, fierce accent
-- -- on a single sound or chord. When written out in full,
-- -- it applies to the sequence of sounds or chords under
-- -- or over which it is placed. Sforzando is not to be
-- -- confused with rinforzando.
-- local sforzando = Dynamic('sforzando', 'sfz', )
-- -- Indicates that the note is to be played with a loud
-- -- attack, and then immediately become soft.
-- local fortepiano = Dynamic('fortepiano', 'fp', )

--   -- A gradual increase in volume.
--   -- Can be extended under many notes to indicate that
--   -- the volume steadily increases during the passage.
--   Crescendo
--   -- A gradual decrease in volume. Can be extended in
--   -- the same manner as crescendo.
--   Diminuendo
--   Decrescendo
