#!/bin/bash

# Script pour créer un dépôt GitHub et pousser StudiOff
# Instructions:
# 1. Installez GitHub CLI depuis: https://cli.github.com
# 2. Exécutez ce script

echo "=== Création du dépôt GitHub pour StudiOff ==="

# Vérifier si gh est installé
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) n'est pas installé!"
    echo ""
    echo "Veuillez installer GitHub CLI:"
    echo "- Téléchargez: https://github.com/cli/cli/releases"
    echo "- Ou utilisez: winget install GitHub.cli"
    echo ""
    echo "Après installation, exécutez:"
    echo "  gh auth login"
    echo "  ./create_github_repo.sh"
    exit 1
fi

# Authentification
echo "Vérification de l'authentification..."
gh auth status || gh auth login

# Créer le dépôt
echo ""
echo "Création du dépôt GitHub..."
gh repo create StudiOff --private --source=. --push

echo ""
echo "✅ Dépôt créé et code poussé avec succès!"
echo ""
echo "Prochaines étapes:"
echo "1. Allez sur https://vercel.com"
echo "2. Importez votre dépôt GitHub"
echo "3. Vercel déploiera automatiquement l'application"
