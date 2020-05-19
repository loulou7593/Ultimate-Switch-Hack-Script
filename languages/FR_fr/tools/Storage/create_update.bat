goto:%~1

:display_title
title ChoiDuJour %this_script_version% - Shadow256 Ultimate Switch Hack Script %ushs_version%
goto:eof

:folder_script_param_error
echo Une erreur de saisie du paramètre du dossier s'est produite, le script va s'arrêter.
goto:eof

:warning_firmware_max_create
echo Attention: Le package de firmware maximum qui peut être créé est pour le firmware 6.1.0, les firmwares supérieurs à ce dernier provoqueront une erreur.
goto:eof

:define_new_keys_file_choice
set /p define_new_keys_file=Souhaitez-vous définir un nouveau fichier de clés par défaut? ^(%lng_yes_choice%/%lng_no_choice%^): 
goto:eof

:keys_file_not_finded
echo Fichiers clés non trouvé, veuillez suivre les instructions.
goto:eof

:keys_file_selection
IF /i NOT "%define_new_keys_file%"=="o" (
	echo Veuillez renseigner le fichier de clés dans la fenêtre suivante.
	pause
)
%windir%\system32\wscript.exe //Nologo "%calling_script_dir%\TOOLS\Storage\functions\open_file.vbs" "" "Fichier de liste de clés Switch^(*.*^)|*.*|" "Sélection du fichier de clés pour Hactool" "%calling_script_dir%\templogs\tempvar.txt"
goto:eof

:no_keys_file_selected_error
echo Aucun fichier clés renseigné, le script va s'arrêter.
goto:eof

:choidujour_keys_file_creation
IF "%create_choidujour_keys_file_state%"=="0" (
	echo Création du fichier "ChoiDuJour_keys.txt" effectuée avec succès.
) else IF "%create_choidujour_keys_file_state%"=="1" (
	echo La clé "%key_missing%" obligatoire ne se trouve pas dans le fichier de clé, le script ne peux pas continuer.
) else IF "%create_choidujour_keys_file_state%"=="2" (
	echo La dernière clé facultative trouvée est la clé "%key_missing%", vous ne pourrez générer que des packages de mise à jour jusqu'au firmware n'utilisant que les clés jusqu'à celle-ci.
)
goto:eof

:choidujour_keys_file_create_error
echo Il semble que le fichier de clés nécessaire à ChoiDuJour n'ait pu être créé, veuillez vérifier votre fichier de clés et relancer le script.
echo Pour vous aider, regarder les clés incorrectes qui se sont affichées juste avant.
goto:eof

:launch_xci_explorer_choice
echo Il est possible de lancer XCI Explorer pour extraire la partition "update" d'un fichier XCI. Notez que si vous choisissez de le lancer, le script ne pourra continuer qu'après la fermeture de XCI Explorer.
set /p launch_xci_explorer=Souhaitez-vous lancer XCI Explorer? ^(%lng_yes_choice%/%lng_no_choice%^): 
goto:eof

:package_type_choice
echo Quel est le type de package de mise à jour:
echo 1: Répertoire?
echo 2: Fichier?
echo.
set /p update_type=Sélectionner le type de package de mise à jour: 
goto:eof

:no_package_type_selected_error
echo Vous devez sélectionner un type de package.
goto:eof

:package_folder_select
%windir%\system32\wscript.exe //Nologo "%calling_script_dir%\TOOLS\Storage\functions\select_dir.vbs" "%calling_script_dir%\templogs\tempvar.txt" "Sélection du dossier contenant la mise à jour extraite"
goto:eof

:package_file_select
%windir%\system32\wscript.exe //Nologo "%calling_script_dir%\TOOLS\Storage\functions\open_file.vbs" "" "Fichier de partition Switch^(*.hfs0^)|*.hfs0|" "Sélection du fichier de mise à jour firmware Switch" "%calling_script_dir%\templogs\tempvar.txt"
goto:eof

:bad_choice_error
echo Ce choix n'est pas supporté.
goto:eof

:no_source_selected_error
echo Aucun fichier ou répertoire de mise à jour  renseigné, le script va s'arrêter.
goto:eof

:sigpatches_param_choice
set /p enable_sigpatches=Souhaitez-vous activer la vérification des signatures ^(nécessaire pour installer du contenu non signé^)? ^(%lng_yes_choice%/%lng_no_choice%^): 
goto:eof

:nogc_param_choice
set /p disable_gamecard=Souhaitez-vous désactiver le port cartouche pour éviter la mise à jour du firmware de celui-ci ^(à utiliser si la console n'est jamais passé au-dessus du firmware 4.0.0^)? ^(%lng_yes_choice%/%lng_no_choice%^): 
goto:eof

:noexfat_param_choice
set /p no_exfat=Souhaitez-vous désactiver le support pour le format EXFAT des cartes SD? ^(%lng_yes_choice%/%lng_no_choice%^): 
goto:eof

:package_creation_success
echo Firmware créé avec succès dans le répertoire "update_packages" du script.
goto:eof

:package_creation_error
echo Un problème est survenu pendant la création du firmware.
echo Vérifiez que les fichiers "ChoiDujour.exe", "hactool.exe", "keys.txt", "libmbedcrypto.dll", "libmbedtls.dll", "libmbedx509.dll" et "update.hfs0" sont bien à côté de ce script.
echo Vérifiez également que vous avez bien toutes les clés requises dans le fichier "keys.txt".
goto:eof