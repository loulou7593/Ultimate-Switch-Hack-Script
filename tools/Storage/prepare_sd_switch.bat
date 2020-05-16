::Script by Shadow256
call tools\storage\functions\ini_scripts.bat
:begin_script
Setlocal enabledelayedexpansion
set this_script_full_path=%~0
set associed_language_script=%language_path%\!this_script_full_path:%ushs_base_path%=!
set associed_language_script=%ushs_base_path%%associed_language_script%
IF NOT EXIST "%associed_language_script%" (
	set associed_language_script=languages\FR_fr\!this_script_full_path:%ushs_base_path%=!
	set associed_language_script=%ushs_base_path%!associed_language_script!
	echo The associated language file cannot be found, please run the updater to download it. French will be set as default.
	pause
)
IF NOT EXIST "%associed_language_script%" (
	echo Language error. Please use the update manager to update the script. This script will now close.
	pause
	endlocal
	goto:eof
)
IF EXIST "%~0.version" (
	set /p this_script_version=<"%~0.version"
) else (
	set this_script_version=1.00.00
)
IF EXIST templogs (
	del /q templogs 2>nul
	rmdir /s /q templogs 2>nul
)
mkdir templogs
call "%associed_language_script%" "display_title"
call "%associed_language_script%" "intro"
pause
:define_volume_letter
%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
set /p tempcount=<templogs\count.txt
del /q templogs\count.txt
IF "%tempcount%"=="0" (
	call "%associed_language_script%" "disk_not_finded_error"
	goto:endscript
)
echo.
call "%associed_language_script%" "disk_list_begin"
:list_volumes
IF "%tempcount%"=="0" goto:set_volume_letter
TOOLS\gnuwin32\bin\tail.exe -%tempcount% <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\head.exe -1
set /a tempcount-=1
goto:list_volumes
:set_volume_letter
echo.
echo.
set volume_letter=
call "%associed_language_script%" "disk_choice"
call TOOLS\Storage\functions\strlen.bat nb "%volume_letter%"
IF %nb% EQU 0 (
	call "%associed_language_script%" "disk_choice_empty_error"
	goto:define_volume_letter
)
set volume_letter=%volume_letter:~0,1%
IF "%volume_letter%"=="0" goto:endscript2
set nb=1
CALL TOOLS\Storage\functions\CONV_VAR_to_MAJ.bat volume_letter
set i=0
:check_chars_volume_letter
IF %i% LSS %nb% (
	set check_chars_volume_letter=0
	FOR %%z in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
		IF "!volume_letter:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars_volume_letter=1
			goto:check_chars_volume_letter
		)
	)
	IF "!check_chars_volume_letter!"=="0" (
		call "%associed_language_script%" "disk_choice_char_error"
		goto:define_volume_letter
	)
)
IF NOT EXIST "%volume_letter%:\" (
	call "%associed_language_script%" "disk_choice_not_exist_error"
	goto:define_volume_letter
)
TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 1 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
set /p temp_volume_letter=<templogs\tempvar.txt
IF NOT "%volume_letter%"=="%temp_volume_letter%" (
	call "%associed_language_script%" "disk_choice_not_in_list_error"
	goto:define_volume_letter
)
set format_choice=
call "%associed_language_script%" "disk_format_choice"
IF NOT "%format_choice%"=="" set format_choice=%format_choice:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "format_choice" "o/n_choice"
IF /i "%format_choice%"=="o" (
	echo.
	set format_type=
	call "%associed_language_script%" "disk_format_type_choice"
) else (
	goto:copy_to_sd
)
IF "%format_type%"=="1" goto:format_exfat
IF "%format_type%"=="2" goto:format_fat32
goto:copy_to_sd
:format_exfat
call "%associed_language_script%" "disk_formating_begin"
echo.
chcp 850 >nul
format %volume_letter%: /X /Q /FS:EXFAT
IF %errorlevel% NEQ 0 (
	chcp 65001 >nul
	call "%associed_language_script%" "disk_formating_error"
	goto:endscript
) else (
chcp 65001 >nul
	call "%associed_language_script%" "disk_formating_success"
	echo.
	goto:copy_to_sd
)
:format_fat32
call "%associed_language_script%" "disk_formating_begin"
echo.
TOOLS\fat32format\fat32format.exe -q -c128 %volume_letter%
echo.
IF "%ERRORLEVEL%"=="5" (
	call "%associed_language_script%" "disk_formating_fat32_not_admin_error"
	::echo.
	goto:copy_to_sd
)
IF "%ERRORLEVEL%"=="32" (
	call "%associed_language_script%" "disk_formating_fat32_disk_used_error"
	goto:endscript
)
IF "%ERRORLEVEL%"=="2" (
	call "%associed_language_script%" "disk_formating_fat32_disk_not_exist_error"
	goto:endscript
)
IF NOT "%ERRORLEVEL%"=="1" (
	IF NOT "%ERRORLEVEL%"=="0" (
		call "%associed_language_script%" "disk_formating_fat32_unknown_error"
		goto:endscript
	)
)
IF "%ERRORLEVEL%"=="1" (
	call "%associed_language_script%" "disk_formating_fat32_canceled_info"
)
IF "%ERRORLEVEL%"=="0" (
	call "%associed_language_script%" "disk_formating_success"
)
:copy_to_sd
:define_general_select_profile
echo.
call "%associed_language_script%" "general_profile_select_begin"
set /a temp_count=0
copy nul templogs\profiles_list.txt >nul
IF NOT EXIST "tools\sd_switch\profiles\*.bat" (
	goto:general_no_profile_created
)
cd tools\sd_switch\profiles
for %%p in (*.bat) do (
	set /a temp_count+=1
	set temp_profilename=%%p
	set temp_profilename=!temp_profilename:~0,-4!
	echo !temp_count!: !temp_profilename!
	echo %%p>> ..\..\..\templogs\profiles_list.txt
)
cd ..\..\..
:general_no_profile_created
set /a count_default_profile=%temp_count%
IF EXIST "tools\default_configs\general_profile_all.bat" (
	set /a general_profile_number=1
	set /a general_profile_number+=%temp_count%
	set /a count_default_profile+=1
	call "%associed_language_script%" "general_profile_select_atmosphere_and_sxos_recommanded_profile_display"
) else (
	set general_no_default_config=Y
)
IF EXIST "tools\default_configs\atmosphere_profile_all.bat" (
	IF "%general_no_default_config%"=="Y" (
		set /a atmosphere_profile_number=1
	) else (
		set /a atmosphere_profile_number=2
	)
	set /a atmosphere_profile_number+=%temp_count%
	set /a count_default_profile+=1
	call "%associed_language_script%" "general_profile_select_atmosphere_recommanded_profile_display"
) else (
	set atmosphere_no_default_config=Y
)
IF EXIST "tools\default_configs\sxos_profile_all.bat" (
	IF "%general_no_default_config%"=="Y" (
		IF "%atmosphere_no_default_config%"=="Y" (
			set /a sxos_profile_number=1
		)
	) else IF "%atmosphere_no_default_config%"=="Y" (
		set /a sxos_profile_number=2
	) else (
		set /a sxos_profile_number=3
	)
	IF "%atmosphere_no_default_config%"=="Y" (
		IF "%general_no_default_config%"=="Y" (
			set /a sxos_profile_number=1
		)
	) else IF "%general_no_default_config%"=="Y" (
		set /a sxos_profile_number=2
	) else (
		set /a sxos_profile_number=3
	)
	set /a sxos_profile_number+=%temp_count%
	set /a count_default_profile+=1
	call "%associed_language_script%" "general_profile_select_sxos_recommanded_profile_display"
) else (
	set sxos_no_default_config=Y
)
set general_profile_path=
set general_profile=
call "%associed_language_script%" "general_profile_choice"
IF /i "%general_profile%"=="e" goto:endscript2
IF "%general_profile%"=="" (
	set pass_copy_general_pack=Y
	goto:skip_verif_general_profile
)
call TOOLS\Storage\functions\strlen.bat nb "%general_profile%"
set i=0
:check_chars_general_profile
IF %i% NEQ %nb% (
	set check_chars=0
	FOR %%z in (0 1 2 3 4 5 6 7 8 9) do (
		IF "!general_profile:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars=1
			goto:check_chars_general_profile
		)
	)
	IF "!check_chars!"=="0" (
		set pass_copy_general_pack=Y
		goto:skip_verif_general_profile
	)
)
IF %general_profile% GTR %count_default_profile% (
	set pass_copy_general_pack=Y
		goto:skip_verif_general_profile
)
IF "%general_profile%"=="0" (
	call tools\Storage\prepare_sd_switch_profiles_management.bat
	call "%associed_language_script%" "display_title"
	goto:define_general_select_profile
)
IF %general_profile% EQU %general_profile_number% (
	IF NOT "%general_no_default_config%"=="Y" (
		set pass_prepare_packs=Y
		set general_profile_path=tools\default_configs\general_profile_all.bat
		goto:skip_verif_general_profile
	)
)
IF %general_profile% EQU %atmosphere_profile_number% (
	IF NOT "%atmosphere_no_default_config%"=="Y" (
		set pass_prepare_packs=Y
		set general_profile_path=tools\default_configs\atmosphere_profile_all.bat
		goto:skip_verif_general_profile
	)
)
IF %general_profile% EQU %sxos_profile_number% (
	IF NOT "%sxos_no_default_config%"=="Y" (
		set pass_prepare_packs=Y
		set general_profile_path=tools\default_configs\sxos_profile_all.bat
		goto:skip_verif_general_profile
	)
)
TOOLS\gnuwin32\bin\sed.exe -n %general_profile%p <templogs\profiles_list.txt > templogs\tempvar.txt
set /p general_profile_path=<templogs\tempvar.txt
set general_profile_path=tools\sd_switch\profiles\%general_profile_path%
set pass_prepare_packs=Y
:skip_verif_general_profile
del /q templogs\profiles_list.txt >nul 2>&1
IF NOT "%pass_prepare_packs%"=="Y" (
	call tools\Storage\prepare_sd_switch_files_questions.bat
	call "%associed_language_script%" "display_title"
	IF "%language_important_error%"=="Y" goto:endscript2
	goto:test_copy_launch
) else (
	IF EXIST "%general_profile_path%" (
		call "%general_profile_path%"
	)
)
IF /i "%copy_atmosphere_pack%"=="o" (
	IF NOT "%atmosphere_pass_copy_modules_pack%"=="Y" (
		IF NOT EXIST "%atmosphere_modules_profile_path%" (
			set errorlevel=404
		)
	)
)
IF /i "%copy_reinx_pack%"=="o" (
	IF NOT "%reinx_pass_copy_modules_pack%"=="Y" (
		IF NOT EXIST "%reinx_modules_profile_path%" (
			set errorlevel=404
		)
	)
)
IF /i "%copy_emu%"=="o" (
	IF NOT "%pass_copy_emu_pack%"=="Y" (
		IF NOT EXIST "%emu_profile_path%" (
			set errorlevel=404
		)
	)
)
IF "%copy_cheats%"=="Y" (
	IF NOT EXIST "%cheats_profile_path%" (
		set errorlevel=404
	)
)
IF NOT "%pass_copy_mixed_pack%"=="Y" (
	IF NOT EXIST "%mixed_profile_path%" (
			set errorlevel=404
	)
)
IF NOT "%pass_copy_overlays_pack%"=="Y" (
	IF NOT EXIST "%overlays_profile_path%" (
			set errorlevel=404
	)
)
:confirm_settings
call tools\Storage\prepare_sd_switch_infos.bat
call "%associed_language_script%" "display_title"
set confirm_copy=
call "%associed_language_script%" "confirm_copy_choice"
IF NOT "%confirm_copy%"=="" set confirm_copy=%confirm_copy:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "confirm_copy" "o/n_choice"
IF /i "%confirm_copy%"=="o" (
	set errorlevel=200
	goto:test_copy_launch
) else IF /i "%confirm_copy%"=="n" (
	call "%associed_language_script%" "canceled"
	pause
	endlocal
	goto:begin_script
) else (
	call "%associed_language_script%" "bad_choice"
	goto:confirm_settings
)
:test_copy_launch
IF %errorlevel% EQU 200 (
	goto:begin_copy
) else IF %errorlevel% EQU 400 (
	endlocal
	goto:begin_script
) else (
	call "%associed_language_script%" "before_copy_error"
	pause
	endlocal
	goto:begin_script
)

