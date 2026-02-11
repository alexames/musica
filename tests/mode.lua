local unit = require 'llx.unit'
local llx = require 'llx'
local mode_module = require 'musica.mode'
require 'musica.modes'
local pitch_interval_module = require 'musica.pitch_interval'

local Mode = mode_module.Mode
local PitchInterval = pitch_interval_module.PitchInterval
local List = llx.List
local tovalue = llx.tovalue
local main_file = llx.main_file

_G.Mode = Mode
_G.List = List

_ENV = unit.create_test_env(_ENV)

describe('ModeTest', function()
  it('should have ionian equal to major', function()
    expect(Mode.ionian).to.be_equal_to(Mode.major)
  end)

  it('should have correct semitone intervals for ionian', function()
    expect(Mode.ionian.semitone_intervals).to.be_equal_to(List{
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
    })
  end)

  it('should return 5 for relative minor of major', function()
    expect(Mode.major:relative(Mode.minor)).to.be_equal_to(5)
  end)

  it('should return 2 for relative major of minor', function()
    expect(Mode.minor:relative(Mode.major)).to.be_equal_to(2)
  end)

  it('should rotate major left by 5 to get minor', function()
    expect(Mode.major << 5).to.be_equal_to(Mode.minor)
  end)

  it('should rotate minor left by 2 to get major', function()
    expect(Mode.minor << 2).to.be_equal_to(Mode.major)
  end)

  it('should rotate major right by 2 to get minor', function()
    expect(Mode.major >> 2).to.be_equal_to(Mode.minor)
  end)

  it('should rotate minor right by 5 to get major', function()
    expect(Mode.minor >> 5).to.be_equal_to(Mode.major)
  end)

  it('should return true when ionian equals mode with same intervals', function()
    expect(Mode.ionian == Mode(List{
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
    })).to.be_truthy()
  end)

  it('should return false when ionian does not equal mode with different intervals', function()
    expect(Mode.ionian == Mode(List{
      PitchInterval.whole,
      PitchInterval.half,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.whole,
      PitchInterval.half,
      PitchInterval.whole,
    })).to.be_falsy()
  end)

  it('should return length of 7 for major mode', function()
    expect(#Mode.major).to.be_equal_to(7)
  end)

  it('should return unison for major mode index 0', function()
    expect(Mode.major[0]).to.be_equal_to(PitchInterval.unison)
  end)

  it('should return major second for major mode index 1', function()
    expect(Mode.major[1]).to.be_equal_to(PitchInterval.major_second)
  end)

  it('should return major third for major mode index 2', function()
    expect(Mode.major[2]).to.be_equal_to(PitchInterval.major_third)
  end)

  it('should return perfect fourth for major mode index 3', function()
    expect(Mode.major[3]).to.be_equal_to(PitchInterval.perfect_fourth)
  end)

  it('should return perfect fifth for major mode index 4', function()
    expect(Mode.major[4]).to.be_equal_to(PitchInterval.perfect_fifth)
  end)

  it('should return major sixth for major mode index 5', function()
    expect(Mode.major[5]).to.be_equal_to(PitchInterval.major_sixth)
  end)

  it('should return major seventh for major mode index 6', function()
    expect(Mode.major[6]).to.be_equal_to(PitchInterval.major_seventh)
  end)

  it('should return octave for major mode index 7', function()
    expect(Mode.major[7]).to.be_equal_to(PitchInterval.octave)
  end)

  it('should return double octave for major mode index 14', function()
    expect(Mode.major[14]).to.be_equal_to(2 * PitchInterval.octave)
  end)

  it('should return unison for minor mode index 0', function()
    expect(Mode.minor[0]).to.be_equal_to(PitchInterval.unison)
  end)

  it('should return major second for minor mode index 1', function()
    expect(Mode.minor[1]).to.be_equal_to(PitchInterval.major_second)
  end)

  it('should return minor third for minor mode index 2', function()
    expect(Mode.minor[2]).to.be_equal_to(PitchInterval.minor_third)
  end)

  it('should return perfect fourth for minor mode index 3', function()
    expect(Mode.minor[3]).to.be_equal_to(PitchInterval.perfect_fourth)
  end)

  it('should return perfect fifth for minor mode index 4', function()
    expect(Mode.minor[4]).to.be_equal_to(PitchInterval.perfect_fifth)
  end)

  it('should return minor sixth for minor mode index 5', function()
    expect(Mode.minor[5]).to.be_equal_to(PitchInterval.minor_sixth)
  end)

  it('should return minor seventh for minor mode index 6', function()
    expect(Mode.minor[6]).to.be_equal_to(PitchInterval.minor_seventh)
  end)

  it('should return octave for minor mode index 7', function()
    expect(Mode.minor[7]).to.be_equal_to(PitchInterval.octave)
  end)

  it('should return double octave for minor mode index 14', function()
    expect(Mode.minor[14]).to.be_equal_to(2 * PitchInterval.octave)
  end)

  it('should convert mode to string and back to same mode', function()
    local mode = Mode.major
    expect(tovalue(tostring(mode))).to.be_equal_to(mode)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
