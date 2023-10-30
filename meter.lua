require 'llx'

Pulse = class 'Pulse' {
  __init = function(self, duration)
    self.duration = duration or 1
  end
}

StressedPulse = class 'StressedPulse' :extends(Pulse) {
  isStressed = function(self)
    return true
  end
}

UnstressedPulse = class UnstressedPulse : extends(Pulse) {
  isStressed = function(self)
    return false
  end
}

-- The sequence of stressed and unstressed beats in a phrase.
Meter = class 'Meter' {
  __init = function(self, pulses)
    self.pulseSequence = pulses
  end;

  duration = function(self)
    -- return sum(pulse.duration for pulse in self.pulseSequence)
  end;

  beats = function(self, numberOfBeats)
    return numberOfBeats
  end;

  pulses = function(self, numberOfPulses)
    error(NotImplementedError())
  end;

  measures = function(self, numberOfMeasures)
    return numberOfMeasures * self.duration()
  end;
}


class 'MeterProgression' {
  __init = function(self, periods)
    self.periods = periods
  end;

  duration = function(self)
    -- return sum(meter.duration() * measures
    --            for meter, measures in self.periods)
  end;
}


-- A sequence of durations and intensities.
class 'Rhythm' {

}

fourFour = Meter(List{StressedPulse(),
                  UnstressedPulse(),
                  StressedPulse(),
                  UnstressedPulse()})

commonMeter = fourFour