:begin_copy
echo.
call "%associed_language_script%" "copying_begin"

IF /i "%del_files_dest_copy%"=="1" (
	call :delete_cfw_files
	set del_files_dest_copy=0
) else IF /i "%del_files_dest_copy%"=="2" (
	rmdir /s /q "%volume_letter%:\" >nul 2>&1
	set del_files_dest_copy=0
)

IF /i "%update_retroarch%"=="o" call tools\storage\update_manager.bat "retroarch_update"
IF NOT EXIST "templogs" mkdir templogs

IF /i "%copy_atmosphere_pack%"=="o" (
	IF EXIST "%volume_letter%:\atmosphere\titles*.*" (
		IF EXIST "%volume_letter%:\atmosphere\contents" (
			rmdir /s /q "%volume_letter%:\atmosphere\titles" >nul
		) else (
			move "%volume_letter%:\atmosphere\titles" "%volume_letter%:\atmosphere\contents" >nul
		)
	)
	IF EXIST "%volume_letter%:\atmosphere\BCT.ini" del /q "%volume_letter%:\atmosphere\BCT.ini"
	IF EXIST "%volume_letter%:\atmosphere\loader.ini" del /q "%volume_letter%:\atmosphere\loader.ini"
	IF EXIST "%volume_letter%:\atmosphere\system_settings.ini" del /q "%volume_letter%:\atmosphere\system_settings.ini"
	IF EXIST "%volume_letter%:\atmosphere\kip_patches\fs_patches" rmdir /s /q "%volume_letter%:\atmosphere\kip_patches\fs_patches" >nul
	IF EXIST "%volume_letter%:\atmosphere\kip_patches\loader_patches" rmdir /s /q "%volume_letter%:\atmosphere\kip_patches\loader_patches" >nul
	IF EXIST "%volume_letter%:\atmosphere\exefs_patches\es_patches" rmdir /s /q "%volume_letter%:\atmosphere\exefs_patches\es_patches" >nul
	IF EXIST "%volume_letter%:\atmosphere\hekate_kips\loader.kip" del /q "%volume_letter%:\atmosphere\hekate_kips\loader.kip" >nul
	IF EXIST "%volume_letter%:\sept\sept-secondary.enc" del /q "%volume_letter%:\sept\sept-secondary.enc"
	IF EXIST "%volume_letter%:\sept\ams\sept-secondary.enc" del /q "%volume_letter%:\sept\ams\sept-secondary.enc"
	%windir%\System32\Robocopy.exe TOOLS\sd_switch\atmosphere %volume_letter%:\ /e >nul
	IF /i "%copy_payloads%"=="o" (
		copy /V /B TOOLS\sd_switch\payloads\Atmosphere_fusee-primary.bin %volume_letter%:\Atmosphere_fusee-primary.bin >nul
		copy /V /B TOOLS\sd_switch\payloads\Hekate.bin %volume_letter%:\Hekate.bin >nul
		IF EXIST "%volume_letter%:\bootloader\sys\switchboot.txt" copy /v /b "TOOLS\Switchboot\tegrarcm\hekate_switchboot_mod.bin" "%volume_letter%:\hekate_switchboot_mod.bin" >nul
	)
	copy /V /B TOOLS\sd_switch\payloads\Atmosphere_fusee-primary.bin %volume_letter%:\bootloader\payloads\Atmosphere_fusee-primary.bin >nul
	copy /V /B TOOLS\sd_switch\payloads\Hekate.bin %volume_letter%:\bootloader\payloads\Hekate.bin >nul
	copy /V /B TOOLS\sd_switch\payloads\Hekate.bin %volume_letter%:\bootloader\update.bin >nul
	IF EXIST "%volume_letter%:\switch\GagOrder.nro" del /q "%volume_letter%:\switch\GagOrder.nro" >nul
	IF EXIST "%volume_letter%:\atmosphere\exefs_patches\Signature_Patches_by_br4z0rf_and_Jakibaki" rmdir /s /q "%volume_letter%:\atmosphere\exefs_patches\Signature_Patches_by_br4z0rf_and_Jakibaki" >nul
	IF EXIST "%volume_letter%:\switch\appstore\res" rmdir /s /q "%volume_letter%:\switch\appstore\res" >nul
	IF EXIST "%volume_letter%:\BCT.ini" del /q "%volume_letter%:\BCT.ini" >nul
	IF EXIST "%volume_letter%:\fusee-secondary.bin" del /q "%volume_letter%:\fusee-secondary.bin" >nul
	IF EXIST "%volume_letter%:\bootlogo.bmp" del /q "%volume_letter%:\bootlogo.bmp" >nul
	IF EXIST "%volume_letter%:\hekate_ipl.ini" del /q "%volume_letter%:\hekate_ipl.ini" >nul
	IF EXIST "%volume_letter%:\switch\CFWSettings" rmdir /s /q "%volume_letter%:\switch\CFWSettings" >nul
	IF EXIST "%volume_letter%:\switch\CFW-Settings" rmdir /s /q "%volume_letter%:\switch\CFW-Settings" >nul
	IF EXIST "%volume_letter%:\modules\atmosphere\fs_mitm.kip" del /q "%volume_letter%:\modules\atmosphere\fs_mitm.kip" >nul
	IF EXIST "%volume_letter%:\atmosphere\titles\010000000000100D" rmdir /s /q "%volume_letter%:\atmosphere\titles\010000000000100D" >nul
	IF /i "%atmosphere_enable_nogc_patch%"=="O" (
		%windir%\System32\Robocopy.exe TOOLS\sd_switch\atmosphere_patches_nogc %volume_letter%:\ /e >nul
	)
	IF /i "%atmosphere_enable_cheats%"=="o" (
		IF "%copy_all_cheats_pack%"=="Y" (
			%windir%\System32\Robocopy.exe TOOLS\sd_switch\cheats\titles %volume_letter%:\atmosphere\contents /e >nul
		) else (
			call :copy_cheats_profile "atmosphere"
		)
		%windir%\System32\Robocopy.exe TOOLS\sd_switch\mixed\modular\EdiZon %volume_letter%:\ /e >nul
	)
	copy /V /B TOOLS\sd_switch\payloads\Hekate.bin %volume_letter%:\atmosphere\reboot_payload.bin >nul
	copy /V /B TOOLS\sd_switch\payloads\Hekate.bin %volume_letter%:\switch\HekateBrew\payload.bin >nul
	copy /V /B TOOLS\sd_switch\payloads\Lockpick_RCM.bin %volume_letter%:\bootloader\payloads\Lockpick_RCM.bin >nul
	copy /V /B TOOLS\sd_switch\payloads\Incognito_RCM.bin %volume_letter%:\bootloader\payloads\Incognito_RCM.bin >nul
	del /Q /S "%volume_letter%:\atmosphere\.emptydir" >nul
	del /Q /S "%volume_letter%:\bootloader\.emptydir" >nul
	del /Q /S "%volume_letter%:\emummc\.emptydir" >nul
	del /Q /S "%volume_letter%:\mods\.emptydir" >nul
	IF EXIST "%volume_letter%:\switch\KosmosToolbox\config.json" del /Q "%volume_letter%:\switch\KosmosToolbox\config.json" >nul 2>&1
	IF EXIST "%volume_letter%:\bootloader\sys\switchboot.txt" (
		%windir%\System32\Robocopy.exe TOOLS\Switchboot\tegrarcm\bootloader %volume_letter%:\bootloader /e >nul
		%windir%\System32\Robocopy.exe TOOLS\Switchboot\Tidy_Memloader %volume_letter%:\ /e >nul
		copy /v /b "TOOLS\Switchboot\tegrarcm\hekate_switchboot_mod.bin" "%volume_letter%:\bootloader\payloads\hekate_switchboot_mod.bin" >nul
	)
	IF /i "%atmosphere_manual_config%"=="o" (
		call :copy_atmosphere_configuration
	)
	call :copy_modules_pack "atmosphere"
	IF NOT "%atmosphere_pass_copy_emummc_pack%"=="Y" copy /v "%atmosphere_emummc_profile_path%" "%volume_letter%:\emummc\emummc.ini" >nul
	IF NOT "%pass_copy_overlays_pack%"=="Y" call :force_copy_overlays_base_files "atmosphere"
)

