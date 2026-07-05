# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Contour` type for declaring, classifying, and realizing melodic shapes
  (`musica.contour`), with a contour vocabulary, analysis, and frame
  submodules.
- `musica._VERSION` constant exposing the library version.
- Layer 2 composition helpers: `stamper`, `scale_stamper`, `drum_pattern`,
  `pulse`, `scale_walk`, and `sequence`.
- Procedural generation engine (`musica.generation`) driven by the Z3
  constraint solver, loaded lazily so the core library works without the
  native `lua-z3` binding.

### Fixed

- All unit test suites are now discovered by the test runners and CI, and
  test failures propagate through process exit codes.
- `Song` raises a descriptive error (instead of a bare assertion) when a
  MIDI file contains a `NoteEndEvent` with no matching `NoteBeginEvent`.
- LilyPond export (`Song:tolilypond`) now engraves songs that contain
  notes; previously any non-empty figure raised an indexing error because
  notes store their pitch as a MIDI integer.
- LilyPond key signatures now render minor keys as `\minor` instead of
  always emitting `\major`.

## [0.1.0]

Initial development version: pitches, intervals, scales, chords, modes,
rhythm, meter, tempo, notes, figures, articulations, dynamics, MIDI import
and export, and LilyPond engraving.
