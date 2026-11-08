@echo off
setlocal
pushd "%~dp0"
python tools\present_local.py
set "soundwavePresentationCode=%ERRORLEVEL%"
popd
if not "%soundwavePresentationCode%"=="0" pause
exit /b %soundwavePresentationCode%
