@echo off
echo ========================================
echo   Script pour pousser vers GitHub
echo ========================================
echo.

echo Etape 1: Creez un depot vide sur GitHub:
echo   1. Allez sur https://github.com/new
echo   2. Repository name: StudiOff
echo   3. Selectionnez: Public
echo   4. NE cochez PAS "Add a README file"
echo   5. Cliquez "Create repository"
echo.
echo APPUEYEZ SUR ENTREE QUAND FAIT...
pause >nul

echo.
echo Etape 2: Ajout des fichiers...
git add .
git status

echo.
echo Etape 3: Commit...
git commit -m "Deploy StudiOff on Vercel - Initial commit"

echo.
echo Etape 4: Connexion a GitHub (connectez-vous si demande)
echo.

echo Etape 5: Push vers GitHub
git branch -M main
git remote add origin https://github.com/RayMatews/StudiOff.git
git push -u origin main

echo.
echo ========================================
echo   Termine!
echo ========================================
pause