IF /i "%copy_reinx_pack%"=="o" (
			IF EXIST "%volume_letter%:\ReiNX\contents" (
			rmdir /s /q "%volume_letter%:\ReiNX\titles" >nul
		) else (
			move "%volume_letter%:\ReiNX\titles" "%volume_letter%:\ReiNX\contents" >nul
		)
	IF EXIST "%volume_letter%:\sept\sept-secondary.enc" del /q "%volume_letter%:\sept\sept-secondary.enc" >nul
	IF EXIST "%volume_letter%:\sept\reinx\sept-secondary.enc" del /q "%volume_letter%:\sept\reinx\sept-secondary.enc" >nul
	IF EXIST "%volume_letter%:\ReiNX\contents\010000000000100D\*.*" rmdir /s /q ""%volume_letter%:\ReiNX\contents\010000000000100D" >nul
	IF EXIST "%volume_letter%:\ReiNX\contents\0100000000000036\exefs\*.*" rmdir /s /q ""%volume_letter%:\ReiNX\contents\0100000000000036\exefs" >nul
	IF EXIST "%volume_letter%:\ReiNX\patches\*.*" rmdir /s /q "%volume_letter%:\ReiNX\patches" >nul
	IF EXIST "%volume_letter%:\ReiNX\splash.bin" del /q "%volume_letter%:\ReiNX\splash.bin"
	IF EXIST "%volume_letter%:\ReiNX\lp0fw.bin" del /q "%volume_letter%:\ReiNX\lp0fw.bin"
	%windir%\System32\Robocopy.exe TOOLS\sd_switch\reinx %volume_letter%:\ /e >nul
	IF /i NOT "%reinx_enable_nogc_patch%"=="o" del /q %volume_letter%:\ReiNX\nogc >nul
	copy /V /B TOOLS\sd_switch\payloads\ReiNX.bin %volume_letter%:\ReiNX.bin >nul
	IF /i "%copy_atmosphere_pack%"=="o" copy /V /B TOOLS\sd_switch\payloads\ReiNX.bin %volume_letter%:\bootloader\payloads\ReiNX.bin >nul
	IF EXIST "%volume_letter%:\switch\GagOrder.nro" del /q "%volume_letter%:\switch\GagOrder.nro" >nul
	IF EXIST "%volume_letter%:\switch\appstore\res" rmdir /s /q "%volume_letter%:\switch\appstore\res" >nul
	copy /V /B TOOLS\sd_switch\payloads\ReiNX.bin %volume_letter%:\ReiNX\reboot_payload.bin >nul
	call :copy_modules_pack "reinx"
	IF NOT "%pass_copy_overlays_pack%"=="Y" call :force_copy_overlays_base_files "reinx"
)

