require 'llx'
require 'musictheory/util'
require 'musictheory/pitch'

local Union = types.Union

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

  __index = function(self, index)
    check_arguments{self=Mode, index=Union{Number, Table, String}}
    if isinstance(index, Number) then
      if index < 0 then
        index = #self + index
      end
      return rawget(self, 'pitch_intervals')[index]
    elseif isinstance(index, Table) then
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
    check_arguments{self=Mode}
    return #self.semitone_intervals
  end,

  __tostring = function(self)
    check_arguments{self=Mode}
    return string.format('Mode(%s)',
                         self.semitone_intervals)
  end,
}
