local midi = require 'midi'
require 'song'

local function arpeggio_figure(key, quality, nth_chord, direction, scale_indices, inversion)
  local root = find_chord(key, quality, nth_chord, direction=direction).root
  local relative_key = key.relative(scale_index=key.to_scale_index(root))

  local chord_size = len(scale_indices)
  local arp_range = 2 * chord_size
  local chord_indices_list = [range(-arp_range,  arp_range,   up),
                      range( arp_range, -arp_range, down)]
  local result = {}
  for i, v in ipairs(chord_indices_list) do
    result[i] = arpeggiate(
        Chord{pitches=relative_key[scale_indices]}:inversion(inversion),
        duration=1/4,
        index_pattern=chord_indices)
  end
  return concatenate(result)
end

local function prelude_arpeggio()
  local c_major_scale = Scale(tonic=Pitch.c4, mode=Mode.major)
  local a_flat_major_scale = Scale(tonic=Pitch.a_flat4, mode=Mode.major)
  local b_flat_major_scale = Scale(tonic=Pitch.b_flat4, mode=Mode.major)

  local tetrad = {0, 1, 2, 4}
  local tetrad7 = {0, 2, 4, 6}

  local up = Direction.up
  local down = Direction.down

  return concatenate{
      arpeggio_figure(     c_major_scale, Quality.major, 0,   up, tetrad,  0),
      arpeggio_figure(     c_major_scale, Quality.minor, 0, down, tetrad,  0),
      arpeggio_figure(     c_major_scale, Quality.major, 0,   up, tetrad,  0),
      arpeggio_figure(     c_major_scale, Quality.minor, 0, down, tetrad,  0),
      arpeggio_figure(     c_major_scale, Quality.major, 1,   up, tetrad, -2),
      arpeggio_figure(     c_major_scale, Quality.major, 2,   up, tetrad, -2),
      arpeggio_figure(a_flat_major_scale, Quality.major, 0,   up, tetrad7, 0),
      arpeggio_figure(b_flat_major_scale, Quality.major, 0,   up, tetrad7, 0),
  }
end

local function scale_index_contour_melody(contour, key, scale_offset)
  return [key[scale_index + scale_offset] for scale_index in contour]
end

local function combine_melody(pitches=produce_value(None),
                  rhythm=produce_value(None),
                  dynamics=produce_value(None))
  return [Note(pitch=pitch, duration=duration, volume=volume)
          for pitch, duration, volume in zip(pitches, rhythm, dynamics)]
end


local function melody_line()
  local contourA = [0]

  local contourB = [0, 2]
  local contourC = [0, 1]
  local contourD = [0, -2]

  local contourE = [0, -1, -2, 0]
  local contourF = [0, -1, -2, -3]

  local rhythmA = [4]

  local rhythmB = [2, 2]
  local rhythmC = [3, 1]

  local rhythmD = [1, 1, 1, 1]

  local function helper(contour, rhythm, scale, scale_offset)
    local pitches = scale_index_contour_melody(contour, scale, scale_offset)
    local melody = combine_melody(pitches, rhythm)
    return Figure(duration=sum(rhythm), melody=melody)
  end

  local major = Scale(tonic=Pitch.c4, mode=Mode.major)
  local minor = major.parallel(mode=Mode.minor)

  local A = helper(contourA, rhythmA, major, 0)
  local B = helper(contourB, rhythmB, major, -1)
  local C = helper(contourE, rhythmD, major, 1)
  local D = helper(contourF, rhythmD, major, 2)
  local melodyA = repeat_figure(A * B * A, endings=[C, D])

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

song = Song(2)

arpeggio_section = song.make_section([(common_meter, 16)])
arpeggio_section.add_parts([prelude_arpeggio()])

melody_section = song.make_section([(common_meter, 16)])
melody_section.add_parts([prelude_arpeggio(), melody_line()])

song.append_section(arpeggio_section)
song.append_section(melody_section)

local channel
channel = song:make_channel(midi.instrument.acoustic_guitar_nylon)
channel.figure_instances:insert(FigureInstance(0, figure))

channel = song:make_channel(midi.instrument.acoustic_guitar_steel)
channel.figure_instances:insert(FigureInstance(0, chords))

channel = song:make_channel(midi.instrument.acoustic_bass)
channel.figure_instances:insert(FigureInstance(0, bass))

channel = song:make_channel(midi.instrument.trumpet)
channel.figure_instances:insert(FigureInstance(0, trumpet))

local midi_file = tomidifile(song)
local file <close> = io.open('prelude.mid', 'wb')
midi_file:write(file)

print(tostring(song))