IF /i "%copy_sxos_pack%"=="o" (
	%windir%\System32\Robocopy.exe TOOLS\sd_switch\sxos %volume_letter%:\ /e >nul
	IF /i "%copy_payloads%"=="o" (
		copy /V /B TOOLS\sd_switch\payloads\SXOS.bin %volume_letter%:\SXOS.bin >nul
		copy /V /B TOOLS\sd_switch\payloads\Lockpick_RCM.bin %volume_letter%:\Lockpick_RCM.bin >nul
		copy /V /B TOOLS\sd_switch\payloads\Incognito_RCM.bin %volume_letter%:\Incognito_RCM.bin >nul
	)
	IF /i "%copy_atmosphere_pack%"=="o" copy /V /B TOOLS\sd_switch\payloads\SXOS.bin %volume_letter%:\bootloader\payloads\SXOS.bin >nul
	IF EXIST "%volume_letter%:\switch\GagOrder.nro" del /q "%volume_letter%:\switch\GagOrder.nro" >nul
	IF EXIST "%volume_letter%:\switch\appstore\res" rmdir /s /q "%volume_letter%:\switch\appstore\res" >nul
	IF /i "%sxos_enable_cheats%"=="o" (
		IF "%copy_all_cheats_pack%"=="Y" (
			%windir%\System32\Robocopy.exe TOOLS\sd_switch\cheats\titles %volume_letter%:\sxos\titles /e >nul
		) else (
			call :copy_cheats_profile "sxos"
		)
	)
	call :copy_modules_pack "sxos"
	rem IF NOT "%pass_copy_overlays_pack%"=="Y" call :force_copy_overlays_base_files "sxos"
	IF EXIST "%volume_letter%:\switch\sx_installer" rmdir /s /q "%volume_letter%:\switch\sx_installer"
	del /Q /S "%volume_letter%:\sxos\.emptydir" >nul
	IF EXIST "%volume_letter%:\sxos\titles\0100000000000123" rmdir /s /q "%volume_letter%:\sxos\titles\0100000000000123"
	IF /i "%remove_sx_autoloader%"=="o" (
		IF EXIST "%volume_letter%:\sxos\titles\00FF0012656180FF\cache" (
			rmdir /s /q "%volume_letter%:\sxos\titles\00FF0012656180FF\flags"
			del /q "%volume_letter%:\sxos\titles\00FF0012656180FF\exefs.nsp"
		) else (
			rmdir /s /q "%volume_letter%:\sxos\titles\00FF0012656180FF"
		)
	)
)

IF /i "%copy_memloader%"=="o" (
	%windir%\System32\Robocopy.exe TOOLS\memloader\mount_discs %volume_letter%:\ /e >nul
	IF /i "%copy_sxos_pack%"=="o" copy /V /B TOOLS\sd_switch\payloads\memloader.bin %volume_letter%:\Memloader.bin >nul
	IF /i "%copy_atmosphere_pack%"=="o" copy /V /B TOOLS\sd_switch\payloads\memloader.bin %volume_letter%:\bootloader\payloads\Memloader.bin >nul
)

call :copy_mixed_pack
call :copy_overlays_pack
call :copy_emu_pack

del /Q /S "%volume_letter%:\switch\.emptydir" >nul
del /Q /S "%volume_letter%:\Backup\.emptydir" >nul
del /Q /S "%volume_letter%:\pk1decryptor\.emptydir" >nul
IF EXIST "%volume_letter%:\tinfoil\" del /Q /S "%volume_letter%:\tinfoil\.emptydir" >nul 2>&1
IF EXIST "%volume_letter%:\folder_version.txt" del /q "%volume_letter%:\folder_version.txt"
IF EXIST "%volume_letter%:\switch\folder_version.txt" del /q "%volume_letter%:\switch\folder_version.txt"
set prepare_another_sd=
call "%associed_language_script%" "copying_end"
IF NOT "%prepare_another_sd%"=="" set prepare_another_sd=%prepare_another_sd:~0,1%
call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "prepare_another_sd" "o/n_choice"
IF /i "%prepare_another_sd%"=="o" (
	endlocal
	goto:begin_script
) else (
	goto:endscript2
)

:copy_modules_pack
IF "%~1"=="atmosphere" (
	IF "%atmosphere_pass_copy_modules_pack%"=="Y" goto:skip_copy_modules_pack
	set temp_modules_copy_path=%volume_letter%:\atmosphere\contents
	set temp_modules_profile_path=%atmosphere_modules_profile_path%
)
IF "%~1"=="reinx" (
	IF "%reinx_pass_copy_modules_pack%"=="Y" goto:skip_copy_modules_pack
	set temp_modules_copy_path=%volume_letter%:\ReiNX\contents
	set temp_modules_profile_path=%reinx_modules_profile_path%
)
IF "%~1"=="sxos" (
	IF "%sxos_pass_copy_modules_pack%"=="Y" goto:skip_copy_modules_pack
	set temp_modules_copy_path=%volume_letter%:\sxos\titles
	set temp_modules_profile_path=%sxos_modules_profile_path%
)
tools\gnuwin32\bin\grep.exe -c "" <"%temp_modules_profile_path%" > templogs\tempvar.txt
set /p temp_count=<templogs\tempvar.txt
for /l %%i in (1,1,%temp_count%) do (
	set temp_special_module=N
	TOOLS\gnuwin32\bin\sed.exe -n %%ip <"%temp_modules_profile_path%" >templogs\tempvar.txt
	set /p temp_module=<templogs\tempvar.txt
		IF "%~1"=="sxos" (
		IF "!temp_module!"=="uLaunch" (
			set temp_special_module=Y
			call "%associed_language_script%" "sxos_force_disable_stealth_mode_for_uLaunch"
			rem IF EXIST "%volume_letter%:\sxos\config\stealth_enable" rename "%volume_letter%:\sxos\config\stealth_enable" "stealth_disable"
		)
	)
	IF "!temp_module!"=="Ovl-menu" (
		IF EXIST "%temp_modules_copy_path%\010000000007E51A\exefs.nsp" rmdir /s /q "%temp_modules_copy_path%\010000000007E51A"
		IF "%ovlmenu_already_copied%"=="Y" set temp_special_module=Y
	)
	IF NOT "!temp_special_module!"=="Y" (
		dir /b "tools\sd_switch\modules\pack\!temp_module!\titles">templogs\tempvar.txt
		set /p temp_module_title_id=<templogs\tempvar.txt
		%windir%\System32\Robocopy.exe tools\sd_switch\modules\pack\!temp_module!\titles %temp_modules_copy_path% /e >nul
		IF EXIST "tools\sd_switch\modules\pack\!temp_module!\others" %windir%\System32\Robocopy.exe tools\sd_switch\modules\pack\!temp_module!\others %volume_letter%:\ /e >nul
		IF "!temp_module!"=="Ovl-menu" (
			set ovlmenu_already_copied=Y
		)
			IF "%~1"=="sxos" (
			IF EXIST "%temp_modules_copy_path%\!temp_module_title_id!\toolbox.json" del /q "%temp_modules_copy_path%\!temp_module_title_id!\toolbox.json"
		)
	)
	IF "!temp_module!"=="Emuiibo" (
		call :force_copy_overlays_base_files "%~1"
		IF EXIST "%volume_letter%:\switch\AmiiSwap\*.*" rmdir /s /q "%volume_letter%:\switch\AmiiSwap"
	)
	IF "!temp_module!"=="Slidenx" (
		IF EXIST "%volume_letter%:\SlideNX\attach.mp3" del /q "%volume_letter%:\SlideNX\attach.mp3"
		IF EXIST "%volume_letter%:\SlideNX\detach.mp3" del /q "%volume_letter%:\SlideNX\detach.mp3"
	)
	IF "!temp_module!"=="Sys-FTPD" (
		IF EXIST "%volume_letter%:\config\sys-ftpd\*.mp3" del /q "%volume_letter%:\config\sys-ftpd\*.mp3"
	)
	IF "!temp_module!"=="BootSoundNX" (
		IF EXIST "%volume_letter%:\bootloader\sound\bootsound.mp3" rmdir /s /q "%volume_letter%:\bootloader\sound"
		IF EXIST "%volume_letter%:\config\BootSoundNX\bootsound.mp3" del /q "%volume_letter%:\config\BootSoundNX\bootsound.mp3" >nul
		IF EXIST "%temp_modules_copy_path%\AA200000000002AA\exefs.nsp" rmdir /s /q ""%temp_modules_copy_path%\AA200000000002AA""
	)
	IF "!temp_module!"=="Sys-tune" (
		call :force_copy_overlays_base_files "%~1"
	)
)
:skip_copy_modules_pack
exit /b

