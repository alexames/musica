local unit = require 'llx.unit'
local llx = require 'llx'
local scale_index_module = require 'musica.scale_index'

local ScaleIndex = scale_index_module.ScaleIndex
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

describe('ScaleIndexTest', function()
  it('should map first to 0', function()
    -- Note: this raw entry shadows the List:first() method on this
    -- instance; ScaleIndex.first is the value 0, not a function.
    expect(ScaleIndex.first).to.be_equal_to(0)
  end)

  it('should map second to 1', function()
    expect(ScaleIndex.second).to.be_equal_to(1)
  end)

  it('should map third to 2', function()
    expect(ScaleIndex.third).to.be_equal_to(2)
  end)

  it('should map fourth to 3', function()
    expect(ScaleIndex.fourth).to.be_equal_to(3)
  end)

  it('should map fifth to 4', function()
    expect(ScaleIndex.fifth).to.be_equal_to(4)
  end)

  it('should map sixth to 5', function()
    expect(ScaleIndex.sixth).to.be_equal_to(5)
  end)

  it('should map seventh to 6', function()
    expect(ScaleIndex.seventh).to.be_equal_to(6)
  end)

  it('should map octave to 7', function()
    expect(ScaleIndex.octave).to.be_equal_to(7)
  end)

  it('should return nil for an unknown index name', function()
    expect(ScaleIndex.ninth).to.be_nil()
  end)

  it('should place octave seven steps above first', function()
    expect(ScaleIndex.octave - ScaleIndex.first).to.be_equal_to(7)
  end)

  it('should define exactly eight indices', function()
    local count = 0
    for _ in pairs(ScaleIndex) do
      count = count + 1
    end
    expect(count).to.be_equal_to(8)
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
