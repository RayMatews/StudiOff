Write-Host "# Script d'installation et de lancement du stack StudiOff"

# 1. Construction du frontend Flutter Web
Write-Host "1. Construction du frontend Flutter Web..."
flutter build web

# 2. Construction des Edge Functions (npm install)
Write-Host "2. Construction des Edge Functions (npm install)..."
if (Test-Path ./supabase/functions/package.json) {
    Push-Location ./supabase/functions
    npm install
    Pop-Location
} else {
    Write-Host "Aucun package.json trouvé dans supabase/functions. Étape ignorée."
}

# 3. Vérification du fichier .env
Write-Host "3. Vérification du fichier .env..."
if (!(Test-Path .env)) {
    Write-Host "Fichier .env manquant. Veuillez le créer avec vos clés Supabase, Stripe, ElevenLabs."
    exit 1
}

# 4. Vérification du docker-compose.yml
Write-Host "4. Vérification du fichier docker-compose.yml..."
if (!(Test-Path docker-compose.yml)) {
    Write-Host "Fichier docker-compose.yml manquant à la racine du projet. Veuillez le créer avant de continuer."
    exit 1
}

# 5. Lancement du stack Docker Compose
Write-Host "5. Lancement du stack Docker Compose..."
docker-compose up -d --build

# 6. Attendre que la base soit prête (optionnel, simple sleep)
Start-Sleep -Seconds 10

# 7. Application des migrations SQL
Write-Host "6. Application des migrations SQL..."
$migrations = Get-ChildItem -Path ./supabase/migrations/*.sql | Sort-Object Name
foreach ($migration in $migrations) {
    Write-Host "  -> $($migration.Name)"
    # Utilise psql local si dispo, sinon tente via docker
    if (Get-Command psql -ErrorAction SilentlyContinue) {
        psql -h localhost -p 5432 -U postgres -d postgres -f $migration.FullName
    } else {
        Write-Host "psql non trouvé localement. Tentative via Docker..."
        docker run --rm -v $(pwd):/scripts --network=host -e PGPASSWORD=postgres postgres:15-alpine psql -h localhost -p 5432 -U postgres -d postgres -f /scripts/$($migration.FullName.Replace("\\","/").Split("/",[System.StringSplitOptions]::RemoveEmptyEntries)[-1])
    }
}

# 8. Accès
Write-Host "7. Accès :"
Write-Host " - Supabase : http://localhost:54323"
Write-Host " - Frontend : http://localhost:8080"
Write-Host " - Edge Functions : http://localhost:3000"