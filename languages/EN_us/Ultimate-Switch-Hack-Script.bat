set lng_label_exist=0
%ushs_base_path%tools\gnuwin32\bin\grep.exe -c -E "^:%~1$" <"%~0" >"%ushs_base_path%temp_lng_var.txt"
set /p lng_label_exist=<"%ushs_base_path%temp_lng_var.txt"
del /q "%ushs_base_path%temp_lng_var.txt"
IF "%lng_label_exist%"=="0" (
	call "!associed_language_script:%language_path%=languages\FR_fr!" "%~1"
	goto:eof
) else (
	goto:%~1
)

:display_title
title Loading %this_script_version% - Shadow256 Ultimate Switch Hack Script %ushs_version%
goto:eof

:admin_error
echo This script requires Admin rights, please right click and select "run as admin" before continuing.
goto:eof

:display_utf8_instructions
echo Before continuing, please verify the following settings are correct. Not setting this correctly could cause this script to fail.
echo Make a right click on the title bar or use the shortcut "alt+space" and select "properties".
echo Go to the "fonts" tab, select the "Lucida Console" font and click the "OK" button.
echo.
echo If everything is configured correctly, the script should work without issue.
echo If the script fails and force closes, the font selected is not compatible with UTF-8 encoding.
goto:eof