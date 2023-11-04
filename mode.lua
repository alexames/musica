require 'llx'
require 'musictheory/util'
require 'musictheory/pitch'

Mode = class 'Mode' {
  __init = function(self, semitone_intervals, name)
    self.semitone_intervals = semitone_intervals
    self.semitone_indices = intervalsToIndices(semitone_intervals)

    self.pitchIntervals = Spiral(List.generate{
      lambda=function(number, semitone_interval)
        return PitchInterval{number=number,
                             semitone_interval=semitone_interval}
      end,
      list=self.semitone_indices,
      filter=function(n) return n % 2 == 0 end
    })
    self.pitchIntervals = Spiral()
    self.octaveInterval = self.pitchIntervals.extensionInterval

    if name then
      self.name = name
    else
      mode = diatonic_modes.get(self.semitone_intervals, nil)
      self.name = mode and mode.name
    end
  end,

  relative = function(self, mode)
    for i in range(#self.semitone_intervals) do
      relativeIntervals = rotate(self.semitone_intervals, i)
      if relativeIntervals == mode.semitone_intervals then
        return i
      end
    end
    return nil
  end,

  rotate = function(self, rotation)
    return Mode(rotate(self.semitone_intervals, rotation))
  end,

  __eq = function(self, other)
    return self.semitone_intervals == other.semitone_intervals
  end,

  __index = function(self, key)
    return self.pitchIntervals[key]
  end,

  __len = function(self)
    return #self.semitone_intervals
  end,

  -- __repr = function(self)
  --   return string.format("Mode(%s, %s)",
  --                        self.semitone_intervals,
  --                        self.name and ("'" + self.name + "'") or 'nil')
  -- end,
}

local function generate_modes(modes, intervals, globalNames)
  -- if globalNames then
  --   assert(#globalNames == #intervals)
  -- end
  -- local x = range(10)
  -- for i in range(#intervals) do
  --   name = globalNames[i]
  --   newIntervals = rotate(intervals, i)
  --   mode = Mode(newIntervals, name)
  --   modes[newIntervals] = mode
  --   setattr(Mode, name, mode)
  -- end
end


diatonicIntervals = List{PitchInterval.whole,
                         PitchInterval.whole,
                         PitchInterval.half,
                         PitchInterval.whole,
                         PitchInterval.whole,
                         PitchInterval.whole,
                         PitchInterval.half}

diatonic_modes_names = List{
  "ionian",
  "dorian",
  "phrygian",
  "lydian",
  "mixolydian",
  "aeolian",
  "locrian",
}

diatonic_modes = {}
generate_modes(diatonic_modes, diatonicIntervals, diatonic_modes_names)
Mode.major = Mode.ionian
Mode.minor = Mode.aeolian

whole_tone = List{PitchInterval.whole,
                  PitchInterval.whole,
                  PitchInterval.whole,
                  PitchInterval.whole,
                  PitchInterval.whole,
                  PitchInterval.whole}

chromatic = List{PitchInterval.half,
                 PitchInterval.half,
                 PitchInterval.half,
                 PitchInterval.half,
                 PitchInterval.half,
                 PitchInterval.half,
                 PitchInterval.half,
                 PitchInterval.half,
                 PitchInterval.half,
                 PitchInterval.half,
                 PitchInterval.half}

