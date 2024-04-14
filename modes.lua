local llx = require 'llx'
local mode = require 'musictheory/mode'
local pitch_interval = require 'musictheory/pitch_interval'

local PitchInterval = pitch_interval.PitchInterval
local Mode = mode.Mode

local diatonic_intervals = llx.List{
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.half,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.half,
}

local diatonic_modes_names = llx.List{
  'ionian',
  'dorian',
  'phrygian',
  'lydian',
  'mixolydian',
  'aeolian',
  'locrian',
}

assert(#diatonic_modes_names == #diatonic_intervals)
for i, name in ipairs(diatonic_modes_names) do
  Mode[name] = Mode(diatonic_intervals << (i - 1))
end

Mode.major = Mode.ionian
Mode.minor = Mode.aeolian

Mode.whole_tone = Mode(llx.List{
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
})

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

return {}