
--                                                                 Tested | Docs
--------------------------------------------------------------------------+-----
local chord =            require 'musictheory/chord'            -- No     | No
local contour =          require 'musictheory/contour'          -- No     | No
local figure =           require 'musictheory/figure'           -- No     | No
local interval_quality = require 'musictheory/interval_quality' -- No     | No
local meter =            require 'musictheory/meter'            -- No     | No
local mode =             require 'musictheory/mode'             -- No     | No
local note =             require 'musictheory/note'             -- No     | No
local pitch =            require 'musictheory/pitch'            -- No     | No
local pitch_interval =   require 'musictheory/pitch_interval'   -- No     | No
local quality =          require 'musictheory/quality'          -- No     | No
local scale =            require 'musictheory/scale'            -- No     | No
local scale_index =      require 'musictheory/scale_index'      -- No     | No
local song =             require 'musictheory/song'             -- No     | No
local util =             require 'musictheory/util'             -- No     | No

return {
  chord=chord,
  figure=figure,
  meter=meter,
  mode=mode,
  note=note,
  pitch=pitch,
  quality=quality,
  scale=scale,
  song=song,
  util=util,
}
