-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Stamper: the universal "pitches + rhythm -> Figure" builder.
-- Provides stamper() and scale_stamper() for creating Figures from
-- pitch lists and rhythmic templates.
-- @module musica.stamper

local llx = require 'llx'
local figure = require 'musica.figure'
local note = require 'musica.note'
local rhythm_module = require 'musica.rhythm'

local _ENV, _M = llx.environment.create_module_environment()

local Figure = figure.Figure
local isinstance = llx.isinstance
local List = llx.List
local Note = note.Note
local Rhythm = rhythm_module.Rhythm

--- Build time/duration pairs from a Rhythm (durations placed sequentially).
local function rhythm_to_time_pairs(rhythm)
  local pairs = List{}
  local time = 0
  for _, dur in ipairs(rhythm.durations) do
    pairs:insert({time=time, duration=dur})
    time = time + dur
  end
  return pairs, time
end

--- Build time/duration pairs from an explicit list of {time, duration} tables.
local function explicit_to_time_pairs(rhythm_list)
  local pairs = List{}
  local max_end = 0
  for _, entry in ipairs(rhythm_list) do
    local t = entry.time or entry[1]
    local d = entry.duration or entry[2]
    pairs:insert({time=t, duration=d})
    local e = t + d
    if e > max_end then max_end = e end
  end
  return pairs, max_end
end

--- Parse rhythm argument into time/duration pairs and total duration.
local function parse_rhythm(rhythm)
  if isinstance(rhythm, Rhythm) then
    return rhythm_to_time_pairs(rhythm)
  elseif type(rhythm) == 'table' then
    return explicit_to_time_pairs(rhythm)
  else
    error('stamper: rhythm must be a Rhythm or a list of {time, duration}', 3)
  end
end

--- Resolve volume for a given note index.
local function resolve_volume(volume, index)
  if volume == nil then
    return 1.0
  elseif type(volume) == 'number' then
    return volume
  elseif type(volume) == 'table' then
    return volume[((index - 1) % #volume) + 1]
  end
  return 1.0
end

--- Create a Figure by stamping pitches across a rhythmic template.
--
-- @tparam table args Table with fields:
--   pitches: list of Pitch values
--   rhythm: Rhythm object or list of {time, duration} tables
--   volume: number or list of numbers (0.0-1.0), default 1.0
--   note_duration: when set, overrides durations from rhythm (rhythm durations
--                  become inter-onset intervals only)
--   mode: "sequential" (one pitch per slot, default),
--         "simultaneous" (all pitches at each slot),
--         "cycle" (cycle through pitches across slots)
--   duration: figure duration (default: end of last note)
-- @treturn Figure
function stamper(args)
  local pitches = args.pitches
  local volume = args.volume
  local note_dur = args.note_duration
  local mode = args.mode or 'sequential'
  local time_pairs, computed_duration = parse_rhythm(args.rhythm)
  local fig_duration = args.duration or computed_duration

  local notes = List{}

  if mode == 'sequential' then
    -- One pitch per rhythm slot, 1:1 mapping
    for i, tp in ipairs(time_pairs) do
      local pitch = pitches[((i - 1) % #pitches) + 1]
      notes:insert(Note{pitch=pitch, time=tp.time,
                        duration=note_dur or tp.duration,
                        volume=resolve_volume(volume, i)})
    end
  elseif mode == 'simultaneous' then
    -- All pitches at each rhythm slot
    local note_index = 0
    for i, tp in ipairs(time_pairs) do
      for j, pitch in ipairs(pitches) do
        note_index = note_index + 1
        notes:insert(Note{pitch=pitch, time=tp.time,
                          duration=note_dur or tp.duration,
                          volume=resolve_volume(volume, note_index)})
      end
    end
  elseif mode == 'cycle' then
    -- Cycle through pitches across rhythm slots
    for i, tp in ipairs(time_pairs) do
      local pitch = pitches[((i - 1) % #pitches) + 1]
      notes:insert(Note{pitch=pitch, time=tp.time,
                        duration=note_dur or tp.duration,
                        volume=resolve_volume(volume, i)})
    end
  else
    error('stamper: unknown mode "' .. tostring(mode) .. '"', 2)
  end

  return Figure{duration=fig_duration, notes=notes}
end

--- Create a Figure by stamping scale degrees across a rhythmic template.
-- Like stamper(), but takes a Scale and list of scale-degree indices
-- instead of absolute pitches. Resolves indices through the Scale.
--
-- @tparam table args Table with fields:
--   scale: Scale object
--   indices: list of scale degree integers
--   rhythm: Rhythm object or list of {time, duration} tables
--   volume: number or list of numbers (0.0-1.0), default 1.0
--   mode: "sequential" (default), "simultaneous", "cycle"
--   duration: figure duration (default: end of last note)
-- @treturn Figure
function scale_stamper(args)
  local scale = args.scale
  local indices = args.indices
  local pitches = List{}
  for i, idx in ipairs(indices) do
    pitches[i] = scale[idx]
  end
  return stamper{
    pitches=pitches,
    rhythm=args.rhythm,
    volume=args.volume,
    mode=args.mode,
    duration=args.duration,
  }
end

return _M
