require 'llx'
require 'musictheory/util'
require 'musictheory/pitch'

Mode = class 'Mode' {
  __init = function(self, semitone_intervals)
    assert(isinstance(semitone_intervals, List))
    self.semitone_intervals = semitone_intervals
    self.semitone_indices = intervalsToIndices(semitone_intervals)

    local pitch_intervals = {}
    for i, v in ipairs(self.semitone_indices) do
      pitch_intervals[i] = PitchInterval{number=i - 1,
                                         semitone_interval=v}
    end
    self.pitch_intervals = Spiral(pitch_intervals)
  end,

  relative = function(self, mode)
    for i=1, #self.semitone_intervals do
      relativeIntervals = self.semitone_intervals >> i
      if relativeIntervals == mode.semitone_intervals then
        return i
      end
    end
    return nil
  end,

  __shr = function(self, n)
    return Mode(self.semitone_intervals >> n)
  end,

  __shl = function(self, n)
    return Mode(self.semitone_intervals << n)
  end,

  __eq = function(self, other)
    return self.semitone_intervals == other.semitone_intervals
  end,

  __index = function(self, index)
    if type(index) == 'number' then
      if index < 0 then
        index = #self + index
      end
      return rawget(self, 'pitch_intervals')[index]
    elseif type(index) == 'table' then
      local results = List{}
      for i, v in ipairs(index) do
        results[i] = self[v]
      end
      return results
    else
      return Mode.__defaultindex(self, index)
    end
  end,

  __len = function(self)
    return #self.semitone_intervals
  end,

  -- __repr = function(self)
  --   return string.format('Mode(%s, %s)',
  --                        self.semitone_intervals,
  --                        self.name and ("'" + self.name + "'") or 'nil')
  -- end,
}

diatonic_intervals = List{
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.half,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.half,
}

diatonic_modes_names = List{
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
  Mode[name] = Mode(diatonic_intervals >> (i - 1))
end

Mode.major = Mode.ionian
Mode.minor = Mode.aeolian

whole_tone = List{
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
  PitchInterval.whole,
}

chromatic = List{
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
}
