@echo off
setlocal EnableDelayedExpansion

set path=%path%;%~dp0
set vb=%temp%\vb

:dl
if not exist "%~dp0VirtualBox*-Win.exe" (
for /f "tokens=*" %%a in ('^
wget -qO- --no-check-certificate ^
https://www.virtualbox.org/wiki/Downloads ^|
sed "s/\d034/\n/g" ^|
sed -n "/.exe/p"') do (
wget %%a --directory-prefix "%~dp0\"
)
)
echo chech if file has good consistence
7z x "%~dp0VirtualBox*-Win.exe" -o"%vb%" -y
if not !errorlevel!==0 (
del "%~dp0VirtualBox*-Win.exe"
goto dl
)

7z x "%vb%\*.iso" -o"%vb%" -y
xcopy /i /c /r /s /y "%vb%\cert\*.cer" "%~dp0"

if not exist "%~dp0certutil.exe" (
wget http://download.microsoft.com/download/c/7/5/c750f1af-8940-44b6-b9eb-d74014e552cd/adminpak.exe
7z e "%~dp0adminpak.exe" i adminpak.msi -O"%~dp0"
7z e "%~dp0adminpak.msi" i certutil.exe certadm.dll -O"%~dp0"
del "%~dp0adminpak.exe" /Q /F
del "%~dp0adminpak.msi" /Q /F
)

certutil -addstore "TrustedPublisher" "%~dp0oracle-vbox.cer"
for /f "delims=" %%f in ('dir /b "%~dp0VirtualBox-*-Win.exe"') DO (
"%~dp0%%f" -s
)

rd "%vb%" /Q /S

endlocal
