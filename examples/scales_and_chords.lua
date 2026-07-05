-- Basic music theory operations: pitches, intervals, scales, and chords.
--
-- Run from the repository root:
--   .\lua.bat examples\scales_and_chords.lua     (Windows)
--   lua examples/scales_and_chords.lua           (with musica installed)

local musica = require 'musica'

local Pitch = musica.Pitch
local PitchInterval = musica.PitchInterval
local Scale = musica.Scale
local Mode = musica.Mode
local Chord = musica.Chord
local Quality = musica.Quality

-- Pitches are named constants; arithmetic works with intervals.
local middle_c = Pitch.c4
print('middle C:        ' .. tostring(middle_c))
print('up a major 3rd:  ' .. tostring(middle_c + PitchInterval.major_third))
print('up an octave:    ' .. tostring(middle_c + PitchInterval.octave))
print('E4 - C4:         ' .. tostring(Pitch.e4 - Pitch.c4))

-- Scales are built from a tonic and a mode, and index like arrays:
-- index 0 is the tonic, positive and negative indices walk the scale.
local c_major = Scale{tonic = middle_c, mode = Mode.major}
print('\nC major scale:')
for i = 0, 7 do
  io.write('  ' .. tostring(c_major[i]))
end
print()

print('two below tonic: ' .. tostring(c_major[-2]))
print('contains F#4?    ' .. tostring(c_major:contains(Pitch.fsharp4)))

-- The relative minor shares every pitch with its major scale.
local a_minor = c_major:relative{mode = Mode.minor}
print('relative minor:  ' .. tostring(a_minor))

-- Chords are a root plus a quality and index like scales; extended
-- indices keep stacking thirds past the top of the triad.
local c_major_chord = Chord{root = middle_c, quality = Quality.major}
print('\nC major triad:')
for i = 0, 2 do
  io.write('  ' .. tostring(c_major_chord[i]))
end
print()
print('extended index 3 (root, octave up): '
  .. tostring(c_major_chord:to_extended_pitch(3)))

-- Inversions rotate the chord tones.
local first_inversion = c_major_chord:inversion(1)
print('1st inversion lowest tone: ' .. tostring(first_inversion[0]))
