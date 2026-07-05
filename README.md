# musica

[![CI](https://github.com/alexames/musica/actions/workflows/ci.yml/badge.svg)](https://github.com/alexames/musica/actions/workflows/ci.yml)
[![Docs](https://github.com/alexames/musica/actions/workflows/docs.yml/badge.svg)](https://alexames.github.io/musica)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Music theory utilities and algorithmic composition for Lua.

Provides data structures and operations for pitches, scales, chords, rhythm,
meter, and more. Includes a procedural music generation engine powered by
constraint solving with [Z3](https://github.com/Z3Prover/z3).

## Installation

```sh
luarocks install --server=https://alexames.github.io/luarocks-repository musica
```

## Usage

```lua
local musica = require 'musica'

local pitch = musica.Pitch('C4')
local scale = musica.Scale(pitch, musica.Mode.MAJOR)
local chord = musica.Chord(pitch, musica.Quality.MAJOR)
```

## Dependencies

- [Lua](https://www.lua.org/) >= 5.4
- [llx](https://github.com/alexames/llx) -- Lua extensions library
- [lua-midi](https://github.com/alexames/lua-midi) -- MIDI file I/O
- [lua-z3](https://github.com/alexames/lua-z3) -- Z3 constraint solver bindings (for generation)

## Documentation

API documentation is generated with [LDoc](https://github.com/lunarmodules/LDoc)
and published to [GitHub Pages](https://alexames.github.io/musica).

To generate locally:

```sh
luarocks install ldoc
ldoc .
```

## Running Tests

On Windows, `run_tests.ps1` installs the working tree and runs every suite:

```powershell
.\run_tests.ps1
```

On any platform, individual suites run directly:

```sh
cd tests
lua5.4 test_pitch.lua
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, test, and PR
guidelines. Notable changes are tracked in [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](LICENSE)