:force_copy_overlays_base_files
IF "%ovlmenu_already_copied%"=="Y" exit /b
IF "%~1"=="atmosphere" (
	set temp_modules_copy_path=%volume_letter%:\atmosphere\contents
)
IF "%~1"=="reinx" (
	set temp_modules_copy_path=%volume_letter%:\ReiNX\titles
)
IF "%~1"=="sxos" (
	set temp_modules_copy_path=%volume_letter%:\sxos\titles
)
IF EXIST "%temp_modules_copy_path%\010000000007E51A\exefs.nsp" rmdir /s /q "%temp_modules_copy_path%\010000000007E51A"
%windir%\System32\Robocopy.exe tools\sd_switch\modules\pack\Ovl-menu\titles %temp_modules_copy_path% /e >nul
%windir%\System32\Robocopy.exe tools\sd_switch\modules\pack\Ovl-menu\others %volume_letter%:\ /e >nul
set ovlmenu_already_copied=Y
exit /b

:copy_mixed_pack
%windir%\System32\Robocopy.exe tools\sd_switch\mixed\base %volume_letter%:\ /e >nul
IF "%pass_copy_mixed_pack%"=="Y" goto:skip_copy_mixed_pack
tools\gnuwin32\bin\grep.exe -c "" <"%mixed_profile_path%" > templogs\tempvar.txt
set /p temp_count=<templogs\tempvar.txt
for /l %%i in (1,1,%temp_count%) do (
	set temp_special_homebrew=N
	TOOLS\gnuwin32\bin\sed.exe -n %%ip <"%mixed_profile_path%" >templogs\tempvar.txt
	set /p temp_homebrew=<templogs\tempvar.txt
	IF "!temp_homebrew!"=="EdiZon" (
		IF NOT EXIST "%volume_letter%:\switch" mkdir "%volume_letter%:\switch"
		IF EXIST "%volume_letter%:\EdiZon" move "%volume_letter%:\EdiZon" "%volume_letter%:\switch\EdiZon" >nul
	)
	IF "!temp_homebrew!"=="Switch-cheats-updater" (
		IF EXIST "%volume_letter%:\config\cheats-updater\exclude.txt" rename "%volume_letter%:\config\cheats-updater\exclude.txt" "exclude.txt.bak" >nul
	)
		IF "!temp_homebrew!"=="Fizeau" (
		set temp_special_homebrew=Y
		IF EXIST "%volume_letter%:\atmosphere\contents" (
			set one_cfw_chosen=Y
			%windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew!\special_atmosphere %volume_letter%: /e >nul
			%windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew!\module\titles %volume_letter%:\atmosphere\contents /e >nul
		)
		IF EXIST "%volume_letter%:\ReiNX\contents" (
			set one_cfw_chosen=Y
			%windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew!\module\titles %volume_letter%:\ReiNX\contents /e >nul
		)
		IF EXIST "%volume_letter%:\sxos\titles" (
			set one_cfw_chosen=Y
			%windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew!\module %volume_letter%:\sxos /e >nul
		)
		IF EXIST "%volume_letter%:\boot.dat" (
			set one_cfw_chosen=Y
			IF NOT EXIST "%volume_letter%:\sxos" mkdir "%volume_letter%:\sxos"
			%windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew!\module %volume_letter%:\sxos /e >nul
		)
		IF /i "%copy_atmosphere_pack%"=="o" (
			set one_cfw_chosen=Y
			IF NOT EXIST "%volume_letter%:\atmosphere" mkdir "%volume_letter%:\atmosphere"
			%windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew!\module\titles %volume_letter%:\atmosphere\contents /e >nul
		)
		IF /i "%copy_reinx_pack%"=="o" (
			set one_cfw_chosen=Y
			IF NOT EXIST "%volume_letter%:\ReiNX" mkdir "%volume_letter%:\ReiNX"
			%windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew!\module\titles %volume_letter%:\ReiNX\contents /e >nul
		)
		IF /i "%copy_sxos_pack%"=="o" (
			set one_cfw_chosen=Y
			IF NOT EXIST "%volume_letter%:\sxos" mkdir "%volume_letter%:\sxos"
			%windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew!\module %volume_letter%:\sxos /e >nul
		)
		IF "!one_cfw_chosen!"=="Y" (
			%windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew!\homebrew %volume_letter%:\ /e >nul
		) else (
			call "%associed_language_script%" "homebrew_should_be_associed_with_at_least_one_cfw_error"
		)
	)
	IF "!temp_special_homebrew!"=="N" %windir%\System32\Robocopy.exe tools\sd_switch\mixed\modular\!temp_homebrew! %volume_letter%:\ /e >nul
	IF "!temp_homebrew!"=="Switch-cheats-updater" (
		IF EXIST "%volume_letter%:\config\cheats-updater\exclude.txt.bak" (
			del /q "%volume_letter%:\config\cheats-updater\exclude.txt" >nul
			rename "%volume_letter%:\config\cheats-updater\exclude.txt.bak" "exclude.txt" >nul
		)
	)
	IF "!temp_homebrew!"=="Nxdumptool" (
		IF EXIST "%volume_letter%:\switch\gcdumptool\*.*" rmdir /s /q "%volume_letter%:\switch\gcdumptool"
		IF EXIST "%volume_letter%:\switch\gcdumptool.nro" del /q "%volume_letter%:\switch\gcdumptool.nro"
	)
	IF "!temp_homebrew!"=="Payload_Launcher" (
		copy /V /B TOOLS\sd_switch\payloads\Lockpick_RCM.bin %volume_letter%:\payloads\Lockpick_RCM.bin >nul
		copy /V /B TOOLS\sd_switch\payloads\Incognito_RCM.bin %volume_letter%:\payloads\Incognito_RCM.bin >nul
		IF /i "%copy_atmosphere_pack%"=="o" (
			copy /V /B TOOLS\sd_switch\payloads\Atmosphere_fusee-primary.bin %volume_letter%:\payloads\Atmosphere_fusee-primary.bin >nul
			copy /V /B TOOLS\sd_switch\payloads\Hekate.bin %volume_letter%:\payloads\Hekate.bin >nul
			IF EXIST "%volume_letter%:\bootloader\sys\switchboot.txt" copy /v /b "tools\Switchboot\tegrarcm\hekate_switchboot_mod.bin" "%volume_letter%:\payloads\hekate_switchboot_mod.bin" >nul
		)
		IF /i "%copy_reinx_pack%"=="o" copy /V /B TOOLS\sd_switch\payloads\ReiNX.bin %volume_letter%:\payloads\ReiNX.bin >nul
		IF /i "%copy_sxos_pack%"=="o" copy /V /B TOOLS\sd_switch\payloads\SXOS.bin %volume_letter%:\payloads\SXOS.bin >nul
		IF /i "%copy_memloader%"=="o" copy /V /B TOOLS\sd_switch\payloads\memloader.bin %volume_letter%:\payloads\memloader.bin >nul
	)
)
:skip_copy_mixed_pack
exit /b

