-- LDoc configuration for musica
-- Run with: ldoc .

project = 'musica'
title = 'musica - Music Theory Library'
description = [[
A music theory library for Lua providing data structures and utilities for working
with musical concepts like pitches, scales, chords, rhythm, and composition.
]]

-- Source files
file = 'src'

-- Output directory
dir = 'docs'

-- Use markdown for descriptions
format = 'markdown'

-- Sort alphabetically
sort = true

-- Include all documented items
all = true

-- Template style
style = nil
template = nil

-- Package display name
package = ''

-- One file per module
one = false

-- Show source code links
no_return_or_parms = false
no_summary = false

-- Merge modules into single pages
merge = false

-- Custom tags
custom_tags = {
  {'example', title = 'Example', format = nil},
  {'usage', title = 'Usage', format = nil},
}
