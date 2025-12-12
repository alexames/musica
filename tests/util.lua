local unit = require 'unit'
require 'llx'
require 'musica.util'

_ENV = unit.create_test_env(_ENV)

describe('UtilTest', function()
  it('should test reprArgs', function()
    -- Single unnamed arg
    -- expect(reprArgs('Test', {{nil}})).to.be_equal_to('Test(nil)')
    -- expect(reprArgs('Test', {{100}})).to.be_equal_to('Test(100)')
    -- expect(reprArgs('Test', {{false}})).to.be_equal_to('Test(false)')
    -- expect(reprArgs('Test', {{true}})).to.be_equal_to('Test(true)')
    -- expect(reprArgs('Test', {{'string'}})).to.be_equal_to("Test('string')")
    -- Single named arg
  end)

  it('should test intervalsToIndices', function()
    -- No tests yet
  end)

  it('should test indicesToIntervals', function()
    -- No tests yet
  end)

  it('should test extendedIndex', function()
    -- No tests yet
  end)

  it('should test extendedIndices', function()
    -- No tests yet
  end)
end)

describe('RingTest', function()
  it('should return first element for index 0', function()
    local ring = Ring{3, 6, 9}
    expect(ring[0]).to.be_equal_to(3)
  end)

  it('should return second element for index 1', function()
    local ring = Ring{3, 6, 9}
    expect(ring[1]).to.be_equal_to(6)
  end)

  it('should return third element for index 2', function()
    local ring = Ring{3, 6, 9}
    expect(ring[2]).to.be_equal_to(9)
  end)

  it('should wrap to first element for index 3', function()
    local ring = Ring{3, 6, 9}
    expect(ring[3]).to.be_equal_to(3)
  end)

  it('should wrap to second element for index 4', function()
    local ring = Ring{3, 6, 9}
    expect(ring[4]).to.be_equal_to(6)
  end)

  it('should return third element for negative index -3', function()
    local ring = Ring{3, 6, 9}
    expect(ring[-3]).to.be_equal_to(3)
  end)

  it('should return first element for negative index -2', function()
    local ring = Ring{3, 6, 9}
    expect(ring[-2]).to.be_equal_to(6)
  end)

  it('should return second element for negative index -1', function()
    local ring = Ring{3, 6, 9}
    expect(ring[-1]).to.be_equal_to(9)
  end)

  it('should wrap to third element for negative index -4', function()
    local ring = Ring{3, 6, 9}
    expect(ring[-4]).to.be_equal_to(9)
  end)

  it('should return list of elements for list index', function()
    local ring = Ring{3, 6, 9}
    expect(ring[{-4, -3, -2, -1, 0, 1, 2, 3, 4}]).to.be_equal_to(
      List{9, 3, 6, 9, 3, 6, 9, 3, 6})
  end)
end)

describe('SpiralTest', function()
  it('should return -10 for index -4', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[-4]).to.be_equal_to(-10)
  end)

  it('should return -7 for index -3', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[-3]).to.be_equal_to(-7)
  end)

  it('should return -5 for index -2', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[-2]).to.be_equal_to(-5)
  end)

  it('should return -2 for index -1', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[-1]).to.be_equal_to(-2)
  end)

  it('should return 0 for index 0', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[0]).to.be_equal_to(0)
  end)

  it('should return 3 for index 1', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[1]).to.be_equal_to(3)
  end)

  it('should return 5 for index 2', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[2]).to.be_equal_to(5)
  end)

  it('should return 8 for index 3', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[3]).to.be_equal_to(8)
  end)

  it('should return 10 for index 4', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[4]).to.be_equal_to(10)
  end)

  it('should return list of values for list index', function()
    local spiral = Spiral{0, 3, 5}
    expect(spiral[{0, 1, 2, 3, 4}]).to.be_equal_to(List{0, 3, 5, 8, 10})
  end)

  it('should return -1 for octave index -1', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[-1]).to.be_equal_to(-1)
  end)

  it('should return 0 for octave index 0', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[0]).to.be_equal_to(0)
  end)

  it('should return 2 for octave index 1', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[1]).to.be_equal_to(2)
  end)

  it('should return 4 for octave index 2', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[2]).to.be_equal_to(4)
  end)

  it('should return 5 for octave index 3', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[3]).to.be_equal_to(5)
  end)

  it('should return 12 for octave index 7', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[7]).to.be_equal_to(12)
  end)

  it('should return 14 for octave index 8', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[8]).to.be_equal_to(14)
  end)

  it('should return 16 for octave index 9', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[9]).to.be_equal_to(16)
  end)

  it('should return 17 for octave index 10', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[10]).to.be_equal_to(17)
  end)

  it('should return 19 for octave index 11', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[11]).to.be_equal_to(19)
  end)

  it('should return 21 for octave index 12', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[12]).to.be_equal_to(21)
  end)

  it('should return 23 for octave index 13', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[13]).to.be_equal_to(23)
  end)

  it('should return 24 for octave index 14', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[14]).to.be_equal_to(24)
  end)

  it('should return list of values for octave list index', function()
    local octave = Spiral{0, 2, 4, 5, 7, 9, 11, 12}
    expect(octave[{0, 2, 4}]).to.be_equal_to(List{0, 4, 7})
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
