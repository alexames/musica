require 'llx'

local Pulse = class 'Pulse' {
  __init = function(self, duration)
    self.duration = duration or 1
  end
}

local StressedPulse = class 'StressedPulse' :extends(Pulse) {
  isStressed = function(self)
    return true
  end
}

local UnstressedPulse = class UnstressedPulse : extends(Pulse) {
  isStressed = function(self)
    return false
  end
}

-- The sequence of stressed and unstressed beats in a phrase.
local Meter = class 'Meter' {
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

local MeterProgression = class 'MeterProgression' {
  __init = function(self, periods)
    self.periods = periods
  end;

  duration = function(self)
    -- return sum(meter.duration() * measures
    --            for meter, measures in self.periods)
  end;
}


-- A sequence of durations and intensities.
local Rhythm = class 'Rhythm' {

}

local four_four = Meter(List{StressedPulse(),
                             UnstressedPulse(),
                             StressedPulse(),
                             UnstressedPulse()})

local common_meter = four_four

return {
  Pulse = Pulse,
  StressedPulse = StressedPulse,
  UnstressedPulse = UnstressedPulse,
  Meter = Meter,
  MeterProgression = MeterProgression,
  Rhythm = Rhythm,
  four_four = four_four,
  common_meter = common_meter
}