@echo off
setlocal
set "LUAROCKS_SYSCONFDIR=src"
"C:\Users\Alexa\bin\luarocks.exe" --project-tree C:\Users\Alexa\Programming\musica\lua_modules %*
exit /b %ERRORLEVEL%
