local unit = require 'llx.unit'
local llx = require 'llx'
local scale_degree_module = require 'musica.scale_degree'

local ScaleDegree = scale_degree_module.ScaleDegree
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

describe('ScaleDegreeTest', function()
  it('should map tonic to 0', function()
    expect(ScaleDegree.tonic).to.be_equal_to(0)
  end)

  it('should map supertonic to 1', function()
    expect(ScaleDegree.supertonic).to.be_equal_to(1)
  end)

  it('should map mediant to 2', function()
    expect(ScaleDegree.mediant).to.be_equal_to(2)
  end)

  it('should map subdominant to 3', function()
    expect(ScaleDegree.subdominant).to.be_equal_to(3)
  end)

  it('should map dominant to 4', function()
    expect(ScaleDegree.dominant).to.be_equal_to(4)
  end)

  it('should map submediant to 5', function()
    expect(ScaleDegree.submediant).to.be_equal_to(5)
  end)

  it('should map leading tone to 6', function()
    expect(ScaleDegree.leading_tone).to.be_equal_to(6)
  end)

  it('should return nil for an unknown degree name', function()
    expect(ScaleDegree.octave).to.be_nil()
  end)

  it('should place dominant a fifth above tonic', function()
    expect(ScaleDegree.dominant - ScaleDegree.tonic).to.be_equal_to(4)
  end)

  it('should place subdominant a fifth below dominant plus one'
    .. ' step', function()
    expect(ScaleDegree.dominant - ScaleDegree.subdominant).to.be_equal_to(1)
  end)

  it('should define exactly seven degrees', function()
    local count = 0
    for _ in pairs(ScaleDegree) do
      count = count + 1
    end
    expect(count).to.be_equal_to(7)
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
