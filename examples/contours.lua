-- Declaring melodic shapes with contours and realizing them as figures.
--
-- Run from the repository root:
--   .\lua.bat examples\contours.lua     (Windows)
--   lua examples/contours.lua           (with musica installed)

local llx = require 'llx'
local musica = require 'musica'
local contour = require 'musica.contour'

local Pitch = musica.Pitch
local Scale = musica.Scale
local Mode = musica.Mode
local Rhythm = musica.Rhythm
local tointeger = llx.tointeger

-- A contour describes the *shape* of a melody independent of any scale;
-- a ContourFrame supplies the musical context (scale, anchor degree, and
-- a rhythm with one slot per note) needed to realize it.
local scale = Scale{tonic = Pitch.c4, mode = Mode.major}

local function quarters(n)
  local durations = {}
  for i = 1, n do durations[i] = 1 end
  return Rhythm(durations)
end

local function describe_figure(label, figure)
  io.write(label .. ':')
  for i = 1, #figure.notes do
    io.write(' ' .. tointeger(figure.notes[i].pitch))
  end
  print()
end

-- Walk up the scale from the anchor to the 5th degree: C D E F G.
local ascent = contour.ascend_to{to = 4}:realize(
  contour.ContourFrame{scale = scale, anchor = 0, rhythm = quarters(5)})
describe_figure('ascend_to 4', ascent)

-- Rise to a peak, then fall back: C D E F G F E D C.
local arch = contour.arc{from = 0, peak = 4, to = 0}:realize(
  contour.ContourFrame{scale = scale, rhythm = quarters(9)})
describe_figure('arc 0-4-0 ', arch)

-- Repeat one degree in every rhythm slot (a pedal tone).
local pedal = contour.pedal{degree = 0}:realize(
  contour.ContourFrame{scale = scale, anchor = 0, rhythm = quarters(4)})
describe_figure('pedal 0   ', pedal)
