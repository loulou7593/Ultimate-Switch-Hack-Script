@ECHO OFF
chcp 65001 >nul
set "program_version=0.98"

:TOP_INIT
CD /d "%prog_dir%"
set "bat_name=%~n0"
Title NSC_Builder v%program_version% -- Profile: %ofile_name% -- by JulesOnTheRoad

:MAIN
cls
call :program_logo
ECHO .......................................................
echo Tappez "1" pour entrer en mode Téléchargement
echo Tappez "2" pour entrer en mode information de fichier
echo.
echo Tappez "N" pour accéder au Nouveaux Modes
echo Tappez "L" pour accéder a l'ancien mode
echo .......................................................
echo.
set /p bs="Faites votre choix: "
set bs=%bs:"=%
if /i "%bs%"=="1" goto DOWNLOADMODE
if /i "%bs%"=="2" goto INFMODE
if /i "%bs%"=="N" exit /B
if /i "%bs%"=="L" goto LegacyMode
goto MAIN

:LegacyMode
call "%prog_dir%ztools\LEGACY_fr.bat"
exit /B

:DOWNLOADMODE
cls
call :program_logo
%pycommand% "%nut%" -lib_call Drive.Download Interface
goto MAIN

:INFMODE
cls
call :program_logo
%pycommand% "%nut%" -lib_call Drive.Info Interface
goto MAIN

::///////////////////////////////////////////////////
::SUBROUTINES
::///////////////////////////////////////////////////

:squirrell
echo                    ,;:;;,
echo                   ;;;;;
echo           .=',    ;:;;:,
echo          /_', "=. ';:;:;
echo          @=:__,  \,;:;:'
echo            _(\.=  ;:;;'
echo           `"_(  _/="`
echo            `"'		
exit /B

:program_logo

ECHO                                        __          _ __    __         
ECHO                  ____  _____ ____     / /_  __  __(_) /___/ /__  _____
ECHO                 / __ \/ ___/ ___/    / __ \/ / / / / / __  / _ \/ ___/
ECHO                / / / (__  ) /__     / /_/ / /_/ / / / /_/ /  __/ /    
ECHO               /_/ /_/____/\___/____/_.___/\__,_/_/_/\__,_/\___/_/     
ECHO                              /_____/                                  
ECHO -------------------------------------------------------------------------------------
ECHO                         NINTENDO SWITCH CLEANER AND BUILDER
ECHO                      (THE XCI MULTI CONTENT BUILDER AND MORE)
ECHO -------------------------------------------------------------------------------------
ECHO =============================     BY JULESONTHEROAD     =============================
ECHO -------------------------------------------------------------------------------------
ECHO "                                POWERED BY SQUIRREL                                "
ECHO "                    BASED ON THE WORK OF BLAWAR AND LUCA FRAGA                     "
ECHO                                  VERSION %program_version% (GDRIVE)
ECHO -------------------------------------------------------------------------------------                   
ECHO Program's github: https://github.com/julesontheroad/NSC_BUILDER
ECHO Blawar's github:  https://github.com/blawar
ECHO Blawar's tinfoil: https://github.com/digableinc/tinfoil
ECHO Luca Fraga's github: https://github.com/LucaFraga
ECHO -------------------------------------------------------------------------------------
exit /B

:delay
PING -n 2 127.0.0.1 >NUL 2>&1
exit /B

:thumbup
echo.
echo    /@
echo    \ \
echo  ___\ \
echo (__O)  \
echo (____@) \
echo (____@)  \
echo (__o)_    \
echo       \    \
echo.
echo Bon amusement....
exit /B

:salida
::pause
exit



