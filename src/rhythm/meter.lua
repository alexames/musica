-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Meter and pulse representation for rhythm.
-- A Meter is a sequence of stressed and unstressed pulses that
-- describes the beat pattern of one measure. A MeterProgression
-- chains meters across multiple measures.
-- @module musica.meter

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

local class = llx.class
local isinstance = llx.isinstance
local List = llx.List

--- A single beat of unspecified stress.
-- Base class for StressedPulse and UnstressedPulse.
-- @type Pulse
Pulse = class 'Pulse' {
  --- Creates a new Pulse.
  -- @function Pulse:__init
  -- @tparam Pulse self
  -- @tparam[opt=1] number duration Length of the pulse in beats
  __init = function(self, duration)
    self.duration = duration or 1
  end,

  --- Checks equality of two pulses.
  -- Equal only if other is a plain Pulse (not a stressed or
  -- unstressed subclass) with the same duration.
  -- @function Pulse:__eq
  -- @tparam Pulse self
  -- @tparam Pulse other Another Pulse
  -- @treturn boolean true if equal
  __eq = function(self, other)
    return isinstance(other, Pulse)
           and not isinstance(other, StressedPulse)
           and not isinstance(other, UnstressedPulse)
           and self.duration == other.duration
  end,

  --- Returns a string representation of the pulse.
  -- @return String like "Pulse(1)"
  __tostring = function(self)
    return string.format('Pulse(%s)', self.duration)
  end,
}

--- A pulse carrying metrical stress (a strong beat).
-- @type StressedPulse
StressedPulse = class 'StressedPulse' :extends(Pulse) {
  --- Reports whether this pulse is stressed.
  -- @return true
  isStressed = function(self)
    return true
  end,

  --- Checks equality of two stressed pulses.
  -- @function StressedPulse:__eq
  -- @tparam StressedPulse self
  -- @tparam StressedPulse other Another pulse
  -- @treturn boolean true if other is stressed with equal duration
  __eq = function(self, other)
    return isinstance(other, StressedPulse)
           and self.duration == other.duration
  end,

  --- Returns a string representation of the pulse.
  -- @return String like "StressedPulse(1)"
  __tostring = function(self)
    return string.format('StressedPulse(%s)', self.duration)
  end,
}

--- A pulse without metrical stress (a weak beat).
-- @type UnstressedPulse
UnstressedPulse = class 'UnstressedPulse' :extends(Pulse) {
  --- Reports whether this pulse is stressed.
  -- @return false
  isStressed = function(self)
    return false
  end,

  --- Checks equality of two unstressed pulses.
  -- @function UnstressedPulse:__eq
  -- @tparam UnstressedPulse self
  -- @tparam UnstressedPulse other Another pulse
  -- @treturn boolean true if other is unstressed with equal duration
  __eq = function(self, other)
    return isinstance(other, UnstressedPulse)
           and self.duration == other.duration
  end,

  --- Returns a string representation of the pulse.
  -- @return String like "UnstressedPulse(1)"
  __tostring = function(self)
    return string.format('UnstressedPulse(%s)', self.duration)
  end,
}

--- The sequence of stressed and unstressed beats in a phrase.
-- A Meter describes one measure's pulse pattern and converts beat
-- and measure counts into durations.
-- @type Meter
Meter = class 'Meter' {
  --- Creates a new Meter.
  -- @function Meter:__init
  -- @tparam Meter self
  -- @tparam List pulses List of Pulse objects, one per beat
  -- @usage
  -- local waltz = Meter(List{StressedPulse(),
  --                          UnstressedPulse(),
  --                          UnstressedPulse()})
  __init = function(self, pulses)
    self.pulseSequence = pulses
  end,

  --- Returns the total duration of one measure in beats.
  -- @return Sum of the durations of all pulses
  duration = function(self)
    local total = 0
    for _, pulse in ipairs(self.pulseSequence) do
      total = total + pulse.duration
    end
    return total
  end,

  --- Returns the duration of a given number of beats.
  -- @tparam number numberOfBeats Number of beats
  -- @return Duration in beats
  beats = function(self, numberOfBeats)
    return numberOfBeats
  end,

  --- Returns the duration of a given number of measures.
  -- @tparam number numberOfMeasures Number of measures
  -- @return Duration in beats
  measures = function(self, numberOfMeasures)
    return numberOfMeasures * self:duration()
  end,

  --- Checks equality of two meters.
  -- @function Meter:__eq
  -- @tparam Meter self
  -- @tparam Meter other Another Meter
  -- @treturn boolean true if the pulse sequences are equal
  __eq = function(self, other)
    return self.pulseSequence == other.pulseSequence
  end,

  --- Returns the number of pulses in the meter.
  -- @return Number of beats per measure
  __len = function(self)
    return #self.pulseSequence
  end,

  --- Returns a string representation of the meter.
  -- @return String like "Meter{StressedPulse(1), ...}"
  __tostring = function(self)
    local strs = {}
    for i, pulse in ipairs(self.pulseSequence) do
      strs[i] = tostring(pulse)
    end
    return 'Meter{' .. table.concat(strs, ', ') .. '}'
  end,
}

--- A sequence of meters spanning multiple measures.
-- @type MeterProgression
MeterProgression = class 'MeterProgression' {
  --- Creates a new MeterProgression.
  -- @function MeterProgression:__init
  -- @tparam MeterProgression self
  -- @tparam List periods List of {meter, numberOfMeasures} pairs
  __init = function(self, periods)
    self.periods = periods
  end,

  --- Returns the total duration of the meter progression.
  -- Each period is a {meter, numberOfMeasures} pair.
  -- @return Total duration in beats
  duration = function(self)
    local total = 0
    for _, period in ipairs(self.periods) do
      local meter, measures = period[1], period[2]
      total = total + meter:duration() * measures
    end
    return total
  end,
}

--- Four-four time: four beats alternating stressed and unstressed.
four_four = Meter(List{StressedPulse(),
                       UnstressedPulse(),
                       StressedPulse(),
                       UnstressedPulse()})

--- Common time: an alias for four_four.
common_meter = four_four

return _M
