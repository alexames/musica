require 'llx'
require 'musictheory'
local midi = require 'midi'

local function arpeggio_figure(key, quality, nth_chord, direction, scale_indices, inversion)
  local root = find_chord{
      scale=key, quality=quality, nth=nth_chord, direction=direction}.root
  local relative_key = key:relative{scale_index=key:to_scale_index(root)}

  local arp_range = 2 * #scale_indices
  local chord_indices_list = List{
    rangelist(-arp_range,  arp_range, Direction.up  ),
    rangelist( arp_range, -arp_range, Direction.down),
  }
  local chord = Chord{pitches=relative_key[scale_indices]}:inversion(inversion)
  local result = transform(chord_indices_list, function(chord_indices)
    return arpeggiate{chord=chord,
                      duration=1/4,
                      index_pattern=chord_indices}
  end)
  return concatenate(result)
end

local function mario_cadence(tonic)
  local whole_tone_interval = PitchInterval{number=1, semitones=2}
  return List{
    Scale{tonic=tonic,                           mode=Mode.major},
    Scale{tonic=tonic - whole_tone_interval,     mode=Mode.major},
    Scale{tonic=tonic - 2 * whole_tone_interval, mode=Mode.major},
  }
end

local function prelude_arpeggio(tonic, cadence)
  local tetrad = List{0, 1, 2, 4}
  local tetrad7 = List{0, 2, 4, 6}
  return concatenate{
    arpeggio_figure(cadence[1], Quality.major, 0, Direction.up,   tetrad,  0),
    arpeggio_figure(cadence[1], Quality.minor, 0, Direction.down, tetrad,  0),
    arpeggio_figure(cadence[1], Quality.major, 0, Direction.up,   tetrad,  0),
    arpeggio_figure(cadence[1], Quality.minor, 0, Direction.down, tetrad,  0),
    arpeggio_figure(cadence[1], Quality.major, 1, Direction.up,   tetrad, -2),
    arpeggio_figure(cadence[1], Quality.major, 2, Direction.up,   tetrad, -2),
    arpeggio_figure(cadence[2], Quality.major, 0, Direction.up,   tetrad7, 0),
    arpeggio_figure(cadence[3], Quality.major, 0, Direction.up,   tetrad7, 0),
  }
end

local function scale_index_contour_melody(contour, key, scale_offset)
  return transform(contour, function(scale_index)
    return key[scale_index + scale_offset]
  end)
end

local function combine_melody(pitches, rhythm)
  local result = List{}
  local i = 0
  for i=1, min{#pitches, #rhythm} do
    local pitch, duration, volume = pitches[i], rhythm[i], 1.0
    result[i] = Note{pitch=pitch, duration=duration, volume=volume}
  end
  return result
end

local function melody_line(tonic)
  local contourA = {0}

  local contourB = {0, 2}
  local contourC = {0, 1}
  local contourD = {0, -2}

  local contourE = {0, -1, -2, 0}
  local contourF = {0, -1, -2, -3}

  local rhythmA = {4}

  local rhythmB = {2, 2}
  local rhythmC = {3, 1}

  local rhythmD = {1, 1, 1, 1}

  local function helper(contour, rhythm, scale, scale_offset)
    local pitches = scale_index_contour_melody(contour, scale, scale_offset)
    local melody = combine_melody(pitches, rhythm)
    return Figure{duration=sum(rhythm), melody=melody}
  end

  local major = Scale{tonic=tonic, mode=Mode.major}
  local minor = major:parallel(Mode.minor)

  local A = helper(contourA, rhythmA, major, 0)
  local B = helper(contourB, rhythmB, major, -1)
  local C = helper(contourE, rhythmD, major, 1)
  local D = helper(contourF, rhythmD, major, 2)
  local melodyA = repeat_volta(A .. B .. A, {C, D})

  local E = helper(contourA, rhythmA, major, -2)
  local F = helper(contourC, rhythmB, major, -3)
  local G = helper(contourC, rhythmC, major, -1)
  local H = helper(contourD, rhythmB, major, 1)

  local I = helper(contourA, rhythmA, minor, 0)
  local J = helper(contourE, rhythmD, minor, 2)
  local K = helper(contourC, rhythmC, minor, 1)
  local L = helper(contourD, rhythmC, minor, 3)

  local melodyB = E .. F .. G .. H .. I .. J .. K .. L

  return melodyA .. melodyB
end

local song = Song()

local tonic = Pitch.c4
local cadence = mario_cadence(tonic)

arpeggio_channel = song:make_channel(midi.instrument.harpsichord)
arpeggio_channel.figure_instances:insert(
  FigureInstance(0, prelude_arpeggio(tonic, cadence)))

melody_channel = song:make_channel(midi.instrument.choir_aahs)
melody_channel.figure_instances:insert(
  FigureInstance(0, melody_line(tonic)))

local midi_file = tomidifile(song)
local file <close> = io.open('prelude.mid', 'wb')
midi_file:write(file)

--]]