:copy_overlays_pack
IF "%pass_copy_overlays_pack%"=="Y" goto:skip_copy_overlays_pack
tools\gnuwin32\bin\grep.exe -c "" <"%overlays_profile_path%" > templogs\tempvar.txt
set /p temp_count=<templogs\tempvar.txt
for /l %%i in (1,1,%temp_count%) do (
	set temp_special_overlay=N
	TOOLS\gnuwin32\bin\sed.exe -n %%ip <"%overlays_profile_path%" >templogs\tempvar.txt
	set /p temp_overlay=<templogs\tempvar.txt
	IF "!temp_special_overlay!"=="N" %windir%\System32\Robocopy.exe tools\sd_switch\overlays\pack\!temp_overlay! %volume_letter%:\ /e >nul
)
:skip_copy_overlays_pack
exit /b

:copy_emu_pack
IF /i NOT "%copy_emu%"=="o" (
	goto:skip_copy_emu_pack
) else (
	IF "%pass_copy_emu_pack%"=="Y" goto:skip_copy_emu_pack
)
IF EXIST "%volume_letter%:\switch\pfba\skin\config.cfg" move "%volume_letter%:\switch\pfba\skin\config.cfg" "%volume_letter%:\switch\pfba\skin\config.cfg.bak" >nul
IF EXIST "%volume_letter%:\switch\pnes\skin\config.cfg" move "%volume_letter%:\switch\pnes\skin\config.cfg" "%volume_letter%:\switch\pnes\skin\config.cfg.bak" >nul
IF EXIST "%volume_letter%:\switch\psnes\skin\config.cfg" move "%volume_letter%:\switch\psnes\skin\config.cfg" "%volume_letter%:\switch\psnes\skin\config.cfg.bak" >nul
tools\gnuwin32\bin\grep.exe -c "" <"%emu_profile_path%" > templogs\tempvar.txt
set /p temp_count=<templogs\tempvar.txt
for /l %%i in (1,1,%temp_count%) do (
	set temp_special_emulator=N
	TOOLS\gnuwin32\bin\sed.exe -n %%ip <"%emu_profile_path%" >templogs\tempvar.txt
	set /p temp_emulator=<templogs\tempvar.txt
	IF "!temp_emulator!"=="Nes_Classic_Edition" (
		IF NOT EXIST "tools\sd_switch\emulators\pack\Nes_Classic_Edition\switch\clover\user\data.json" (
			set config_nes_classic=
			call "%associed_language_script%" "config_nes_classic_choice"
			IF NOT "!config_nes_classic!"=="" set config_nes_classic=!config_nes_classic:~0,1!
			call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "config_nes_classic" "o/n_choice"
			IF /i "!config_nes_classic!"=="o" (
				call tools\NES_Injector\NES_Injector.bat
				call "%associed_language_script%" "display_title"
			)
		)
		IF NOT EXIST "tools\sd_switch\emulators\pack\Nes_Classic_Edition\switch\clover\user\data.json" (
			call "%associed_language_script%" "config_nes_classic_error"
			set temp_special_emulator=Y
		)
		IF NOT "!temp_special_emulator!"=="Y" (
			IF EXIST "%volume_letter%:\switch\clover\user\boxart" rmdir /s /q "%volume_letter%:\switch\clover\user\boxart"
			IF EXIST "%volume_letter%:\switch\clover\user\rom" rmdir /s /q "%volume_letter%:\switch\clover\user\rom"
			IF EXIST "%volume_letter%:\switch\clover\user\thumbnail" rmdir /s /q "%volume_letter%:\switch\clover\user\thumbnail"
			IF EXIST "%volume_letter%:\switch\clover\user\data.json" del /q "%volume_letter%:\switch\clover\user\data.json"
		)
	)
	IF "!temp_emulator!"=="Snes_Classic_Edition" (
		IF NOT EXIST "tools\sd_switch\emulators\pack\Snes_Classic_Edition\switch\snes_classic\game\database.json" (
			set config_snes_classic=
			call "%associed_language_script%" "config_snes_classic_choice"
			IF NOT "!config_snes_classic!"=="" set config_snes_classic=!config_snes_classic:~0,1!
			call "tools\Storage\functions\modify_yes_no_always_never_vars.bat" "config_snes_classic" "o/n_choice"
			IF /i "!config_snes_classic!"=="o" (
				call tools\SNES_Injector\SNES_Injector.bat
				call "%associed_language_script%" "display_title"
			)
		)
		IF NOT EXIST "tools\sd_switch\emulators\pack\Snes_Classic_Edition\switch\snes_classic\game\database.json" (
			call "%associed_language_script%" "config_snes_classic_error"
			set temp_special_emulator=Y
		)
		IF NOT "!temp_special_emulator!"=="Y" (
			IF EXIST "%volume_letter%:\switch\snes_classic\game\boxart" rmdir /s /q "%volume_letter%:\switch\snes_classic\game\boxart"
			IF EXIST "%volume_letter%:\switch\snes_classic\game\rom" rmdir /s /q "%volume_letter%:\switch\snes_classic\game\rom"
			IF EXIST "%volume_letter%:\switch\snes_classic\game\thumbnail" rmdir /s /q "%volume_letter%:\switch\snes_classic\game\thumbnail"
			IF EXIST "%volume_letter%:\switch\snes_classic\game\database.json" del /q "%volume_letter%:\switch\snes_classic\game\database.json"
		)
	)
	IF "!temp_emulator!"=="RetroArch" (
		set temp_special_emulator=Y
		IF NOT EXIST "tools\sd_switch\emulators\pack\!temp_emulator!" (
			call "%associed_language_script%" "retroarch_not_exist_error"
		) else (
			tools\7zip\7za.exe x -y -sccUTF-8 "tools\sd_switch\emulators\pack\RetroArch\RetroArch.7z" -o"%volume_letter%:\" -r
			IF NOT EXIST "%volume_letter%:\switch\retroarch_switch" mkdir "%volume_letter%:\switch\retroarch_switch"
			move "%volume_letter%:\switch\retroarch_switch.nro" "%volume_letter%:\switch\retroarch_switch\retroarch_switch.nro" >nul
		)
	)
	IF NOT "!temp_special_emulator!"=="Y" %windir%\System32\Robocopy.exe tools\sd_switch\emulators\pack\!temp_emulator! %volume_letter%:\ /e >nul
)
IF /i "%keep_emu_configs%"=="o" (
	del /q "%volume_letter%:\switch\pfba\skin\config.cfg" >nul
	move "%volume_letter%:\switch\pfba\skin\config.cfg.bak" "%volume_letter%:\switch\pfba\skin\config.cfg" >nul
	del /q "%volume_letter%:\switch\pnes\skin\config.cfg" >nul
	move "%volume_letter%:\switch\pnes\skin\config.cfg.bak" "%volume_letter%:\switch\pnes\skin\config.cfg" >nul
	del /q "%volume_letter%:\switch\psnes\skin\config.cfg" >nul
	move "%volume_letter%:\switch\psnes\skin\config.cfg.bak" "%volume_letter%:\switch\psnes\skin\config.cfg" >nul
) else (
	IF EXIST "%volume_letter%:\switch\pfba\skin\config.cfg.bak" del /q "%volume_letter%:\switch\pfba\skin\config.cfg.bak"
	IF EXIST "%volume_letter%:\switch\pnes\skin\config.cfg.bak" del /q "%volume_letter%:\switch\pnes\skin\config.cfg.bak"
	IF EXIST "%volume_letter%:\switch\psnes\skin\config.cfg.bak" del /q "%volume_letter%:\switch\psnes\skin\config.cfg.bak"
)
:skip_copy_emu_pack
exit /b

