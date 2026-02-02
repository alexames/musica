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

build = {
   type = "builtin",
   modules = {
      ["musica"] = "init.lua",
      ["musica.accidental"] = "accidental.lua",
      ["musica.articulation"] = "articulation.lua",
      ["musica.beat"] = "beat.lua",
      ["musica.channel"] = "channel.lua",
      ["musica.chord"] = "chord.lua",
      ["musica.contour"] = "contour.lua",
      ["musica.direction"] = "direction.lua",
      ["musica.dynamics"] = "dynamics.lua",
      ["musica.figure"] = "figure.lua",
      ["musica.instrument"] = "instrument.lua",
      ["musica.interval_quality"] = "interval_quality.lua",
      ["musica.lilypond"] = "lilypond.lua",
      ["musica.meter"] = "meter.lua",
      ["musica.mode"] = "mode.lua",
      ["musica.modes"] = "modes.lua",
      ["musica.note"] = "note.lua",
      ["musica.pattern"] = "pattern.lua",
      ["musica.pitch"] = "pitch.lua",
      ["musica.pitch_class"] = "pitch_class.lua",
      ["musica.pitch_interval"] = "pitch_interval.lua",
      ["musica.pitch_util"] = "pitch_util.lua",
      ["musica.quality"] = "quality.lua",
      ["musica.rhythm"] = "rhythm.lua",
      ["musica.ring"] = "ring.lua",
      ["musica.scale"] = "scale.lua",
      ["musica.scale_degree"] = "scale_degree.lua",
      ["musica.scale_index"] = "scale_index.lua",
      ["musica.song"] = "song.lua",
      ["musica.spiral"] = "spiral.lua",
      ["musica.tempo"] = "tempo.lua",
      ["musica.time_signature"] = "time_signature.lua",
      ["musica.transformations"] = "transformations.lua",
      ["musica.util"] = "util.lua",
      ["musica.generation"] = "generation/init.lua",
      ["musica.generation.context"] = "generation/context.lua",
      ["musica.generation.generator"] = "generation/generator.lua",
      ["musica.generation.rule"] = "generation/rule.lua",
      ["musica.generation.rules"] = "generation/rules/init.lua",
      ["musica.generation.rules.boundary"] = "generation/rules/boundary.lua",
      ["musica.generation.rules.composite"] = "generation/rules/composite.lua",
      ["musica.generation.rules.duration"] = "generation/rules/duration.lua",
      ["musica.generation.rules.in_scale"] = "generation/rules/in_scale.lua",
      ["musica.generation.rules.interval"] = "generation/rules/interval.lua",
      ["musica.generation.rules.monotonic"] = "generation/rules/monotonic.lua",
      ["musica.generation.rules.overshoot"] = "generation/rules/overshoot.lua",
      ["musica.generation.rules.range"] = "generation/rules/range.lua",
      ["musica.generation.rules.volume"] = "generation/rules/volume.lua",
   },
}
