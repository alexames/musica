-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Named mode constants.
-- Populates the Mode class with the seven diatonic modes (ionian
-- through locrian), the major/minor aliases, and the whole tone and
-- chromatic modes. Requiring this module makes constants such as
-- Mode.major and Mode.dorian available.
-- @module musica.modes

local llx = require 'llx'
local mode = require 'musica.mode'
local pitch_interval = require 'musica.pitch_interval'

local _ENV, _M = llx.environment.create_module_environment()

local Mode = mode.Mode
local PitchInterval = pitch_interval.PitchInterval

--- The interval pattern of the diatonic (major) scale.
local diatonic_intervals = llx.List{
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.half,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.half,
}

--- Names of the seven diatonic modes, in rotation order.
local diatonic_modes_names = llx.List{
  'ionian',
  'dorian',
  'phrygian',
  'lydian',
  'mixolydian',
  'aeolian',
  'locrian',
}

-- Each diatonic mode is a rotation of the major scale's intervals.
assert(#diatonic_modes_names == #diatonic_intervals)
for i, name in ipairs(diatonic_modes_names) do
  Mode[name] = Mode(diatonic_intervals << (i - 1))
end

--- The major mode: an alias for Mode.ionian.
Mode.major = Mode.ionian
--- The natural minor mode: an alias for Mode.aeolian.
Mode.minor = Mode.aeolian

--- The whole tone mode: six whole steps per octave.
Mode.whole_tone = Mode(llx.List{
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
})

--- The chromatic mode: successive half steps.
Mode.chromatic = Mode(llx.List{
  PitchInterval.half,
  PitchInterval.half,
  PitchInterval.half,
  PitchInterval.half,
  PitchInterval.half,
  PitchInterval.half,
  PitchInterval.half,
  PitchInterval.half,
  PitchInterval.half,
  PitchInterval.half,
  PitchInterval.half,
})

return _M
