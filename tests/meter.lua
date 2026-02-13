local unit = require 'llx.unit'
local llx = require 'llx'
local meter_module = require 'musica.meter'

local Meter = meter_module.Meter
local Pulse = meter_module.Pulse
local StressedPulse = meter_module.StressedPulse
local UnstressedPulse = meter_module.UnstressedPulse
local MeterProgression = meter_module.MeterProgression
local List = llx.List
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

describe('PulseTest', function()
  it('should default duration to 1', function()
    expect(Pulse().duration).to.be_equal_to(1)
  end)

  it('should set custom duration', function()
    expect(Pulse(2).duration).to.be_equal_to(2)
  end)

  it('should be equal to pulse with same duration', function()
    expect(Pulse(1) == Pulse(1)).to.be_truthy()
  end)

  it('should not be equal to pulse with different '
    .. 'duration', function()
    expect(Pulse(1) == Pulse(2)).to.be_falsy()
  end)

  it('should not be equal to stressed pulse with '
    .. 'same duration', function()
    expect(Pulse(1) == StressedPulse(1)).to.be_falsy()
  end)

  it('should not be equal to unstressed pulse with '
    .. 'same duration', function()
    expect(Pulse(1) == UnstressedPulse(1)).to.be_falsy()
  end)

  it('should convert to string', function()
    expect(tostring(Pulse(1))).to.be_equal_to('Pulse(1)')
  end)
end)

describe('StressedPulseTest', function()
  it('should return true for isStressed', function()
    expect(StressedPulse():isStressed()).to.be_truthy()
  end)

  it('should be equal to stressed pulse with '
    .. 'same duration', function()
    expect(
      StressedPulse(1) == StressedPulse(1)
    ).to.be_truthy()
  end)

  it('should not be equal to stressed pulse with '
    .. 'different duration', function()
    expect(
      StressedPulse(1) == StressedPulse(2)
    ).to.be_falsy()
  end)

  it('should not be equal to unstressed pulse with '
    .. 'same duration', function()
    expect(
      StressedPulse(1) == UnstressedPulse(1)
    ).to.be_falsy()
  end)

  it('should convert to string', function()
    expect(tostring(StressedPulse(1)))
      .to.be_equal_to('StressedPulse(1)')
  end)
end)

describe('UnstressedPulseTest', function()
  it('should return false for isStressed', function()
    expect(UnstressedPulse():isStressed()).to.be_falsy()
  end)

  it('should be equal to unstressed pulse with '
    .. 'same duration', function()
    expect(
      UnstressedPulse(1) == UnstressedPulse(1)
    ).to.be_truthy()
  end)

  it('should not be equal to unstressed pulse with '
    .. 'different duration', function()
    expect(
      UnstressedPulse(1) == UnstressedPulse(2)
    ).to.be_falsy()
  end)

  it('should not be equal to stressed pulse with '
    .. 'same duration', function()
    expect(
      UnstressedPulse(1) == StressedPulse(1)
    ).to.be_falsy()
  end)

  it('should convert to string', function()
    expect(tostring(UnstressedPulse(1)))
      .to.be_equal_to('UnstressedPulse(1)')
  end)
end)

describe('MeterTest', function()
  it('should return duration of 4 for four_four', function()
    local m = Meter(List{StressedPulse(),
                         UnstressedPulse(),
                         StressedPulse(),
                         UnstressedPulse()})
    expect(m:duration()).to.be_equal_to(4)
  end)

  it('should return duration of 3 for waltz meter', function()
    local m = Meter(List{StressedPulse(),
                         UnstressedPulse(),
                         UnstressedPulse()})
    expect(m:duration()).to.be_equal_to(3)
  end)

  it('should return correct duration with '
    .. 'non-unit pulses', function()
    local m = Meter(List{StressedPulse(2),
                         UnstressedPulse(1)})
    expect(m:duration()).to.be_equal_to(3)
  end)

  it('should return number of beats unchanged', function()
    local m = Meter(List{StressedPulse(),
                         UnstressedPulse()})
    expect(m:beats(8)).to.be_equal_to(8)
  end)

  it('should return correct measures duration', function()
    local m = Meter(List{StressedPulse(),
                         UnstressedPulse(),
                         StressedPulse(),
                         UnstressedPulse()})
    expect(m:measures(3)).to.be_equal_to(12)
  end)

  it('should return length equal to number of '
    .. 'pulses', function()
    local m = Meter(List{StressedPulse(),
                         UnstressedPulse(),
                         StressedPulse(),
                         UnstressedPulse()})
    expect(#m).to.be_equal_to(4)
  end)

  it('should be equal to meter with same pulses', function()
    local m1 = Meter(List{StressedPulse(),
                          UnstressedPulse()})
    local m2 = Meter(List{StressedPulse(),
                          UnstressedPulse()})
    expect(m1 == m2).to.be_truthy()
  end)

  it('should not be equal to meter with '
    .. 'different pulses', function()
    local m1 = Meter(List{StressedPulse(),
                          UnstressedPulse()})
    local m2 = Meter(List{StressedPulse(),
                          StressedPulse()})
    expect(m1 == m2).to.be_falsy()
  end)

  it('should not be equal to meter with '
    .. 'different number of pulses', function()
    local m1 = Meter(List{StressedPulse(),
                          UnstressedPulse()})
    local m2 = Meter(List{StressedPulse(),
                          UnstressedPulse(),
                          UnstressedPulse()})
    expect(m1 == m2).to.be_falsy()
  end)

  it('should convert to string', function()
    local m = Meter(List{StressedPulse(),
                         UnstressedPulse()})
    expect(tostring(m)).to.be_equal_to(
      'Meter{StressedPulse(1), UnstressedPulse(1)}')
  end)
end)

describe('MeterProgressionTest', function()
  it('should return total duration for '
    .. 'progression', function()
    local m1 = Meter(List{StressedPulse(),
                          UnstressedPulse(),
                          StressedPulse(),
                          UnstressedPulse()})
    local m2 = Meter(List{StressedPulse(),
                          UnstressedPulse(),
                          UnstressedPulse()})
    local prog = MeterProgression(
      List{{m1, 4}, {m2, 2}})
    -- 4 measures of 4/4 (16) + 2 measures of 3/4 (6) = 22
    expect(prog:duration()).to.be_equal_to(22)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
