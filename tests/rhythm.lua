local unit = require 'llx.unit'
local llx = require 'llx'
local rhythm_module = require 'musica.rhythm'

local Rhythm = rhythm_module.Rhythm
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

describe('RhythmTests', function()
  it('should create rhythm with specified durations', function()
    local rhythm = Rhythm{durations = {1, 0.5, 0.5, 1}}
    expect(#rhythm.durations).to.be_equal_to(4)
  end)

  it('should return length via __len', function()
    local rhythm = Rhythm{1, 0.5, 0.5, 1}
    expect(#rhythm).to.be_equal_to(4)
  end)

  it('should calculate total duration correctly', function()
    local rhythm = Rhythm{1, 0.5, 0.5, 1}
    expect(rhythm:total_duration()).to.be_equal_to(3.0)
  end)

  it('should augment first duration by factor', function()
    local rhythm = Rhythm{1, 0.5}
    local augmented = rhythm:augment(2)
    expect(augmented.durations[1]).to.be_equal_to(2.0)
  end)

  it('should augment second duration by factor', function()
    local rhythm = Rhythm{1, 0.5}
    local augmented = rhythm:augment(2)
    expect(augmented.durations[2]).to.be_equal_to(1.0)
  end)

  it('should diminish first duration by factor', function()
    local rhythm = Rhythm{1, 0.5}
    local diminished = rhythm:diminish(2)
    expect(diminished.durations[1]).to.be_equal_to(0.5)
  end)

  it('should diminish second duration by factor', function()
    local rhythm = Rhythm{1, 0.5}
    local diminished = rhythm:diminish(2)
    expect(diminished.durations[2]).to.be_equal_to(0.25)
  end)

  it('should repeat pattern specified number of times', function()
    local rhythm = Rhythm{1, 0.5}
    local repeated = rhythm:repeat_pattern(3)
    expect(#repeated.durations).to.be_equal_to(6)
  end)

  it('should reverse first duration in retrograde', function()
    local rhythm = Rhythm{1, 0.5, 0.25}
    local retro = rhythm:retrograde()
    expect(retro.durations[1]).to.be_equal_to(0.25)
  end)

  it('should reverse second duration in retrograde', function()
    local rhythm = Rhythm{1, 0.5, 0.25}
    local retro = rhythm:retrograde()
    expect(retro.durations[2]).to.be_equal_to(0.5)
  end)

  it('should reverse third duration in retrograde', function()
    local rhythm = Rhythm{1, 0.5, 0.25}
    local retro = rhythm:retrograde()
    expect(retro.durations[3]).to.be_equal_to(1)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
