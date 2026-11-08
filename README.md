# musica

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

- [Lua](https://www.lua.org/) 5.1 through 5.5, or [LuaJIT](https://luajit.org/) 2.x
- [llx](https://github.com/alexames/llx) >= 3.0 -- Lua extensions library
- [lua-midi](https://github.com/alexames/lua-midi) >= 1.1 -- MIDI file I/O
- [lua-z3](https://github.com/alexames/lua-z3) -- Z3 constraint solver bindings (for generation)

`musica-scm-1.rockspec` declares Lua 5.1 through 5.5;
`musica-luajit-scm-1.rockspec` ships the same modules against LuaJIT,
`llx-luajit` and `lua-midi-luajit`.

## Supported Lua Versions

musica runs unchanged on Lua 5.1, 5.2, 5.3, 5.4, 5.5 and LuaJIT. Its
sources are written in the Lua 5.1 syntax subset and reach what differs
between versions through `llx.compat`. `tests/test_portability.lua` fails on
any source that uses syntax or a library name one of those interpreters
lacks; tests that need Lua 5.3 syntax live in `tests/lua53/`.

Two things differ for code that uses musica on Lua 5.1 or LuaJIT:

- Those interpreters ignore `__len` on tables, so `#chord`, `#scale`,
  `#mode`, `#quality`, `#rhythm`, `#meter` and the rest read 0 there. Use
  `compat.len(value)` from `llx.compat`, which honours `__len` everywhere.
- `mode << n` and `mode >> n` need the Lua 5.3 operators. Use
  `mode:rotate_left(n)` and `mode:rotate_right(n)`, which work everywhere.

## Documentation

API documentation is generated with [LDoc](https://github.com/lunarmodules/LDoc)
and published to [GitHub Pages](https://alexames.github.io/musica).

To generate locally:

```sh
luarocks install ldoc
ldoc .
```

## Running Tests

```sh
cd tests
lua5.4 test_core_music.lua
```

## License

[MIT](LICENSE)
