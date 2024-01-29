--                                                              Tested | Docs
-----------------------------------------------------------------------+-----
local submodules = {
  accidental =       require 'musictheory/accidental',       -- No     | No
  articulation =     require 'musictheory/articulation',     -- No     | No
  beat =             require 'musictheory/beat',             -- No     | No
  channel =          require 'musictheory/channel',          -- No     | No
  chord =            require 'musictheory/chord',            -- Yes    | No
  contour =          require 'musictheory/contour',          -- No     | No
  direction =        require 'musictheory/direction',        -- No     | No
  dynamics =         require 'musictheory/dynamics',         -- No     | No
  figure =           require 'musictheory/figure',           -- Yes    | No
  instrument =       require 'musictheory/instrument',       -- No     | No
  interval_quality = require 'musictheory/interval_quality', -- No     | No
  meter =            require 'musictheory/meter',            -- No     | No
  mode =             require 'musictheory/mode',             -- Yes    | No
  modes =            require 'musictheory/modes',            -- No     | No
  note =             require 'musictheory/note',             -- Yes    | No
  pattern =          require 'musictheory/pattern',          -- No     | No
  pitch =            require 'musictheory/pitch',            -- Yes    | No
  pitch_class =      require 'musictheory/pitch_class',      -- No     | No
  pitch_interval =   require 'musictheory/pitch_interval',   -- Yes    | No
  quality =          require 'musictheory/quality',          -- Yes    | No
  rhythm =           require 'musictheory/rhythm',           -- No     | No
  ring =             require 'musictheory/ring',             -- No     | No
  scale =            require 'musictheory/scale',            -- Yes    | No
  scale_degree =     require 'musictheory/scale_degree',     -- No     | No
  scale_index =      require 'musictheory/scale_index',      -- No     | No
  song =             require 'musictheory/song',             -- No     | No
  spiral =           require 'musictheory/spiral',           -- No     | No
  tempo =            require 'musictheory/tempo',            -- No     | No
  util =             require 'musictheory/util',             -- No     | No
}

local module = {}
for submodule_name, submodule in pairs(submodules) do
  for key, value in pairs(submodule) do
    assert(module[k] == nil)
    module[key] = value
  end
end
return module