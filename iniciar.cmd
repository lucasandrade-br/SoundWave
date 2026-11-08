@echo off
setlocal
pushd "%~dp0"

rem Usa o SDK preparado para este projeto, sem alterar o PATH do Windows.
if exist "C:\Tools\Flutter\bin\flutter.bat" (
  set "PATH=C:\Tools\Flutter\bin;%PATH%"
)

where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter nao encontrado. Consulte o guia de ambiente em Idealizacao.
  popd
  pause
  exit /b 1
)

call flutter run -d chrome --web-hostname=127.0.0.1 --web-port=8080
set "soundwaveExitCode=%ERRORLEVEL%"
popd
if not "%soundwaveExitCode%"=="0" pause
exit /b %soundwaveExitCode%
