require 'llx'
require 'musictheory/mode'
require 'musictheory/pitch_interval'

local diatonic_intervals = List{
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.half,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.half,
}

local diatonic_modes_names = List{
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

Mode.whole_tone = Mode(List{
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
})

Mode.chromatic = Mode(List{
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
