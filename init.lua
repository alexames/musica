--                                                              Tested | Docs
-----------------------------------------------------------------------+-----
local submodules = {
  accidental =       require 'musictheory/accidental',
  articulation =     require 'musictheory/articulation',
  beat =             require 'musictheory/beat',
  channel =          require 'musictheory/channel',
  chord =            require 'musictheory/chord',            -- Yes    | No
  contour =          require 'musictheory/contour',          -- No     | No
  direction =        require 'musictheory/direction',
  dynamics =         require 'musictheory/dynamics',
  figure =           require 'musictheory/figure',           -- Yes    | No
  instrument =       require 'musictheory/instrument',
  interval_quality = require 'musictheory/interval_quality',
  meter =            require 'musictheory/meter',            -- No     | No
  mode =             require 'musictheory/mode',             -- Yes    | No
  modes =            require 'musictheory/modes',
  note =             require 'musictheory/note',             -- Yes    | No
  pattern =          require 'musictheory/pattern',
  pitch =            require 'musictheory/pitch',            -- Yes    | No
  pitch_class =      require 'musictheory/pitch_class',      -- No     | No
  pitch_interval =   require 'musictheory/pitch_interval',   -- Yes    | No
  quality =          require 'musictheory/quality',          -- Yes    | No
  rhythm =           require 'musictheory/rhythm',
  ring =             require 'musictheory/ring',             -- No     | No
  scale =            require 'musictheory/scale',            -- Yes    | No
  scale_degree =     require 'musictheory/scale_degree',
  scale_index =      require 'musictheory/scale_index',
  song =             require 'musictheory/song',             -- No     | No
  spiral =           require 'musictheory/spiral',           -- No     | No
  tempo =            require 'musictheory/tempo',
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