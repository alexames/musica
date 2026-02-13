-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local isinstance = llx.isinstance
local List = llx.List

Pulse = class 'Pulse' {
  __init = function(self, duration)
    self.duration = duration or 1
  end,

  __eq = function(self, other)
    return isinstance(other, Pulse)
           and not isinstance(other, StressedPulse)
           and not isinstance(other, UnstressedPulse)
           and self.duration == other.duration
  end,

  __tostring = function(self)
    return string.format('Pulse(%s)', self.duration)
  end,
}

StressedPulse = class 'StressedPulse' :extends(Pulse) {
  isStressed = function(self)
    return true
  end,

  __eq = function(self, other)
    return isinstance(other, StressedPulse)
           and self.duration == other.duration
  end,

  __tostring = function(self)
    return string.format('StressedPulse(%s)', self.duration)
  end,
}

UnstressedPulse = class 'UnstressedPulse' :extends(Pulse) {
  isStressed = function(self)
    return false
  end,

  __eq = function(self, other)
    return isinstance(other, UnstressedPulse)
           and self.duration == other.duration
  end,

  __tostring = function(self)
    return string.format('UnstressedPulse(%s)', self.duration)
  end,
}

-- The sequence of stressed and unstressed beats in a phrase.
Meter = class 'Meter' {
  __init = function(self, pulses)
    self.pulseSequence = pulses
  end,

  --- Returns the total duration of one measure in beats.
  duration = function(self)
    local total = 0
    for _, pulse in ipairs(self.pulseSequence) do
      total = total + pulse.duration
    end
    return total
  end,

  --- Returns the duration of a given number of beats.
  beats = function(self, numberOfBeats)
    return numberOfBeats
  end,

  --- Returns the duration of a given number of measures.
  measures = function(self, numberOfMeasures)
    return numberOfMeasures * self:duration()
  end,

  __eq = function(self, other)
    return self.pulseSequence == other.pulseSequence
  end,

  __len = function(self)
    return #self.pulseSequence
  end,

  __tostring = function(self)
    local strs = {}
    for i, pulse in ipairs(self.pulseSequence) do
      strs[i] = tostring(pulse)
    end
    return 'Meter{' .. table.concat(strs, ', ') .. '}'
  end,
}

MeterProgression = class 'MeterProgression' {
  __init = function(self, periods)
    self.periods = periods
  end,

  --- Returns the total duration of the meter progression.
  -- Each period is a {meter, numberOfMeasures} pair.
  duration = function(self)
    local total = 0
    for _, period in ipairs(self.periods) do
      local meter, measures = period[1], period[2]
      total = total + meter:duration() * measures
    end
    return total
  end,
}

four_four = Meter(List{StressedPulse(),
                       UnstressedPulse(),
                       StressedPulse(),
                       UnstressedPulse()})

common_meter = four_four

return _M
