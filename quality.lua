require 'llx'
require 'musictheory/pitch'
require 'musictheory/pitch_interval'
require 'musictheory/util'

local QualityByPitches = Schema{
  __name='QualityByPitches',
  type=Table,
  properties={
    pitches={
      type=List,
      items={type=Pitch},
    },
    name={type=String},
  },
  required={'pitches'},
}

local QualityByPitchIntervals = Schema{
  __name='QualityByPitchIntervals',
  type=Table,
  properties={
    pitch_intervals={
      type=List,
      items={type=PitchInterval},
    },
    name={type=String},
  },
  required={'pitch_intervals'},
}

local QualityArgumentsSchema = Schema{
  __name='QualityArgumentsSchema',
  type=Union{QualityByPitches, QualityByPitchIntervals},
}

Quality = class 'Quality' {
  __init = function(self, args)
    check_arguments{self=Quality, args=QualityArgumentsSchema}
    self.name = args.name
    local pitch_intervals = args.pitch_intervals
    local pitches = args.pitches
    if pitch_intervals and pitch_intervals[1] ~= PitchInterval.unison then
      local first_interval = pitch_intervals[1]
      for i, interval in ipairs(pitch_intervals) do
        pitch_intervals[i] = interval - first_interval
      end
    elseif pitches then
      pitch_intervals = List{}
      pitches:sort()
      local first_pitch = pitches[1]
      for i, pitch in ipairs(pitches) do
        pitch_intervals[i] = pitch - first_pitch
      end
    end
    self.pitch_intervals = pitch_intervals
  end,

  __index = multi_index(Quality, function(self, index)
    return self.pitch_intervals[index]
  end),

  __eq = function(self, other)
    return self.pitch_intervals == other.pitch_intervals
  end;

  __len = function(self)
    return #self.pitch_intervals
  end;

  __tostring = function(self)
    if self == Quality.major then
      return "Quality.major"
    elseif self == Quality.minor then
      return "Quality.minor"
    elseif self == Quality.augmented then
      return "Quality.augmented"
    elseif self == Quality.diminished then
      return "Quality.diminished"
    end
    return string.format("Quality{pitch_intervals=%s}", self.pitch_intervals)
  end;
}

Quality.major = Quality{pitch_intervals=List{PitchInterval.unison, PitchInterval.major_third, PitchInterval.perfect_fifth}}
Quality.minor = Quality{pitch_intervals=List{PitchInterval.unison, PitchInterval.minor_third, PitchInterval.perfect_fifth}}
Quality.augmented = Quality{pitch_intervals=List{PitchInterval.unison, PitchInterval.major_third, PitchInterval.augmented_fifth}}
Quality.diminished = Quality{pitch_intervals=List{PitchInterval.unison, PitchInterval.minor_third, PitchInterval.diminished_fifth}}
