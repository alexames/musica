-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Drum pattern builder.
-- Builds drum Figures from independent layers, each with its own
-- pitch (MIDI note), rhythm, and volume.
-- @module musica.drums

local llx = require 'llx'
local figure = require 'musica.figure'
local note = require 'musica.note'
local rhythm_module = require 'musica.rhythm'

local _ENV, _M = llx.environment.create_module_environment()

local Figure = figure.Figure
local isinstance = llx.isinstance
local List = llx.List
local merge = figure.merge
local Note = note.Note
local Rhythm = rhythm_module.Rhythm

--- Build a single-layer Figure from a pitch, rhythm, and volume.
-- When note_duration is provided and rhythm is a Rhythm, the Rhythm durations
-- are treated as inter-onset intervals and note_duration sets the actual length.
local function build_layer(layer, fig_duration)
  local pitch = layer.pitch
  local volume = layer.volume or 1.0
  local rhythm = layer.rhythm
  local note_duration = layer.note_duration
  local notes = List{}

  if isinstance(rhythm, Rhythm) then
    local time = 0
    for _, dur in ipairs(rhythm.durations) do
      notes:insert(Note{pitch=pitch, time=time,
                        duration=note_duration or dur, volume=volume})
      time = time + dur
    end
  elseif type(rhythm) == 'table' then
    -- Explicit {time, duration} pairs
    for _, entry in ipairs(rhythm) do
      local t = entry.time or entry[1]
      local d = note_duration or entry.duration or entry[2]
      notes:insert(Note{pitch=pitch, time=t, duration=d, volume=volume})
    end
  else
    error('drum_pattern: layer rhythm must be a Rhythm or list of {time, duration}', 3)
  end

  return Figure{duration=fig_duration, notes=notes}
end

--- Create a drum Figure from independent layers.
-- Each layer specifies a drum sound (pitch), rhythm, and volume.
-- All layers are merged into a single Figure.
--
-- @tparam table args Table with fields:
--   layers: list of {pitch=number, rhythm=Rhythm, volume=number} tables
--   duration: figure duration in beats (default 4)
-- @treturn Figure
function drum_pattern(args)
  local layers = args.layers
  local fig_duration = args.duration or 4

  if #layers == 0 then
    return Figure{duration=fig_duration, notes={}}
  end

  local figures = List{}
  for _, layer in ipairs(layers) do
    figures:insert(build_layer(layer, fig_duration))
  end

  -- Merge all layers
  local result = figures[1]
  for i = 2, #figures do
    result = result + figures[i]
  end
  return result
end

return _M
