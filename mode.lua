require 'llx'
require 'musictheory/pitch'
require 'musictheory/util'

Mode = class 'Mode' {
  __init = function(self, semitone_intervals)
    check_arguments{self=Mode, semitone_intervals=List}
    self.semitone_intervals = semitone_intervals
    local pitch_intervals = {}
    for i, v in ipairs(intervals_to_indices(semitone_intervals)) do
      pitch_intervals[i] = PitchInterval{number=i - 1,
                                         semitone_interval=v}
    end
    self.pitch_intervals = Spiral(pitch_intervals)
  end,

  relative = function(self, mode)
    check_arguments{self=Mode, mode=Mode}
    for i=1, #self.semitone_intervals do
      local relative_intervals = self.semitone_intervals << i
      if relative_intervals == mode.semitone_intervals then
        return i
      end
    end
    return nil
  end,

  __shr = function(self, n)
    check_arguments{self=Mode, n=Integer}
    return Mode(self.semitone_intervals >> n)
  end,

  __shl = function(self, n)
    check_arguments{self=Mode, n=Integer}
    return Mode(self.semitone_intervals << n)
  end,

  __eq = function(self, other)
    check_arguments{self=Mode, other=Mode}
    return self.semitone_intervals == other.semitone_intervals
  end,

  __index = multi_index(Mode, function(self, index)
      if index < 0 then
        index = #self + index
      end
      return self.pitch_intervals[index]
    end),

  __len = function(self)
    check_arguments{self=Mode}
    return #self.semitone_intervals
  end,

  __tostring = function(self)
    check_arguments{self=Mode}
    return string.format('Mode(%s)',
                         self.semitone_intervals)
  end,
}
