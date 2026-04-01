-- Tests for Layer 2 abstractions: stamper, drum_pattern, scale_walk, pulse

package.path = '../src/?.lua;' .. package.path

local musica = require 'musica'

local Pitch = musica.Pitch
local PitchInterval = musica.PitchInterval
local Scale = musica.Scale
local Mode = musica.Mode
local Note = musica.Note
local Figure = musica.Figure
local Rhythm = musica.Rhythm
local stamper = musica.stamper
local scale_stamper = musica.scale_stamper
local drum_pattern = musica.drum_pattern
local pulse = musica.pulse
local scale_walk = musica.scale_walk
local sequence = musica.sequence

local P8 = PitchInterval.octave
local pass_count = 0
local fail_count = 0

local function check(name, condition, msg)
  if condition then
    pass_count = pass_count + 1
  else
    fail_count = fail_count + 1
    print('FAIL: ' .. name .. (msg and (' - ' .. msg) or ''))
  end
end

local function approx(a, b, eps)
  return math.abs(a - b) < (eps or 0.001)
end

-- Test pulse
print('=== pulse ===')
local r = pulse(0.5, 4)
check('pulse count', #r == 8)
check('pulse total', approx(r:total_duration(), 4))
for _, d in ipairs(r.durations) do
  check('pulse duration', approx(d, 0.5))
end

local r2 = pulse(0.25, 2)
check('pulse quarter count', #r2 == 8)
check('pulse quarter total', approx(r2:total_duration(), 2))

-- Test scale_walk
print('=== scale_walk ===')
local walk_up = scale_walk{from=0, to=4}
check('walk_up length', #walk_up == 5, 'got ' .. #walk_up)
check('walk_up[1]', walk_up[1] == 0)
check('walk_up[5]', walk_up[5] == 4)

local walk_down = scale_walk{from=7, to=4}
check('walk_down length', #walk_down == 4, 'got ' .. #walk_down)
check('walk_down[1]', walk_down[1] == 7)
check('walk_down[4]', walk_down[4] == 4)

local walk_single = scale_walk{from=3, to=3}
check('walk_single', #walk_single == 1)
check('walk_single val', walk_single[1] == 3)

local walk_step2 = scale_walk{from=0, to=6, step=2}
check('walk_step2 length', #walk_step2 == 4, 'got ' .. #walk_step2)
check('walk_step2 includes end', walk_step2[#walk_step2] == 6)

-- Test sequence
print('=== sequence ===')
local seq = sequence{pattern={0, -2, -4}, starts={9, 7, 5}}
check('sequence length', #seq == 9, 'got ' .. #seq)
check('seq[1]', seq[1] == 9)
check('seq[2]', seq[2] == 7)
check('seq[3]', seq[3] == 5)
check('seq[4]', seq[4] == 7)
check('seq[5]', seq[5] == 5)
check('seq[6]', seq[6] == 3)

-- Test stamper sequential
print('=== stamper ===')
local scale = Scale{tonic=Pitch.c4, mode=Mode.major}
local fig = stamper{pitches={scale[0], scale[2], scale[4]},
  rhythm=Rhythm{1, 1, 2}, volume=0.5, duration=4}
check('stamper notes count', #fig.notes == 3, 'got ' .. #fig.notes)
check('stamper duration', fig.duration == 4)
check('stamper note1 time', approx(fig.notes[1].time, 0))
check('stamper note2 time', approx(fig.notes[2].time, 1))
check('stamper note3 time', approx(fig.notes[3].time, 2))
check('stamper note3 dur', approx(fig.notes[3].duration, 2))
check('stamper volume', approx(fig.notes[1].volume, 0.5))

-- Test stamper with note_duration
local fig2 = stamper{pitches={scale[0]},
  rhythm=Rhythm{0.5, 0.5, 0.5, 0.5}, note_duration=0.24, volume=1.0, duration=4}
check('stamper note_dur count', #fig2.notes == 4)
check('stamper note_dur dur', approx(fig2.notes[1].duration, 0.24))
check('stamper note_dur time2', approx(fig2.notes[2].time, 0.5))

-- Test stamper simultaneous
local fig3 = stamper{pitches={scale[0], scale[2]},
  rhythm={{0, 0.49}}, mode='simultaneous', volume=0.5, duration=4}
check('stamper simul count', #fig3.notes == 2, 'got ' .. #fig3.notes)
check('stamper simul same time', approx(fig3.notes[1].time, fig3.notes[2].time))

-- Test scale_stamper
print('=== scale_stamper ===')
local fig4 = scale_stamper{scale=scale, indices={0, 2, 4},
  rhythm=Rhythm{1, 1, 2}, volume=0.8, duration=4}
check('scale_stamper count', #fig4.notes == 3)
check('scale_stamper pitch matches scale',
  fig4.notes[1].pitch == scale[0] and fig4.notes[2].pitch == scale[2]
  and fig4.notes[3].pitch == scale[4])

-- Test drum_pattern
print('=== drum_pattern ===')
local KICK = 36
local SNARE = 38
local dp = drum_pattern{layers={
  {pitch=KICK, rhythm=Rhythm{1, 1, 1, 1}, note_duration=0.24, volume=1.0},
  {pitch=SNARE, rhythm={{1.0, 0.24}, {3.0, 0.24}}, volume=0.9},
}, duration=4}
check('drum_pattern duration', dp.duration == 4)
-- Should have 4 kicks + 2 snares = 6 notes
check('drum_pattern note count', #dp.notes == 6, 'got ' .. #dp.notes)

-- Verify kick notes have correct duration
local kick_count = 0
for _, n in ipairs(dp.notes) do
  if n.pitch == KICK then
    kick_count = kick_count + 1
    check('kick dur', approx(n.duration, 0.24))
  end
end
check('kick count', kick_count == 4)

-- Summary
print(string.format('\n%d passed, %d failed', pass_count, fail_count))
if fail_count > 0 then os.exit(1) end
