# Contributing to musica

Thanks for your interest in contributing! This document explains how to set
up a development environment, run the tests, and submit changes.

## Development setup

Requirements:

- [Lua](https://www.lua.org/) 5.4
- [LuaRocks](https://luarocks.org/) 3.x

Clone the repository and install the dependencies into a project-local tree:

```sh
git clone https://github.com/alexames/musica.git
cd musica
luarocks init
luarocks install --server=https://alexames.github.io/luarocks-repository llx
luarocks install --server=https://alexames.github.io/luarocks-repository lua-midi
luarocks make --deps-mode=none
```

`luarocks init` creates project-local `lua` and `luarocks` wrappers plus a
`lua_modules/` tree (all gitignored). `luarocks make` installs the working
tree into `lua_modules` — rerun it after changing files under `src/` so the
wrappers pick up your changes.

### Optional: the generation engine (Z3)

`musica.generation` depends on [lua-z3](https://github.com/alexames/lua-z3),
a native binding that is ABI-bound to the host Lua and distributed
separately. The core library installs and runs without it; only
`tests/test_generator.lua` and `tests/test_rules.lua` need it. On Windows,
`run_tests.ps1` automatically discovers a sibling `../lua-z3` checkout with
a built Lua 5.4 module.

## Running the tests

On Windows:

```powershell
.\run_tests.ps1
```

This reinstalls the working tree into `lua_modules`, then runs every
`tests/test_*.lua` file. Any file can also be run on its own:

```powershell
.\lua.bat tests\test_pitch.lua
```

Or via LuaRocks on any platform:

```sh
luarocks test
```

Tests use the `llx.unit` framework (`describe` / `it` / `expect`). Every
test file ends with:

```lua
if main_file() then
  os.exit(unit.run_unit_tests() == 0)
end
```

so that failures propagate through the process exit code — keep this footer
in new test files.

## Linting

CI runs [luacheck](https://github.com/lunarmodules/luacheck) with the
configuration in `.luacheckrc`:

```sh
luacheck src tests
```

Style basics (enforced by `.editorconfig` / `.luacheckrc`): two-space
indentation, 80-column lines, single-quoted strings, and the `llx` module
pattern (`local _ENV, _M = llx.environment.create_module_environment()`).

## Submitting changes

1. Fork and create a topic branch from `main`.
2. Make your change, including tests. Bug fixes should come with a test
   that would have caught the bug.
3. Update `CHANGELOG.md` under `[Unreleased]` for user-visible changes.
4. Make sure the test suite passes and luacheck is clean.
5. Open a pull request describing what changed and why.

New modules must be registered in two places: the rockspec `build.modules`
table and (if part of the core API) the `flatten_submodules` list in
`src/init.lua`.
