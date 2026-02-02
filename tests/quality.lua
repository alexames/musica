local unit = require 'llx.unit'
require 'llx'
require 'musica.quality'

_ENV = unit.create_test_env(_ENV)

describe('QualityTest', function()
  it('should create major quality from major scale pitches', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.major}
    expect(Quality{pitches=scale:pitches(0, 2, 4)}).to.be_equal_to(Quality.major)
  end)

  it('should create minor quality from minor scale pitches', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.minor}
    expect(Quality{pitches=scale:pitches(0, 2, 4)}).to.be_equal_to(Quality.minor)
  end)

  it('should have correct pitch intervals for major quality', function()
    expect(Quality.major.pitch_intervals).to.be_equal_to(
      List{PitchInterval.unison,
           PitchInterval.majorThird,
           PitchInterval.perfectFifth})
  end)

  it('should return true when quality equals minor', function()
    scale = Scale{tonic=Pitch.c4, mode=Mode.minor}
    expect(Quality{pitches=scale:pitches(0, 2, 4)} == Quality.minor).to.be_truthy()
  end)

  it('should return length of 3 for major quality', function()
    expect(#Quality.major).to.be_equal_to(3)
  end)

  it('should evaluate repr of major quality correctly', function()
    expect(eval(repr(Quality.major))).to.be_equal_to(Quality.major)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
