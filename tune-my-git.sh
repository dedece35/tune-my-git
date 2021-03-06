#!/bin/bash

#
# AUTEUR :
#   David DE CARVALHO
#   @dedece35
#   27/10/2017
#

is_backup_actif=1
dir_script=`dirname "$0"`
dir_profil="$dir_script/profiles"
option_disable_backups1="-db"
option_disable_backups2="--disable-backups"
option_help1="-h"
option_help2="--help"
fic_conf_tunemygit="$dir_script/.tunemygit"
str_is_profile_from_conf=""

# afficher l'aide du script
afficherAide() {
    echo ""
    echo " _____                                             ___       _      ";
    echo "(_   _)                                           (  _\`\  _ ( )_    ";
    echo "  | | _   _   ___     __       ___ ___   _   _    | ( (_)(_)| ,_)   ";
    echo "  | |( ) ( )/' _ \`\ /'__\`\   /' _ \` _ \`\( ) ( )   | |___ | || |     ";
    echo "  | || (_) || ( ) |(  ___/   | ( ) ( ) || (_) |   | (_, )| || |_    ";
    echo "  (_)\`\___/'(_) (_)\`\____)   (_) (_) (_)\`\__, |   (____/'(_)\`\__)   ";
    echo "                                        ( )_| |                     ";
    echo "                                        \`\___/'                     ";
    echo ""
    echo -e "\nScript permettant d'activer un profil GIT"
    echo -e "(Ecrasement des fichiers ~/.gitconfig, ~/.ssh/id_rsa, ~/.ssh/id_rsa.pub)"
    echo -e "\nUsage :"
    echo -e "  tune-my-git.sh <OPTIONS> <PROFIL>"
    echo -e "\nOPTIONS : "
    echo -e "$option_disable_backups1, $option_disable_backups2 : désactive le backup des fichiers remplacées (backup avec extension du type '.bkp-<timestamp>'"
    echo -e "$option_help1, $option_help2 : affiche l'aide du script"
    echo -e "\nPROFIL : nom du profil à activer (facultatif => si non fourni, alors récupération du profil à activer dans le fichier ${fic_conf_tunemygit}"
    listerProfiles
    exit 1
}

# lister les profiles disponibles
listerProfiles() {
    echo -e "\nListe des profils disponibles : "

    if [[ ! -d "$dir_profil" ]]
    then
        echo -e "AUCUN\n   => \033[33;41m   ERREUR   \033[0m Le répertoire '$dir_profil' est obligatoire et doit contenir au moins un sous-répertoire avec le nom d'un profil\n"
        exit 1
    fi

    lstProfiles=`ls $dir_profil`
    if [[ "$lstProfiles" == "" ]]
    then
        echo -e "AUCUN\n   => \033[33;41m   ERREUR   \033[0m Le répertoire '$dir_profil' doit contenir au moins un sous-répertoire avec le nom d'un profil\n"
        exit 1
    fi

    echo "$lstProfiles"
}

# verification que le profile contient les fichiers nécessaires
verifierProfile() {

    if [[ ! -d "$dir_profil" ]]
    then
        echo -e "\n\033[33;41m   ERREUR   \033[0m Le répertoire '$dir_profil' est obligatoire et doit contenir au moins un sous-répertoire avec le nom d'un profil\n"
        exit 1
    fi

    dir_profil_cur="$dir_profil/$1"
    if [[ ! -d "$dir_profil_cur" ]]
    then
        echo -e "\n\033[33;41m   ERREUR   \033[0m Le profil '$1' N'existe PAS (répertoire '$dir_profil_cur')"
        listerProfiles
        exit 1
    fi

    fic_idrsa_cur="$dir_profil_cur/id_rsa"
    if [[ ! -f "$fic_idrsa_cur" ]]
    then
        echo -e "\n\033[33;41m   ERREUR   \033[0m Le profil '$1' est INVALIDE : le fichier 'id_rsa' est manquant (fichier '$fic_idrsa_cur')\n"
        exit 1
    fi

    fic_idrsapub_cur="$dir_profil_cur/id_rsa.pub"
    if [[ ! -f "$fic_idrsapub_cur" ]]
    then
        echo -e "\n\033[33;41m   ERREUR   \033[0m Le profil '$1' est INVALIDE : le fichier 'id_rsa.pub' est manquant (fichier '$fic_idrsapub_cur')\n"
        exit 1
    fi

    fic_gitconfig_cur="$dir_profil_cur/.gitconfig"
    if [[ ! -f "$fic_gitconfig_cur" ]]
    then
        echo -e "\n\033[33;41m   ERREUR   \033[0m Le profil '$1' est INVALIDE : le fichier '.gitconfig' est manquant (fichier '$fic_gitconfig_cur')\n"
        exit 1
    fi

}

