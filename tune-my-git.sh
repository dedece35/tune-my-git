#
# TUNE MY GIT
# 
# Objectif :
#   pouvoir facilement changer de profil GIT afin de pouvoir commiter sous différentes identités
#
# Techniquement :
#   - modifier le .gitconfig
#   - modifier les fichiers SSH
#
# AUTEUR :
#   David DE CARVALHO
#   @dedece35
#   27/10/2017
#

afficherAide() {
    echo ""
	echo "Script permettant de configurer le profil GIT"
    echo ""
	echo "Usage :"
    echo "  tune-my-git.sh <PROFIL>"
    echo ""
    listerProfiles
    exit 1
}

listerProfiles() {
    echo "Liste des profils disponibles : "
    echo "`ls profiles`"
}

verifierProfile() {

    if [[ ! -d "./profiles" ]]
    then
        echo ""
        echo "ERREUR => Le répertoire './profiles' est obligatoire et doit contenir au moins un sous-répertoire avec le nom d'un profil"
        echo ""
        exit 1
    fi

    if [[ ! -d "./profiles/$1" ]]
    then
        echo ""
        echo "ERREUR => Le profil '$1' N'existe PAS"
        echo ""
        listerProfiles
        exit 1
    fi

    if [[ ! -f "./profiles/$1/id_rsa" ]]
    then
        echo ""
        echo "ERREUR => Le profil '$1' est INVALIDE : le fichier 'id_rsa' est manquant"
        echo ""
        exit 1
    fi

    if [[ ! -f "./profiles/$1/id_rsa.pub" ]]
    then
        echo ""
        echo "ERREUR => Le profil '$1' est INVALIDE : le fichier 'id_rsa.pub' est manquant"
        echo ""
        exit 1
    fi

    if [[ ! -f "./profiles/$1/.gitconfig" ]]
    then
        echo ""
        echo "ERREUR => Le profil '$1' est INVALIDE : le fichier '.gitconfig' est manquant"
        echo ""
        exit 1
    fi

}

# verification du nb de paramètre
if [[ $# != 1 ]]
then
    afficherAide
else

    verifierProfile $1

    echo ""
    echo "Application du profil GIT '$1'"

    if [[ ! -d ~/.ssh ]]
    then
        echo "Répertoire '.ssh' INEXISTANT => création du répertoire"
    fi

    echo "Mise en place du fichier SSH 'id_rsa' du profile '$1'"
    cp "./profiles/$1/id_rsa" ~/.ssh/.

    echo "Mise en place du fichier SSH 'id_rsa.pub' du profile '$1'"
    cp "./profiles/$1/id_rsa.pub" ~/.ssh/.

    echo "Mise en place du fichier de conf GIT '.gitconfig' du profile '$1'"
    cp "./profiles/$1/.gitconfig" ~/.

    echo ""
fi