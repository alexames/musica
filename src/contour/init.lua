-- Copyright 2024 Alexander Ames <Alexander.Ames@gmail.com>

--- Contour: describe, classify, and realize melodic shapes.
--
-- A Contour is a declarative description of a melody's MOVEMENT (an arc up then
-- down, a stepwise walk to a target, a neighbour turn, a repeated pedal, ...),
-- independent of absolute pitch. The same contour can describe many melodies.
-- Contours can:
--   * score/match an existing melody (classification) -- see `analysis` for the
--     extraction substrate and `contour` for the Contour type,
--   * realize() into concrete notes when fully specified (a `ContourFrame`
--     supplies scale/anchors/rhythm),
--   * (designed, z3-backed) compile to generation Rules so a solver can produce
--     melodies matching the shape.
--
-- This module flattens its submodules; the original analysis functions
-- (directional_contour, relative_contour, ...) remain available here for
-- backward compatibility.
-- @module musica.contour

local llx = require 'llx'

local lock <close> = llx.lock_global_table()

return require 'llx.flatten_submodules' {
  require 'musica.contour.analysis',
  require 'musica.contour.frame',
  require 'musica.contour.contour',
  require 'musica.contour.sequence',
  require 'musica.contour.vocabulary',
}
