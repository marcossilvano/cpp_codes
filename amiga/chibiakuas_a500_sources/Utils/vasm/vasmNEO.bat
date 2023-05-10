@echo off 
if not exist \Emu\mame0200b_32bit\mame.exe goto EmulatorFail

set BuildFile=%1
set BuildPath=%2
if exist \utils\SelectedBuildFile.bat call \utils\SelectedBuildFile.bat 

cd %BuildPath%
if not %BuildPath:~0,1%==%CD:~0,1% goto InvalidPath


if not exist \RelNEO\roms\neogeo.zip goto MissingRom

\Utils\Vasm\vasmm68k_mot_win32.exe %BuildFile% -chklabels -nocase -Fbin -m68000 -no-opt -Dvasm=1  -L \BldNEO\Listing.txt -DBuildNEO=1 -o "\BldNEO\cart.p"

if not "%errorlevel%"=="0" goto Abandon

cd \BldNEO

\Utils\byteswap \BldNEO\cart.p 202-p1.p1
\Utils\pad 202-p1.p1 524288 25
copy 202-p1.p1 \RelNEO\roms\ChibiAkumasGame\

\Utils\MakeNeoGeoHash.exe "\RelNEO\hash\neogeo.xml.template" "\RelNEO\hash\neogeo.xml" "\RelNEO\roms\ChibiAkumasGame"

cd \Emu\mame0200b_32bit
mame neogeo ChibiAkumasGame -video gdi -skip_gameinfo

rem mame neogeo Grime -video gdi -skip_gameinfo


goto Abandon

:MissingRom
echo No Neogeo Rom found.
echo put a MAME neogeo.zip file in \RelNEO\roms and try again!

:InvalidPath
echo Error: ASM file must be on same drive as devtools 
echo File: %BuildPath%\%BuildFile% 
echo Devtools Drive: %CD:~0,1% 
goto Abandon


:EmulatorFail
echo Error: Can't find \Emu\mame0200b_32bit\mame.exe
:Abandon
if "%3"=="nopause" exit
pause