# verification du nb de paramètre
if [[ $# != 1 && $# != 2 ]]
then
    afficherAide
fi

# verification de l'option help
if [[ "$1" == "$option_help1" || "$1" == "$option_help2" ]]
then
    afficherAide
fi

profile_cur=$1

# verification du profil et de l'option "disable_backup"
if [[ "$1" == "$option_disable_backups1" || "$1" == "$option_disable_backups2" ]]
then
    is_backup_actif=0
    profile_cur=$2
else
    echo -e "\n\033[33;41m   ERREUR   \033[0m L'option '$1' N'est PAS une option valide avec l'utilisation d'un profil"
    afficherAide
fi

# recuperation du profil sauvegardée si possible
if [[ "$profile_cur" == "" ]]
then
    if [[ -f "$fic_conf_tunemygit" ]]
    then
        profile_cur=`cat $fic_conf_tunemygit`
        str_is_profile_from_conf=" (à partir du fichier $fic_conf_tunemygit)"
    else
        echo -e "\n\033[33;41m   ERREUR   \033[0m Pas de profil fourni en option et pas de fichier de profil courant trouvé ($fic_conf_tunemygit). Merci de passer en paramètre un profil au moins une fois."
        afficherAide
    fi
fi

verifierProfile $profile_cur

# Activation du profil
echo -e "\nActivation du profil GIT \033[1;43m   '$profile_cur'   \033[0m $str_is_profile_from_conf: "

# ajout répertoire manquant
if [[ ! -d ~/.ssh ]]
then
    echo "- Répertoire '.ssh' INEXISTANT => création du répertoire"
    mkdir ~/.ssh
fi

# gestion des backups
if [[ $is_backup_actif == 1 ]]
then
    echo -e "\033[5;43m   WARNING   \033[0m mode backup actif (par défaut) : pour le désactiver, utiliser l'option '$option_disable_backups'" ;

    timestamp=$(awk 'BEGIN {srand(); print srand()}')

    echo "- Backup du fichier SSH 'id_rsa' (dans répertoire ~/.ssh)"
    cp ~/.ssh/id_rsa ~/.ssh/id_rsa.bkp-$timestamp

    echo "- Backup du fichier SSH 'id_rsa.pub' (dans répertoire ~/.ssh)"
    cp ~/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub.bkp-$timestamp

    echo "- Backup du fichier de conf GIT '.gitconfig' (dans répertoire ~)"
    cp ~/.gitconfig ~/.gitconfig.bkp-$timestamp
fi

# modification des fichiers suivant le prodil
echo "- Sauvegarde profil courant dans fichier ${fic_conf_tunemygit}"
echo "$profile_cur" > "$fic_conf_tunemygit"

echo "- Mise en place du fichier SSH 'id_rsa' du profile '$profile_cur'"
cp "$dir_script/profiles/$profile_cur/id_rsa" ~/.ssh/.

echo "- Mise en place du fichier SSH 'id_rsa.pub' du profile '$profile_cur'"
cp "$dir_script/profiles/$profile_cur/id_rsa.pub" ~/.ssh/.

echo "- Mise en place du fichier de conf GIT '.gitconfig' du profile '$profile_cur'"
cp "$dir_script/profiles/$profile_cur/.gitconfig" ~/.

echo ""