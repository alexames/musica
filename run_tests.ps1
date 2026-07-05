Set-Location $PSScriptRoot

# Discover lua-z3 sibling project for local generation tests.
# In CI, lua-z3 is installed via luarocks. Locally, we use the sibling
# lua-z3 project's Lua 5.4 build: rock/z3.lua wraps the native module
# (z3_native.dll), which needs libz3.dll from the vcpkg install tree on PATH.
$luaZ3Root = Join-Path $PSScriptRoot "..\lua-z3"
$z3NativeDir = Join-Path $luaZ3Root "build\lua54\Source\z3\Release"
if (Test-Path (Join-Path $z3NativeDir "z3_native.dll")) {
  $env:PATH = "$luaZ3Root\build\vcpkg_installed\x64-windows\bin;$env:PATH"
  if ($env:LUA_CPATH) {
    $env:LUA_CPATH = "$z3NativeDir\?.dll;$env:LUA_CPATH"
  } else {
    $env:LUA_CPATH = "$z3NativeDir\?.dll;;"
  }
  if ($env:LUA_PATH) {
    $env:LUA_PATH = "$luaZ3Root\rock\?.lua;$env:LUA_PATH"
  } else {
    $env:LUA_PATH = "$luaZ3Root\rock\?.lua;;"
  }
}

$tests = Get-ChildItem tests\test_*.lua
$failed = 0
foreach ($f in $tests) {
  Write-Host "=== $($f.Name) ==="
  & .\lua.bat $f.FullName
  if ($LASTEXITCODE -ne 0) { $failed++ }
}
if ($failed -gt 0) {
  Write-Host "`n$failed test file(s) FAILED" -ForegroundColor Red
  exit 1
} else {
  Write-Host "`nAll test files passed" -ForegroundColor Green
}
