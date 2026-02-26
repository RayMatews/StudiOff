# PowerShell script to setup GitHub and push StudiOff

Write-Host "=== Configuration GitHub pour StudiOff ===" -ForegroundColor Cyan

# Check if gh is installed
$ghPath = Get-Command gh -ErrorAction SilentlyContinue

if (-not $ghPath) {
    Write-Host "`nGitHub CLI n'est pas installé!" -ForegroundColor Red
    Write-Host "Télécharger depuis: https://github.com/cli/cli/releases/latest"
    Write-Host "`nOu utilisez le navigateur pour télécharger et installer gh"
    Write-Host "`nAprès installation, exécutez ce script à nouveau"
    exit 1
}

# Check auth status
Write-Host "`nVérification de l'authentification..." -ForegroundColor Yellow
gh auth status

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nConnexion à GitHub requise..." -ForegroundColor Yellow
    gh auth login
}

# Create repo
Write-Host "`nCréation du dépôt GitHub..." -ForegroundColor Yellow
gh repo create StudiOff --private --source=. --push

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Code poussé avec succès!" -ForegroundColor Green
    Write-Host "`nProchaines étapes:" -ForegroundColor Cyan
    Write-Host "1. Allez sur https://vercel.com" -ForegroundColor White
    Write-Host "2. Connectez-vous avec votre compte GitHub" -ForegroundColor White
    Write-Host "3. New...' > 'Project'" -ForegroundColor White
    Write-Hostez le dépôt ' Cliquez sur 'Add "4. ImportStudiOff'" -ForegroundColor White
    Write-Host "5. Cliquez 'Deploy' - le déploiement démarrera automatiquement!" -ForegroundColor White
} else {
    Write-Host "`n❌ Erreur lors de la création du dépôt" -ForegroundColor Red
}
