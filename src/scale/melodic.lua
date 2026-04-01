-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Melodic generators.
-- Provides functions that produce pitch sequences (as lists of scale indices)
-- for use with scale_stamper and other composition tools.
-- @module musica.melodic

local llx = require 'llx'

local _ENV, _M = llx.environment.create_module_environment()

local List = llx.List

--- Generate a stepwise walk between two scale degrees.
-- Returns a list of scale indices from 'from' to 'to' (inclusive).
--
-- @tparam table args Table with fields:
--   from: starting scale index
--   to: ending scale index
--   step: step size in scale degrees (default 1, sign auto-adjusted)
-- @treturn table List of scale indices
function scale_walk(args)
  local from = args.from or args[1]
  local to = args.to or args[2]
  local step = args.step or 1

  -- Auto-adjust step direction
  if from < to then
    step = math.abs(step)
  elseif from > to then
    step = -math.abs(step)
  else
    return List{from}
  end

  local indices = List{}
  local i = from
  if step > 0 then
    while i <= to do
      indices:insert(i)
      i = i + step
    end
  else
    while i >= to do
      indices:insert(i)
      i = i + step
    end
  end

  -- Ensure the final index is included
  if indices[#indices] ~= to then
    indices:insert(to)
  end

  return indices
end

--- Generate a melodic sequence: repeat a pattern of relative scale offsets
-- at successive starting degrees.
--
-- @tparam table args Table with fields:
--   pattern: list of relative scale offsets (e.g., {0, -2, -4})
--   starts: list of scale indices to start from (e.g., {9, 7, 5})
-- @treturn table Flat list of scale indices
function sequence(args)
  local pattern = args.pattern
  local starts = args.starts
  local indices = List{}
  for _, start in ipairs(starts) do
    for _, offset in ipairs(pattern) do
      indices:insert(start + offset)
    end
  end
  return indices
end

return _M
