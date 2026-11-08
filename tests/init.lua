require 'musica.tests.articulation'
require 'musica.tests.chord'
require 'musica.tests.contour'
require 'musica.tests.dynamics'
require 'musica.tests.figure'
require 'musica.tests.meter'
require 'musica.tests.mode'
require 'musica.tests.note'
require 'musica.tests.pitch'
require 'musica.tests.pitch_class'
require 'musica.tests.pitch_interval'
require 'musica.tests.quality'
require 'musica.tests.rhythm'
require 'musica.tests.scale'
require 'musica.tests.song'
require 'musica.tests.tempo'
require 'musica.tests.time_signature'
require 'musica.tests.util'

local compat = require 'llx.compat'

-- Tests that need the Lua 5.3 integer operators, which no earlier Lua parses.
if compat.integer_bits == 64 then
  require 'musica.tests.lua53.mode'
end
