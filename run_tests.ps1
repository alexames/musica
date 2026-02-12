Set-Location $PSScriptRoot

# Discover lua-z3 sibling project for local generation tests.
# In CI, lua-z3 is installed via luarocks. Locally, we look for the pre-built
# Lua 5.4 DLL in the sibling lua-z3 project's build directory.
$luaZ3Build = Join-Path $PSScriptRoot "..\lua-z3\build\lua54"
if (Test-Path $luaZ3Build) {
  $env:PATH = "$luaZ3Build\vcpkg_installed\x64-windows\bin;$env:PATH"
  $z3Cpath = "$luaZ3Build\Source\z3\Release\?.dll"
  if ($env:LUA_CPATH) {
    $env:LUA_CPATH = "$z3Cpath;$env:LUA_CPATH"
  } else {
    $env:LUA_CPATH = "$z3Cpath;;"
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