:copy_cheats_profile
IF "%~1"=="atmosphere" set temp_cheats_copy_path=%volume_letter%:\atmosphere\contents
IF "%~1"=="sxos" set temp_cheats_copy_path=%volume_letter%:\sxos\titles
tools\gnuwin32\bin\grep.exe -c "" <"%cheats_profile_path%" > templogs\tempvar.txt
set /p temp_count=<templogs\tempvar.txt
for /l %%i in (1,1,%temp_count%) do (
	TOOLS\gnuwin32\bin\sed.exe -n %%ip <"%cheats_profile_path%" >templogs\tempvar.txt
	set /p temp_cheat=<templogs\tempvar.txt
	IF NOT EXIST "%temp_cheats_copy_path%\!temp_cheat!" mkdir "%temp_cheats_copy_path%\!temp_cheat!"
	%windir%\System32\Robocopy.exe tools\sd_switch\cheats\titles\!temp_cheat! %temp_cheats_copy_path%\!temp_cheat! /e >nul
)
exit /b

:delete_cfw_files
IF EXIST "%volume_letter%:\atmosphere" rmdir /s /q "%volume_letter%:\atmosphere"
IF EXIST "%volume_letter%:\bootloader" rmdir /s /q "%volume_letter%:\bootloader"
IF EXIST "%volume_letter%:\config" rmdir /s /q "%volume_letter%:\config"
IF EXIST "%volume_letter%:\emummc\emummc.ini" del /q "%volume_letter%:\emummc\emummc.ini"
IF EXIST "%volume_letter%:\ftpd" rmdir /s /q "%volume_letter%:\ftpd"
IF EXIST "%volume_letter%:\modules" rmdir /s /q "%volume_letter%:\modules"
IF EXIST "%volume_letter%:\ReiNX" rmdir /s /q "%volume_letter%:\ReiNX"
IF EXIST "%volume_letter%:\sept" rmdir /s /q "%volume_letter%:\sept"
IF EXIST "%volume_letter%:\SlideNX" rmdir /s /q "%volume_letter%:\SlideNX"
IF EXIST "%volume_letter%:\sxos\titles" rmdir /s /q "%volume_letter%:\sxos\titles"
IF EXIST "%volume_letter%:\boot.dat" del /q "%volume_letter%:\boot.dat"
IF EXIST "%volume_letter%:\hbmenu.nro" del /q "%volume_letter%:\hbmenu.nro"
IF EXIST "%volume_letter%:\xor.play.json" del /q "%volume_letter%:\xor.play.json"
IF EXIST "%volume_letter%:\switch\HekateBrew" rmdir /s /q "%volume_letter%:\switch\HekateBrew"
IF EXIST "%volume_letter%:\switch\atmosphere-updater" rmdir /s /q "%volume_letter%:\switch\atmosphere-updater"
IF EXIST "%volume_letter%:\switch\Kip_Select" rmdir /s /q "%volume_letter%:\switch\Kip_Select"
IF EXIST "%volume_letter%:\switch\Kosmos-Toolbox" rmdir /s /q "%volume_letter%:\switch\Kosmos-Toolbox"
IF EXIST "%volume_letter%:\switch\KosmosUpdater" rmdir /s /q "%volume_letter%:\switch\KosmosUpdater"
IF EXIST "%volume_letter%:\switch\ldnmitm_config" rmdir /s /q "%volume_letter%:\switch\ldnmitm_config"
IF EXIST "%volume_letter%:\switch\ReiNXToolkit" rmdir /s /q "%volume_letter%:\switch\ReiNXToolkit"
IF EXIST "%volume_letter%:\switch\ROMMENU" rmdir /s /q "%volume_letter%:\switch\ROMMENU"
IF EXIST "%volume_letter%:\switch\reboot_to_payload" rmdir /s /q "%volume_letter%:\switch\reboot_to_payload"
IF EXIST "%volume_letter%:\switch\sigpatch-updater" rmdir /s /q "%volume_letter%:\switch\sigpatch-updater"
IF EXIST "%volume_letter%:\switch\SimpleModManager" rmdir /s /q "%volume_letter%:\switch\SimpleModManager"
IF EXIST "%volume_letter%:\switch\sx_installer" rmdir /s /q "%volume_letter%:\switch\sx_installer"
IF EXIST "%volume_letter%:\switch\SXDUMPER" rmdir /s /q "%volume_letter%:\switch\SXDUMPER"
exit /b

