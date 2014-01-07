@echo off
setlocal EnableDelayedExpansion

set p=%~dp0
set w=%p%\wget.exe
set s=%p%\sed.exe
set z=%p%\7z.exe
set c=%p%\certutil.exe
set vb=%temp%\vb
set i=%vb%\1.index.log
set e=%vb%\2.url.log
set d=%~dp0VirtualBox
set h=https://www.virtualbox.org/wiki/Downloads
set sw=HKLM\SOFTWARE
set u=Microsoft\Windows\CurrentVersion\Uninstall
set k={08FD61E2-0BCC-424D-8F26-4FC4864B0440}


reg query "%sw%\%u%\%k%" > nul 2>&1

if !errorlevel!==0 goto ok

if not exist "%vb%" md "%vb%"
if not exist "%d%" md "%d%"
:dl
if not exist "%d%\VirtualBox*-Win.exe" (
"%w%" --no-check-certificate "%h%" -O "%i%"
"%s%" "s/\d034/\n/g" "%i%" | "%s%" -n "/.exe/p" > "%e%"
for /f "tokens=*" %%a in ('type "%e%"') do (
"%w%" -P "%d%" --no-check-certificate "%%a"
)
)
"%z%" x "%d%\VirtualBox*-Win.exe" -o"%vb%" -y
if not !errorlevel!==0 (
del "%d%\VirtualBox*-Win.exe"
goto dl
)
"%z%" x "%vb%\*.iso" -o"%vb%" -y
xcopy /i /c /r /s /y "%vb%\cert\*.cer" "%d%"

if not exist "%~dp0certutil.exe" (
wget http://download.microsoft.com/download/c/7/5/c750f1af-8940-44b6-b9eb-d74014e552cd/adminpak.exe
7z e "%~dp0adminpak.exe" i adminpak.msi -O"%~dp0"
7z e "%~dp0adminpak.msi" i certutil.exe certadm.dll -O"%~dp0"
del "%~dp0adminpak.exe" /Q /F
del "%~dp0adminpak.msi" /Q /F
)

"%c%" -addstore "TrustedPublisher" "%d%\oracle-vbox.cer"
for /f "delims=" %%f in ('dir /b "%d%\VirtualBox-*-Win.exe"') DO (
"%d%\%%f" -s
)

rd "%vb%" /Q /S
:ok

endlocal
