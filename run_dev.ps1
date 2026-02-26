# run_dev.ps1 - Script pour lancer StudiOff en mode développement
# Usage: .\run_dev.ps1

# Charger les variables d'environnement depuis .env
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]*)\s*=\s*(.*)\s*$") {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
            Write-Host "Loaded: $name" -ForegroundColor Green
        }
    }
} else {
    Write-Host "ERREUR: Fichier .env non trouvé!" -ForegroundColor Red
    Write-Host "Copiez .env.example vers .env et remplissez vos valeurs" -ForegroundColor Yellow
    exit 1
}

# Vérifier les variables obligatoires
$required = @("SUPABASE_URL", "SUPABASE_ANON_KEY")
$missing = @()

foreach ($var in $required) {
    $value = [Environment]::GetEnvironmentVariable($var)
    if ([string]::IsNullOrEmpty($value) -or $value -like "*your-*" -or $value -like "*YOUR_*") {
        $missing += $var
    }
}

if ($missing.Count -gt 0) {
    Write-Host "`nERREUR: Variables manquantes ou non configurées:" -ForegroundColor Red
    foreach ($var in $missing) {
        Write-Host "  - $var" -ForegroundColor Yellow
    }
    Write-Host "`nModifiez le fichier .env avec vos vraies valeurs Supabase" -ForegroundColor Cyan
    exit 1
}

Write-Host "`n=== Lancement de StudiOff ===" -ForegroundColor Cyan
Write-Host "SUPABASE_URL: $env:SUPABASE_URL" -ForegroundColor Gray

# Construire les arguments dart-define
$dartDefines = @(
    "--dart-define=SUPABASE_URL=$env:SUPABASE_URL",
    "--dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY"
)

if ($env:STRIPE_PUBLISHABLE_KEY) {
    $dartDefines += "--dart-define=STRIPE_PUBLISHABLE_KEY=$env:STRIPE_PUBLISHABLE_KEY"
}

# Lancer Flutter
Write-Host "`nDémarrage de l'application..." -ForegroundColor Green
flutter run -d chrome $dartDefines
