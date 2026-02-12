local unit = require 'llx.unit'
local llx = require 'llx'
local time_signature_module = require 'musica.time_signature'

local TimeSignature = time_signature_module.TimeSignature
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

describe('TimeSignatureTests', function()
  it('should create 4/4 time signature with correct numerator', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts.numerator).to.be_equal_to(4)
  end)

  it('should create 4/4 time signature with correct denominator', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts.denominator).to.be_equal_to(4)
  end)

  it('should identify 4/4 as simple meter', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts:is_simple()).to.be_truthy()
  end)

  it('should identify 4/4 as not compound meter', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts:is_compound()).to.be_falsy()
  end)

  it('should identify 6/8 as not simple meter', function()
    local ts = TimeSignature{numerator = 6, denominator = 8}
    expect(ts:is_simple()).to.be_falsy()
  end)

  it('should identify 6/8 as compound meter', function()
    local ts = TimeSignature{numerator = 6, denominator = 8}
    expect(ts:is_compound()).to.be_truthy()
  end)

  it('should calculate 4 beats per measure for 4/4', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts:get_beats_per_measure()).to.be_equal_to(4)
  end)

  it('should calculate 2 beats per measure for 6/8', function()
    local ts = TimeSignature{numerator = 6, denominator = 8}
    expect(ts:get_beats_per_measure()).to.be_equal_to(2)  -- 6/3 = 2
  end)

  it('should classify 2/4 as duple meter', function()
    local ts_duple = TimeSignature{numerator = 2, denominator = 4}
    expect(ts_duple:get_meter_type()).to.be_equal_to('duple')
  end)

  it('should classify 3/4 as triple meter', function()
    local ts_triple = TimeSignature{numerator = 3, denominator = 4}
    expect(ts_triple:get_meter_type()).to.be_equal_to('triple')
  end)

  it('should classify 4/4 as quadruple meter', function()
    local ts_quadruple = TimeSignature{numerator = 4, denominator = 4}
    expect(ts_quadruple:get_meter_type()).to.be_equal_to('quadruple')
  end)

  it('should convert time signature to string', function()
    local ts = TimeSignature{numerator = 3, denominator = 4}
    expect(tostring(ts)).to.be_equal_to('3/4')
  end)

  it('should order 2/4 less than 3/4 by measure duration', function()
    local ts_2_4 = TimeSignature{numerator = 2, denominator = 4}
    local ts_3_4 = TimeSignature{numerator = 3, denominator = 4}
    expect(ts_2_4 < ts_3_4).to.be_truthy()
  end)

  it('should order 3/4 less than 4/4 by measure duration', function()
    local ts_3_4 = TimeSignature{numerator = 3, denominator = 4}
    local ts_4_4 = TimeSignature{numerator = 4, denominator = 4}
    expect(ts_3_4 < ts_4_4).to.be_truthy()
  end)

  it('should order 6/8 less than 4/4 by measure duration', function()
    -- 6/8 = 0.75 measures, 4/4 = 1.0 measures
    local ts_6_8 = TimeSignature{numerator = 6, denominator = 8}
    local ts_4_4 = TimeSignature{numerator = 4, denominator = 4}
    expect(ts_6_8 < ts_4_4).to.be_truthy()
  end)

  it('should order 2/2 less than 4/4 when equal duration (by denominator)', function()
    -- Both have measure duration 1.0, but 2/2 has smaller denominator
    local ts_2_2 = TimeSignature{numerator = 2, denominator = 2}
    local ts_4_4 = TimeSignature{numerator = 4, denominator = 4}
    expect(ts_2_2 < ts_4_4).to.be_truthy()
  end)

  it('should order time signature less than or equal to itself', function()
    local ts = TimeSignature{numerator = 4, denominator = 4}
    expect(ts <= TimeSignature{numerator = 4, denominator = 4}).to.be_truthy()
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