:copy_atmosphere_configuration
Setlocal disabledelayedexpansion
IF /i "%atmo_upload_enabled%"=="o" (
	set atmo_upload_enabled=0x1
) else (
	set atmo_upload_enabled=0x0
)
IF /i "%atmo_usb30_force_enabled%"=="o" (
	set atmo_usb30_force_enabled=0x1
) else (
	set atmo_usb30_force_enabled=0x0
)
IF /i "%atmo_ease_nro_restriction%"=="o" (
	set atmo_ease_nro_restriction=0x1
) else (
	set atmo_ease_nro_restriction=0x0
)
IF /i "%atmo_dmnt_cheats_enabled_by_default%"=="o" (
	set atmo_dmnt_cheats_enabled_by_default=0x1
) else (
	set atmo_dmnt_cheats_enabled_by_default=0x0
)
IF /i "%atmo_dmnt_always_save_cheat_toggles%"=="o" (
	set atmo_dmnt_always_save_cheat_toggles=0x1
) else (
	set atmo_dmnt_always_save_cheat_toggles=0x0
)
IF /i "%atmo_enable_hbl_bis_write%"=="o" (
	set atmo_enable_hbl_bis_write=0x1
) else (
	set atmo_enable_hbl_bis_write=0x0
)
IF /i "%atmo_enable_hbl_cal_read%"=="o" (
	set atmo_enable_hbl_cal_read=0x1
) else (
	set atmo_enable_hbl_cal_read=0x0
)
IF /i "%atmo_fsmitm_redirect_saves_to_sd%"=="o" (
	set atmo_fsmitm_redirect_saves_to_sd=0x1
) else (
	set atmo_fsmitm_redirect_saves_to_sd=0x0
)
IF /i "%atmo_enable_deprecated_hid_mitm%"=="o" (
	set atmo_enable_deprecated_hid_mitm=0x1
) else (
	set atmo_enable_deprecated_hid_mitm=0x0
)
IF "%atmo_fatal_auto_reboot_interval%"=="" (
	set atmo_fatal_auto_reboot_interval=0x0
) else (
	set atmo_fatal_auto_reboot_interval=0x%atmo_fatal_auto_reboot_interval%
)
IF "%atmo_power_menu_reboot_function%"=="1" (
set atmo_power_menu_reboot_function=payload
) else IF "%atmo_power_menu_reboot_function%"=="2" (
set atmo_power_menu_reboot_function=rcm
) else IF "%atmo_power_menu_reboot_function%"=="3" (
set atmo_power_menu_reboot_function=normal
) else (
	set atmo_power_menu_reboot_function=payload
)
IF "%atmo_applet_heap_size%"=="" (
	set atmo_applet_heap_size=0x0
) else (
	set atmo_applet_heap_size=0x%atmo_applet_heap_size%
)
IF "%atmo_applet_heap_reservation_size%"=="" (
	set atmo_applet_heap_reservation_size=0x8600000
) else (
	set atmo_applet_heap_reservation_size=0x%atmo_applet_heap_reservation_size%
)
IF "%atmo_hbl_override_key%"=="" (
	set atmo_hbl_override_key=R
) else (
	IF "%inverted_atmo_hbl_override_key%"=="Y" set atmo_hbl_override_key=!%atmo_hbl_override_key%
)
IF "%atmo_hbl_override_any_app_key%"=="" (
	set atmo_hbl_override_any_app_key=R
) else (
	IF "%inverted_atmo_hbl_override_any_app_key%"=="Y" set atmo_hbl_override_any_app_key=!%atmo_hbl_override_any_app_key%
)
IF "%atmo_layeredfs_override_key%"=="" (
	set inverted_atmo_layeredfs_override_key=Y
	set atmo_layeredfs_override_key=L
) else (
	IF "%inverted_atmo_layeredfs_override_key%"=="Y" set atmo_layeredfs_override_key=!%atmo_layeredfs_override_key%
)
IF "%atmo_cheats_override_key%"=="" (
	set inverted_atmo_cheats_override_key=Y
	set atmo_cheats_override_key=L
) else (
	IF "%inverted_atmo_cheats_override_key%"=="Y" set atmo_cheats_override_key=!%atmo_cheats_override_key%
)
echo ; Disable uploading error reports to Nintendo>%volume_letter%:\atmosphere\config\system_settings.ini
echo [eupld]>>%volume_letter%:\atmosphere\config\system_settings.ini
echo upload_enabled = u8!%atmo_upload_enabled%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Enable USB 3.0 superspeed for homebrew>>%volume_letter%:\atmosphere\config\system_settings.ini
echo [usb]>>%volume_letter%:\atmosphere\config\system_settings.ini
echo usb30_force_enabled = u8!%atmo_usb30_force_enabled%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Control whether RO should ease its validation of NROs.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; (note: this is normally not necessary, and ips patches can be used.)>>%volume_letter%:\atmosphere\config\system_settings.ini
echo [ro]>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ease_nro_restriction = u8!%atmo_ease_nro_restriction%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Atmosphere custom settings>>%volume_letter%:\atmosphere\config\system_settings.ini
echo [atmosphere]>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Reboot from fatal automatically after some number of milliseconds.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; If field is not present or 0, fatal will wait indefinitely for user input.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo fatal_auto_reboot_interval = u64!%atmo_fatal_auto_reboot_interval%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Make the power menu's "reboot" button reboot to payload.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Set to "payload" to reboot to "/atmosphere\reboot_to_payload.bin" payload, "normal" for normal reboot, "rcm" for rcm reboot.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo power_menu_reboot_function = str!%atmo_power_menu_reboot_function%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Controls whether dmnt cheats should be toggled on or off by >>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; default. 1 = toggled on by default, 0 = toggled off by default.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo dmnt_cheats_enabled_by_default = u8!%atmo_dmnt_cheats_enabled_by_default%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Controls whether dmnt should always save cheat toggle state>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; for restoration on new game launch. 1 = always save toggles,>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; 0 = only save toggles if toggle file exists.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo dmnt_always_save_cheat_toggles = u8!%atmo_dmnt_always_save_cheat_toggles%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Enable writing to BIS partitions for HBL.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; This is probably undesirable for normal usage.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo enable_hbl_bis_write = u8!%atmo_enable_hbl_bis_write%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Enable reading the CAL0 partition for HBL.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; This is probably undesirable for normal usage.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo enable_hbl_cal_read = u8!%atmo_enable_hbl_cal_read%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Controls whether fs.mitm should redirect save files>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; to directories on the sd card.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; 0 = Do not redirect, 1 = Redirect.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; NOTE: EXPERIMENTAL>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; If you do not know what you are doing, do not touch this yet.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo fsmitm_redirect_saves_to_sd = u8!%atmo_fsmitm_redirect_saves_to_sd%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Controls whether to enable the deprecated hid mitm>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; to fix compatibility with old homebrew.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; 0 = Do not enable, 1 = Enable.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Please note this setting may be removed in a>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; future release of Atmosphere.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo enable_deprecated_hid_mitm = u8!%atmo_enable_deprecated_hid_mitm%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo [hbloader]>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Controls the size of the homebrew heap when running as applet.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; If set to zero, all available applet memory is used as heap.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; The default is zero.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo applet_heap_size = u64!%atmo_applet_heap_size%>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; Controls the amount of memory to reserve when running as applet>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; for usage by other applets. This setting has no effect if>>%volume_letter%:\atmosphere\config\system_settings.ini
echo ; applet_heap_size is non-zero. The default is zero.>>%volume_letter%:\atmosphere\config\system_settings.ini
echo applet_heap_reservation_size = u64!%atmo_applet_heap_reservation_size%>>%volume_letter%:\atmosphere\config\system_settings.ini

echo [hbl_config]>%volume_letter%:\atmosphere\config\override_config.ini
echo ; Program Specific Config>>%volume_letter%:\atmosphere\config\override_config.ini
echo ; Up to 8 program-specific configurations can be set.>>%volume_letter%:\atmosphere\config\override_config.ini
echo ; These use `program_id_#` and `override_key_#`>>%volume_letter%:\atmosphere\config\override_config.ini
echo ; where # is in range [0,7].>>%volume_letter%:\atmosphere\config\override_config.ini
echo program_id_0=010000000000100D>>%volume_letter%:\atmosphere\config\override_config.ini
echo override_key_0=%atmo_hbl_override_key%>>%volume_letter%:\atmosphere\config\override_config.ini
echo.>>%volume_letter%:\atmosphere\config\override_config.ini
echo ; Any Application Config>>%volume_letter%:\atmosphere\config\override_config.ini
echo ; Note that this will only apply to program IDs that>>%volume_letter%:\atmosphere\config\override_config.ini
echo ; are both applications and not specified above>>%volume_letter%:\atmosphere\config\override_config.ini
echo ; by a program specific config.>>%volume_letter%:\atmosphere\config\override_config.ini
echo override_any_app=true>>%volume_letter%:\atmosphere\config\override_config.ini
echo override_any_app_key=%atmo_hbl_override_any_app_key%>>%volume_letter%:\atmosphere\config\override_config.ini
echo path=atmosphere/hbl.nsp>>%volume_letter%:\atmosphere\config\override_config.ini
echo.>>%volume_letter%:\atmosphere\config\override_config.ini
echo [default_config]>>%volume_letter%:\atmosphere\config\override_config.ini
echo override_key=%atmo_layeredfs_override_key%>>%volume_letter%:\atmosphere\config\override_config.ini
echo cheat_enable_key=%atmo_cheats_override_key%>>%volume_letter%:\atmosphere\config\override_config.ini
endlocal
exit /b

:endscript
pause
:endscript2
rmdir /s /q templogs
endlocal