local unit = require 'llx.unit'
local llx = require 'llx'
local tempo_module = require 'musica.tempo'

local Tempo = tempo_module.Tempo
local main_file = llx.main_file

_ENV = unit.create_test_env(_ENV)

describe('TempoTests', function()
  it('should create tempo with BPM', function()
    local tempo = Tempo(120)
    expect(tempo.bpm).to.be_equal_to(120)
  end)

  it('should create tempo with marking and set BPM in range', function()
    local tempo = Tempo{marking = 'Allegro'}
    expect(tempo.bpm >= 120 and tempo.bpm <= 156).to.be_truthy()
  end)

  it('should create tempo with marking and set marking to lowercase', function()
    local tempo = Tempo{marking = 'Allegro'}
    expect(tempo.marking).to.be_equal_to('allegro')
  end)

  it('should calculate microseconds per beat correctly', function()
    local tempo = Tempo(120)
    local microseconds = tempo:get_microseconds_per_beat()
    expect(microseconds).to.be_equal_to(500000)  -- 60,000,000 / 120
  end)

  it('should include marking in description', function()
    local tempo = Tempo{marking = 'Allegro'}
    local desc = tempo:describe()
    expect(desc:match('Allegro')).to.be_truthy()
  end)

  it('should include BPM in description', function()
    local tempo = Tempo{marking = 'Allegro'}
    local desc = tempo:describe()
    expect(desc:match('BPM')).to.be_truthy()
  end)

  it('should return true when tempo is in specified range', function()
    local tempo = Tempo(130)
    expect(tempo:is_in_range('allegro')).to.be_truthy()
  end)

  it('should return false when tempo is not in specified range', function()
    local tempo = Tempo(130)
    expect(tempo:is_in_range('adagio')).to.be_falsy()
  end)

  it('should be equal when bpm and marking both match', function()
    local a = Tempo{marking = 'allegro'}
    local b = Tempo{marking = 'allegro'}
    expect(a == b).to.be_truthy()
  end)

  it('should not be equal when markings differ even if bpm matches', function()
    local a = Tempo{bpm = 138, marking = 'allegro'}
    local b = Tempo(138)
    expect(a == b).to.be_falsy()
  end)

  it('should order slower tempo less than faster tempo', function()
    local adagio = Tempo{marking = 'adagio'}
    local allegro = Tempo{marking = 'allegro'}
    expect(adagio < allegro).to.be_truthy()
  end)

  it('should not order faster tempo less than slower tempo', function()
    local adagio = Tempo{marking = 'adagio'}
    local allegro = Tempo{marking = 'allegro'}
    expect(allegro < adagio).to.be_falsy()
  end)

  it('should order tempo less than or equal to itself', function()
    local a = Tempo(120)
    local b = Tempo(120)
    expect(a <= b).to.be_truthy()
  end)

  it('should order slower tempo less than or equal to faster tempo', function()
    expect(Tempo(60) <= Tempo(120)).to.be_truthy()
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
