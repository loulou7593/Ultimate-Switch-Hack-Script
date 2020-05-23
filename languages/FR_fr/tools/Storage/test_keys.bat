goto:%~1

:display_title
title Tester un fichier de clés %this_script_version% - Shadow256 Ultimate Switch Hack Script %ushs_version%
goto:eof

:intro
echo Ce script permet de vérifier le contenu d'un fichier de clés et d'indiquer les clés inconnues/uniques qu'il contient ainsi que les clés incorrecte.
goto:eof

:keys_file_choice
%windir%\system32\wscript.exe //Nologo "TOOLS\Storage\functions\open_file.vbs" "" "Tous les fichiers ^(*.*^)|*.*|" "Sélection du fichier de clés" "templogs\tempvar.txt"
goto:eof

:no_keys_file_selected_error
echo Aucun fichier sélectionné, le script va s'arrêter.
goto:eof

:total_keys
echo nombre de clés possibles à analyser: %possible_analysed_keys%
goto:eof

:correct_keys
IF "%correct_keys_state%"=="0" (
	echo Aucune clé correcte vérifiable trouvée.
) else IF "%correct_keys_state%"=="1" (
	echo clé correcte vérifiable trouvée: %unknown_keys%
) else IF "%correct_keys_state%"=="2" (
	echo %count_correct_keys% clés correctes vérifiables trouvées: %correct_keys%
)
goto:eof

:unknown_keys
IF "%unknown_keys_state%"=="0" (
	echo Aucune clé inconnue ou unique à la console trouvée.
) else IF "%unknown_keys_state%"=="1" (
	echo clé inconnue ou unique à la console trouvée: %unknown_keys%
) else IF "%unknown_keys_state%"=="2" (
	echo %count_unknown_keys% clés inconnues ou uniques à la console trouvées: %unknown_keys%
)
goto:eof

:possible_missing_keys
IF "%possible_missing_keys_state%"=="0" (
	echo Aucune clé manquante vérifiable trouvée.
) else IF "%possible_missing_keys_state%"=="1" (
	echo Clés manquante vérifiable trouvée: %possible_missing_keys%
) else IF "%possible_missing_keys_state%"=="2" (
	echo %count_possible_missing_keys% clés manquantes vérifiables trouvées: %possible_missing_keys%
)
goto:eof

:missing_keys
IF "%missing_keys_state%"=="0" (
	echo Aucune clé incorrecte trouvée.
) else IF "%missing_keys_state%"=="1" (
	echo Clé incorrecte trouvée: %missing_keys%
) else IF "%missing_keys_state%"=="2" (
	echo %count_missing_keys% clés incorrectes trouvées: %missing_keys%
)
goto:eof