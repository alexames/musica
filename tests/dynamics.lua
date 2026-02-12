local unit = require 'llx.unit'
local llx = require 'llx'
local dynamics_module = require 'musica.dynamics'

local Dynamic = dynamics_module.Dynamic
local dynamics = dynamics_module.dynamics
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

describe('DynamicTest', function()
  it('should look up piano by long name', function()
    expect(dynamics['piano'].volume).to.be_equal_to(0.4)
  end)

  it('should look up piano by short name', function()
    expect(dynamics['p'].volume).to.be_equal_to(0.4)
  end)

  it('should be equal when same dynamic', function()
    expect(dynamics['piano'] == dynamics['p']).to.be_truthy()
  end)

  it('should not be equal when different dynamics', function()
    expect(dynamics['piano'] == dynamics['forte']).to.be_falsy()
  end)

  it('should order piano less than forte', function()
    expect(dynamics['piano'] < dynamics['forte']).to.be_truthy()
  end)

  it('should not order forte less than piano', function()
    expect(dynamics['forte'] < dynamics['piano']).to.be_falsy()
  end)

  it('should order piano less than or equal to forte', function()
    expect(dynamics['piano'] <= dynamics['forte']).to.be_truthy()
  end)

  it('should order piano less than or equal to itself', function()
    expect(dynamics['piano'] <= dynamics['p']).to.be_truthy()
  end)

  it('should convert piano to string', function()
    expect(tostring(dynamics['piano'])).to.be_equal_to('Dynamic.p')
  end)

  it('should convert fortissimo to string', function()
    expect(tostring(dynamics['fortissimo'])).to.be_equal_to('Dynamic.ff')
  end)

  it('should order all dynamics from soft to loud', function()
    expect(dynamics['n'] < dynamics['pppp']).to.be_truthy()
    expect(dynamics['pppp'] < dynamics['ppp']).to.be_truthy()
    expect(dynamics['ppp'] < dynamics['pp']).to.be_truthy()
    expect(dynamics['pp'] < dynamics['p']).to.be_truthy()
    expect(dynamics['p'] < dynamics['mp']).to.be_truthy()
    expect(dynamics['mp'] < dynamics['mf']).to.be_truthy()
    expect(dynamics['mf'] < dynamics['f']).to.be_truthy()
    expect(dynamics['f'] < dynamics['ff']).to.be_truthy()
    expect(dynamics['ff'] < dynamics['fff']).to.be_truthy()
    expect(dynamics['fff'] < dynamics['ffff']).to.be_truthy()
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
