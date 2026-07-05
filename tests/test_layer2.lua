-- Tests for Layer 2 abstractions: stamper, drum_pattern, scale_walk, pulse

local unit = require 'llx.unit'
local llx = require 'llx'
local musica = require 'musica'

local Pitch = musica.Pitch
local Scale = musica.Scale
local Mode = musica.Mode
local Rhythm = musica.Rhythm
local stamper = musica.stamper
local scale_stamper = musica.scale_stamper
local drum_pattern = musica.drum_pattern
local pulse = musica.pulse
local scale_walk = musica.scale_walk
local sequence = musica.sequence
local tointeger = llx.tointeger
local main_file = llx.main_file

local EPS = 0.001

_ENV = unit.create_test_env(_ENV)

describe('PulseTest', function()
  it('should produce evenly spaced durations filling the total', function()
    local r = pulse(0.5, 4)
    expect(#r).to.be_equal_to(8)
    expect(r:total_duration()).to.be_near(4, EPS)
    for _, d in ipairs(r.durations) do
      expect(d).to.be_near(0.5, EPS)
    end
  end)

  it('should handle quarter-beat pulses', function()
    local r = pulse(0.25, 2)
    expect(#r).to.be_equal_to(8)
    expect(r:total_duration()).to.be_near(2, EPS)
  end)
end)

describe('ScaleWalkTest', function()
  it('should walk up inclusively', function()
    local walk = scale_walk{from=0, to=4}
    expect(#walk).to.be_equal_to(5)
    expect(walk[1]).to.be_equal_to(0)
    expect(walk[5]).to.be_equal_to(4)
  end)

  it('should walk down inclusively', function()
    local walk = scale_walk{from=7, to=4}
    expect(#walk).to.be_equal_to(4)
    expect(walk[1]).to.be_equal_to(7)
    expect(walk[4]).to.be_equal_to(4)
  end)

  it('should produce a single element when from equals to', function()
    local walk = scale_walk{from=3, to=3}
    expect(#walk).to.be_equal_to(1)
    expect(walk[1]).to.be_equal_to(3)
  end)

  it('should respect a custom step and include the endpoint', function()
    local walk = scale_walk{from=0, to=6, step=2}
    expect(#walk).to.be_equal_to(4)
    expect(walk[#walk]).to.be_equal_to(6)
  end)
end)

describe('SequenceTest', function()
  it('should repeat the pattern from each starting index', function()
    local seq = sequence{pattern={0, -2, -4}, starts={9, 7, 5}}
    expect(#seq).to.be_equal_to(9)
    expect(seq[1]).to.be_equal_to(9)
    expect(seq[2]).to.be_equal_to(7)
    expect(seq[3]).to.be_equal_to(5)
    expect(seq[4]).to.be_equal_to(7)
    expect(seq[5]).to.be_equal_to(5)
    expect(seq[6]).to.be_equal_to(3)
  end)
end)

describe('StamperTest', function()
  local scale = Scale{tonic=Pitch.c4, mode=Mode.major}

  it('should stamp sequential notes along a rhythm', function()
    local fig = stamper{pitches={scale[0], scale[2], scale[4]},
      rhythm=Rhythm{1, 1, 2}, volume=0.5, duration=4}
    expect(#fig.notes).to.be_equal_to(3)
    expect(fig.duration).to.be_equal_to(4)
    expect(fig.notes[1].time).to.be_near(0, EPS)
    expect(fig.notes[2].time).to.be_near(1, EPS)
    expect(fig.notes[3].time).to.be_near(2, EPS)
    expect(fig.notes[3].duration).to.be_near(2, EPS)
    expect(fig.notes[1].volume).to.be_near(0.5, EPS)
  end)

  it('should apply a fixed note_duration override', function()
    local fig = stamper{pitches={scale[0]},
      rhythm=Rhythm{0.5, 0.5, 0.5, 0.5}, note_duration=0.24, volume=1.0,
      duration=4}
    expect(#fig.notes).to.be_equal_to(4)
    expect(fig.notes[1].duration).to.be_near(0.24, EPS)
    expect(fig.notes[2].time).to.be_near(0.5, EPS)
  end)

  it('should stamp all pitches at once in simultaneous mode', function()
    local fig = stamper{pitches={scale[0], scale[2]},
      rhythm={{0, 0.49}}, mode='simultaneous', volume=0.5, duration=4}
    expect(#fig.notes).to.be_equal_to(2)
    expect(fig.notes[1].time).to.be_near(fig.notes[2].time, EPS)
  end)
end)

describe('ScaleStamperTest', function()
  local scale = Scale{tonic=Pitch.c4, mode=Mode.major}

  it('should stamp notes from scale indices', function()
    local fig = scale_stamper{scale=scale, indices={0, 2, 4},
      rhythm=Rhythm{1, 1, 2}, volume=0.8, duration=4}
    expect(#fig.notes).to.be_equal_to(3)
    -- Note stores pitch as a MIDI integer (Note coerces via tointeger), so
    -- compare against the integer value of each scale degree, not the Pitch.
    expect(fig.notes[1].pitch).to.be_equal_to(tointeger(scale[0]))
    expect(fig.notes[2].pitch).to.be_equal_to(tointeger(scale[2]))
    expect(fig.notes[3].pitch).to.be_equal_to(tointeger(scale[4]))
  end)
end)

describe('DrumPatternTest', function()
  local KICK = 36
  local SNARE = 38

  it('should merge layers into a single figure', function()
    local dp = drum_pattern{layers={
      {pitch=KICK, rhythm=Rhythm{1, 1, 1, 1}, note_duration=0.24, volume=1.0},
      {pitch=SNARE, rhythm={{1.0, 0.24}, {3.0, 0.24}}, volume=0.9},
    }, duration=4}
    expect(dp.duration).to.be_equal_to(4)
    expect(#dp.notes).to.be_equal_to(6)
  end)

  it('should apply note_duration to every note in a layer', function()
    local dp = drum_pattern{layers={
      {pitch=KICK, rhythm=Rhythm{1, 1, 1, 1}, note_duration=0.24, volume=1.0},
      {pitch=SNARE, rhythm={{1.0, 0.24}, {3.0, 0.24}}, volume=0.9},
    }, duration=4}
    local kick_count = 0
    for _, n in ipairs(dp.notes) do
      if n.pitch == KICK then
        kick_count = kick_count + 1
        expect(n.duration).to.be_near(0.24, EPS)
      end
    end
    expect(kick_count).to.be_equal_to(4)
  end)
end)

if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
