rockspec_format = "3.0"
package = "musica"
version = "scm-1"

source = {
   url = "git://github.com/alexames/musica.git",
   branch = "main",
}

description = {
   summary = "Music theory utilities and algorithmic composition for Lua",
   detailed = [[
A library for music theory operations and algorithmic composition.
Includes pitch, scale, chord, rhythm, and meter representations,
as well as procedural music generation using constraint solving.
   ]],
   homepage = "https://github.com/alexames/musica",
   license = "MIT",
   maintainer = "Alexander Ames <Alexander.Ames@gmail.com>",
   labels = {
      "music",
      "music-theory",
      "composition",
      "algorithmic",
   },
}

dependencies = {
   "lua >= 5.4",
   "llx",
   "lua-midi",
   "lua-z3",
}

test = {
   type = "command",
   command = "cd tests && for f in test_*.lua; do echo \"=== $f ===\"; lua \"$f\" || exit 1; done",
}

build = {
   type = "builtin",
   modules = {
      -- Main entry point
      ["musica"] = "src/init.lua",

      -- Utility
      ["musica.util"] = "src/util/util.lua",
      ["musica.ring"] = "src/util/ring.lua",
      ["musica.spiral"] = "src/util/spiral.lua",

      -- Pitch
      ["musica.accidental"] = "src/pitch/accidental.lua",
      ["musica.direction"] = "src/pitch/direction.lua",
      ["musica.interval_quality"] = "src/pitch/interval_quality.lua",
      ["musica.pitch"] = "src/pitch/pitch.lua",
      ["musica.pitch_class"] = "src/pitch/pitch_class.lua",
      ["musica.pitch_interval"] = "src/pitch/pitch_interval.lua",
      ["musica.pitch_util"] = "src/pitch/pitch_util.lua",

      -- Scale / Harmony
      ["musica.chord"] = "src/scale/chord.lua",
      ["musica.contour"] = "src/scale/contour.lua",
      ["musica.mode"] = "src/scale/mode.lua",
      ["musica.modes"] = "src/scale/modes.lua",
      ["musica.quality"] = "src/scale/quality.lua",
      ["musica.scale"] = "src/scale/scale.lua",
      ["musica.scale_degree"] = "src/scale/scale_degree.lua",
      ["musica.scale_index"] = "src/scale/scale_index.lua",

      -- Rhythm / Time
      ["musica.beat"] = "src/rhythm/beat.lua",
      ["musica.meter"] = "src/rhythm/meter.lua",
      ["musica.rhythm"] = "src/rhythm/rhythm.lua",
      ["musica.tempo"] = "src/rhythm/tempo.lua",
      ["musica.time_signature"] = "src/rhythm/time_signature.lua",

      -- Note / Figure
      ["musica.channel"] = "src/note/channel.lua",
      ["musica.figure"] = "src/note/figure.lua",
      ["musica.note"] = "src/note/note.lua",

      -- Expression
      ["musica.articulation"] = "src/expression/articulation.lua",
      ["musica.dynamics"] = "src/expression/dynamics.lua",

      -- Song / Export
      ["musica.instrument"] = "src/song/instrument.lua",
      ["musica.lilypond"] = "src/song/lilypond.lua",
      ["musica.pattern"] = "src/song/pattern.lua",
      ["musica.song"] = "src/song/song.lua",

      -- Generation
      ["musica.generation"] = "src/generation/init.lua",
      ["musica.generation.context"] = "src/generation/context.lua",
      ["musica.generation.generator"] = "src/generation/generator.lua",
      ["musica.generation.rule"] = "src/generation/rule.lua",
      ["musica.generation.rules"] = "src/generation/rules/init.lua",
      ["musica.generation.rules.boundary"] = "src/generation/rules/boundary.lua",
      ["musica.generation.rules.composite"] = "src/generation/rules/composite.lua",
      ["musica.generation.rules.duration"] = "src/generation/rules/duration.lua",
      ["musica.generation.rules.in_scale"] = "src/generation/rules/in_scale.lua",
      ["musica.generation.rules.interval"] = "src/generation/rules/interval.lua",
      ["musica.generation.rules.monotonic"] = "src/generation/rules/monotonic.lua",
      ["musica.generation.rules.overshoot"] = "src/generation/rules/overshoot.lua",
      ["musica.generation.rules.range"] = "src/generation/rules/range.lua",
      ["musica.generation.rules.volume"] = "src/generation/rules/volume.lua",
   },
}
