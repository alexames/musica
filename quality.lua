require 'llx'
require 'musictheory/util'
require 'musictheory/pitch'

Quality = class 'Quality' {
  __init = function(self, pitchIntervals, pitches, name)
    self.name = name
    if pitchIntervals and pitchIntervals[0] ~= PitchInterval.unison then
      -- pitchIntervals = [interval - pitchIntervals[0]
      --                   for interval in pitchIntervals]
    elseif pitches then
      pitches = sorted(pitches)
      -- pitchIntervals = [pitch - pitches[0]
      --                   for pitch in pitches]
    end
    self.pitchIntervals = pitchIntervals
  end;

  __getitem = function(self, key)
    return self.pitchIntervals[key]
  end;

  __eq = function(self, other)
    return self.pitchIntervals == other.pitchIntervals
  end;

  __len = function(self)
    return #self.pitchIntervals
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
    return "Quality(pitchIntervals=%s)" % (self.pitchIntervals)
  end;
}

Quality.major = Quality{pitchIntervals={PitchInterval.unison, PitchInterval.majorThird, PitchInterval.perfectFifth}}
Quality.minor = Quality{pitchIntervals={PitchInterval.unison, PitchInterval.minorThird, PitchInterval.perfectFifth}}
Quality.augmented = Quality{pitchIntervals={PitchInterval.unison, PitchInterval.majorThird, PitchInterval.augmentedFifth}}
Quality.diminished = Quality{pitchIntervals={PitchInterval.unison, PitchInterval.minorThird, PitchInterval.diminishedFifth}}
