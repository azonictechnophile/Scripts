@echo off

rem -----------------------------------
rem Turn Wireguard on or off with menu
rem -----------------------------------

SETLOCAL
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
)

rem ----------------------------------
rem Adjustable variables
rem ----------------------------------
SET INTERFACE=wg1
SET WGPATH="C:\Program Files\WireGuard"

:MENU
echo =================================
%WGPATH%\wg show|find "%INTERFACE%" > NUL
IF ERRORLEVEL 1 ( echo Wireguard tunnel is %ESC%[91mDOWN%ESC%[0m ) else ( echo Wireguard tunnel is %ESC%[92mUP%ESC%[0m )
echo.
echo 1 - Enable Tunnel
echo 2 - Disable Tunnel
echo 3 - Exit
echo.
echo =================================
set /P SELECTION=Type 1, 2, or 3 then press Enter:
IF %SELECTION%==1 GOTO ENABLE
IF %SELECTION%==2 GOTO DISABLE
IF %SELECTION%==3 GOTO EOF

:ENABLE
%WGPATH%\wireguard /installtunnelservice %WGPATH%\%INTERFACE%.conf
timeout /t 2 /nobreak > NUL
GOTO MENU

:DISABLE
%WGPATH%\wireguard /uninstalltunnelservice %INTERFACE%
timeout /t 2 /nobreak > NUL
GOTO MENU

:EOF
