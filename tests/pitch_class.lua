local unit = require 'llx.unit'
local llx = require 'llx'
local pitch_class_module = require 'musica.pitch_class'

local PitchClass = pitch_class_module.PitchClass
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

describe('PitchClassTest', function()
  it('should be equal when same pitch class', function()
    expect(PitchClass.A == PitchClass[1]).to.be_truthy()
  end)

  it('should not be equal when different pitch classes', function()
    expect(PitchClass.A == PitchClass.B).to.be_falsy()
  end)

  it('should order A less than B', function()
    expect(PitchClass.A < PitchClass.B).to.be_truthy()
  end)

  it('should order A less than G', function()
    expect(PitchClass.A < PitchClass.G).to.be_truthy()
  end)

  it('should not order G less than A', function()
    expect(PitchClass.G < PitchClass.A).to.be_falsy()
  end)

  it('should not order A less than A', function()
    expect(PitchClass.A < PitchClass.A).to.be_falsy()
  end)

  it('should order A less than or equal to A', function()
    expect(PitchClass.A <= PitchClass.A).to.be_truthy()
  end)

  it('should order A less than or equal to B', function()
    expect(PitchClass.A <= PitchClass.B).to.be_truthy()
  end)

  it('should not order B less than or equal to A', function()
    expect(PitchClass.B <= PitchClass.A).to.be_falsy()
  end)

  it('should convert to string', function()
    expect(tostring(PitchClass.C)).to.be_equal_to('PitchClass.C')
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
