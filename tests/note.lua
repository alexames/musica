local unit = require 'llx.unit'
local llx = require 'llx'
local note_module = require 'musica.note'

local Note = note_module.Note
local tovalue = llx.tovalue
local main_file = llx.main_file

_G.Note = Note

_ENV = unit.create_test_env(_ENV)

describe('NoteTest', function()
  it('should set pitch when initialized with volume', function()
    local note = Note{pitch=72, time=0, duration=2, volume=1}
    expect(note.pitch).to.be_equal_to(72)
  end)

  it('should set time when initialized with volume', function()
    local note = Note{pitch=72, time=0, duration=2, volume=1}
    expect(note.time).to.be_equal_to(0)
  end)

  it('should set duration when initialized with volume', function()
    local note = Note{pitch=72, time=0, duration=2, volume=1}
    expect(note.duration).to.be_equal_to(2)
  end)

  it('should set volume when initialized with volume', function()
    local note = Note{pitch=72, time=0, duration=2, volume=1}
    expect(note.volume).to.be_equal_to(1)
  end)

  it('should set pitch when initialized without volume', function()
    local note = Note{pitch=72, time=0, duration=2}
    expect(note.pitch).to.be_equal_to(72)
  end)

  it('should set time when initialized without volume', function()
    local note = Note{pitch=72, time=0, duration=2}
    expect(note.time).to.be_equal_to(0)
  end)

  it('should set duration when initialized without volume', function()
    local note = Note{pitch=72, time=0, duration=2}
    expect(note.duration).to.be_equal_to(2)
  end)

  it('should default volume to 1 when initialized without volume', function()
    local note = Note{pitch=72, time=0, duration=2}
    expect(note.volume).to.be_equal_to(1)
  end)

  it('should throw error when pitch is missing', function()
    expect(function() Note{time=0, duration=2} end).to.throw()
  end)

  it('should default time to 0 when time is missing', function()
    local note = Note{pitch=72, duration=2}
    expect(note.time).to.be_equal_to(0)
  end)

  it('should throw error when duration is missing', function()
    expect(function() Note{pitch=72, time=0} end).to.throw()
  end)

  it('should return new note with correct finish via with_finish', function()
    local note = Note{pitch=72, time=10, duration=15}
    local adjusted = note:with_finish(12)
    expect(adjusted:finish()).to.be_equal_to(12)
    expect(adjusted.time).to.be_equal_to(10)
    expect(adjusted.duration).to.be_equal_to(2)
  end)

  it('with_finish should not mutate original note', function()
    local note = Note{pitch=72, time=10, duration=15}
    note:with_finish(12)
    expect(note.duration).to.be_equal_to(15)
  end)

  it('should calculate finish time correctly', function()
    local note = Note{pitch=72, time=10, duration=2}
    expect(note:finish()).to.be_equal_to(12)
  end)

  it('should convert note to string and back to same note', function()
    local note = Note{pitch=72, time=0, duration=2}
    expect(tovalue(tostring(note))).to.be_equal_to(note)
  end)
end)

if main_file() then
  unit.run_unit_tests()
end
