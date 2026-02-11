local unit = require 'llx.unit'
local llx = require 'llx'
local quality_module = require 'musica.quality'
local scale_module = require 'musica.scale'
local pitch_module = require 'musica.pitch'
local mode_module = require 'musica.mode'
require 'musica.modes'
local pitch_interval_module = require 'musica.pitch_interval'

local Quality = quality_module.Quality
local Scale = scale_module.Scale
local Pitch = pitch_module.Pitch
local Mode = mode_module.Mode
local PitchInterval = pitch_interval_module.PitchInterval
local List = llx.List
local tovalue = llx.tovalue
local main_file = llx.main_file

_G.Quality = Quality

_ENV = unit.create_test_env(_ENV)

describe('QualityTest', function()
  it('should create major quality from major scale pitches', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(Quality{pitches=scale[{0, 2, 4}]}).to.be_equal_to(Quality.major)
  end)

  it('should create minor quality from minor scale pitches', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.minor}
    expect(Quality{pitches=scale[{0, 2, 4}]}).to.be_equal_to(Quality.minor)
  end)

  it('should have correct pitch intervals for major quality', function()
    expect(Quality.major.pitch_intervals).to.be_equal_to(
      List{PitchInterval.unison,
           PitchInterval.major_third,
           PitchInterval.perfect_fifth})
  end)

  it('should return true when quality equals minor', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.minor}
    expect(Quality{pitches=scale[{0, 2, 4}]} == Quality.minor).to.be_truthy()
  end)

  it('should return length of 3 for major quality', function()
    expect(#Quality.major).to.be_equal_to(3)
  end)

  it('should evaluate repr of major quality correctly', function()
    expect(tovalue(tostring(Quality.major))).to.be_equal_to(Quality.major)
  end)

  it('should not mutate the input pitches list when constructed from pitches', function()
    local pitches = List{Pitch.g4, Pitch.c4, Pitch.e4}
    local original = List{Pitch.g4, Pitch.c4, Pitch.e4}
    Quality{pitches=pitches}
    expect(pitches).to.be_equal_to(original)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
