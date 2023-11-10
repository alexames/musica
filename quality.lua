require 'llx'
require 'musictheory/util'
require 'musictheory/pitch'

Quality = class 'Quality' {
  __init = function(self, pitch_intervals, pitches, name)
    self.name = name
    if pitch_intervals and pitch_intervals[0] ~= PitchInterval.unison then
      -- pitch_intervals = [interval - pitch_intervals[0]
      --                   for interval in pitch_intervals]
    elseif pitches then
      pitches = sorted(pitches)
      -- pitch_intervals = [pitch - pitches[0]
      --                   for pitch in pitches]
    end
    self.pitch_intervals = pitch_intervals
  end;

  __getitem = function(self, key)
    return self.pitch_intervals[key]
  end;

  __eq = function(self, other)
    return self.pitch_intervals == other.pitch_intervals
  end;

  __len = function(self)
    return #self.pitch_intervals
  end;

  __repr = function(self)
    if self == Quality.major then
      return "Quality.major"
    elseif self == Quality.minor then
      return "Quality.minor"
    elseif self == Quality.augmented then
      return "Quality.augmented"
    elseif self == Quality.diminished then
      return "Quality.diminished"
    end
    return "Quality(pitch_intervals=%s)" % (self.pitch_intervals)
  end;
}

Quality.major = Quality{pitch_intervals={PitchInterval.unison, PitchInterval.major_third, PitchInterval.perfect_fifth}}
Quality.minor = Quality{pitch_intervals={PitchInterval.unison, PitchInterval.minor_third, PitchInterval.perfect_fifth}}
Quality.augmented = Quality{pitch_intervals={PitchInterval.unison, PitchInterval.major_third, PitchInterval.augmented_fifth}}
Quality.diminished = Quality{pitch_intervals={PitchInterval.unison, PitchInterval.minor_third, PitchInterval.diminished_fifth}}
