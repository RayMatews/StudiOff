# ====================================
# StudiOff - Configuration Supabase
# ====================================
# Ce script vous aide à configurer Supabase pour StudiOff
# Exécutez: .\setup_supabase_config.ps1

param(
    [string]$SupabaseUrl,
    [string]$SupabaseAnonKey,
    [string]$StripePublishableKey
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  StudiOff - Configuration Supabase" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ====================================
# 1. Vérifier Supabase CLI
# ====================================
Write-Host "[1/5] Vérification de Supabase CLI..." -ForegroundColor Yellow

$supabaseCLI = $false
try {
    $version = supabase --version 2>&1
    Write-Host "  ✓ Supabase CLI installé: $version" -ForegroundColor Green
    $supabaseCLI = $true
} catch {
    Write-Host "  ⚠ Supabase CLI non installé" -ForegroundColor DarkYellow
    Write-Host "    Pour l'installer: npm install -g supabase" -ForegroundColor Gray
    Write-Host "    Vous pouvez continuer sans CLI (configuration manuelle)" -ForegroundColor Gray
}

Write-Host ""

# ====================================
# 2. Demander les informations
# ====================================
Write-Host "[2/5] Configuration des variables d'environnement..." -ForegroundColor Yellow
Write-Host ""

if (-not $SupabaseUrl) {
    Write-Host "  Entrez votre SUPABASE_URL" -ForegroundColor White
    Write-Host "  (ex: https://abcdefgh.supabase.co)" -ForegroundColor Gray
    $SupabaseUrl = Read-Host "  SUPABASE_URL"
}

if (-not $SupabaseAnonKey) {
    Write-Host ""
    Write-Host "  Entrez votre SUPABASE_ANON_KEY" -ForegroundColor White
    Write-Host "  (commence par eyJ...)" -ForegroundColor Gray
    $SupabaseAnonKey = Read-Host "  SUPABASE_ANON_KEY"
}

if (-not $StripePublishableKey) {
    Write-Host ""
    Write-Host "  Entrez votre STRIPE_PUBLISHABLE_KEY (optionnel, appuyez Entrée pour ignorer)" -ForegroundColor White
    Write-Host "  (commence par pk_test_ ou pk_live_)" -ForegroundColor Gray
    $StripePublishableKey = Read-Host "  STRIPE_PUBLISHABLE_KEY"
}

Write-Host ""

# ====================================
# 3. Valider les entrées
# ====================================
Write-Host "[3/5] Validation des entrées..." -ForegroundColor Yellow

$valid = $true

if ($SupabaseUrl -match "^https://[a-z0-9]+\.supabase\.co$") {
    Write-Host "  ✓ SUPABASE_URL valide" -ForegroundColor Green
} else {
    Write-Host "  ✗ SUPABASE_URL invalide (format attendu: https://xxx.supabase.co)" -ForegroundColor Red
    $valid = $false
}

if ($SupabaseAnonKey -match "^eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$") {
    Write-Host "  ✓ SUPABASE_ANON_KEY valide (format JWT)" -ForegroundColor Green
} else {
    Write-Host "  ✗ SUPABASE_ANON_KEY invalide (doit être un token JWT)" -ForegroundColor Red
    $valid = $false
}

if ($StripePublishableKey) {
    if ($StripePublishableKey -match "^pk_(test|live)_[A-Za-z0-9]+$") {
        Write-Host "  ✓ STRIPE_PUBLISHABLE_KEY valide" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ STRIPE_PUBLISHABLE_KEY format inhabituel" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  ℹ STRIPE_PUBLISHABLE_KEY non configuré (optionnel)" -ForegroundColor Gray
}

Write-Host ""

if (-not $valid) {
    Write-Host "❌ Configuration invalide. Veuillez vérifier vos entrées." -ForegroundColor Red
    exit 1
}

# ====================================
# 4. Créer le fichier .env
# ====================================
Write-Host "[4/5] Création du fichier .env..." -ForegroundColor Yellow

$envContent = @"
# ==========================================
# StudiOff - Variables d'environnement
# ==========================================
# Ce fichier est généré automatiquement
# NE PAS COMMITER CE FICHIER DANS GIT!

# Supabase Configuration
SUPABASE_URL=$SupabaseUrl
SUPABASE_ANON_KEY=$SupabaseAnonKey

# Stripe Configuration (optionnel)
STRIPE_PUBLISHABLE_KEY=$StripePublishableKey

# Application Mode
# true = Mode démo (pas de backend requis)
# false = Mode production (Supabase requis)
DEMO_MODE=false
"@

$envPath = Join-Path $PSScriptRoot ".env"
$envContent | Out-File -FilePath $envPath -Encoding UTF8 -Force

Write-Host "  ✓ Fichier .env créé: $envPath" -ForegroundColor Green

# Vérifier .gitignore
$gitignorePath = Join-Path $PSScriptRoot ".gitignore"
if (Test-Path $gitignorePath) {
    $gitignoreContent = Get-Content $gitignorePath -Raw
    if ($gitignoreContent -notmatch "\.env") {
        Add-Content -Path $gitignorePath -Value "`n# Environment variables`n.env`n.env.*"
        Write-Host "  ✓ .env ajouté à .gitignore" -ForegroundColor Green
    } else {
        Write-Host "  ✓ .env déjà dans .gitignore" -ForegroundColor Green
    }
} else {
    @"
# Environment variables
.env
.env.*
"@ | Out-File -FilePath $gitignorePath -Encoding UTF8
    Write-Host "  ✓ .gitignore créé avec .env" -ForegroundColor Green
}

Write-Host ""

# ====================================
# 5. Test de connexion
# ====================================
Write-Host "[5/5] Test de connexion à Supabase..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$SupabaseUrl/rest/v1/" -Headers @{
        "apikey" = $SupabaseAnonKey
        "Authorization" = "Bearer $SupabaseAnonKey"
    } -Method Get -ErrorAction Stop
    
    Write-Host "  ✓ Connexion à Supabase réussie!" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "  ✗ Erreur d'authentification - Vérifiez votre ANON_KEY" -ForegroundColor Red
    } elseif ($statusCode -eq 404) {
        Write-Host "  ✓ Connexion établie (API REST accessible)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Impossible de tester la connexion: $_" -ForegroundColor DarkYellow
    }
}

Write-Host ""

# ====================================
# Résumé
# ====================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONFIGURATION TERMINÉE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ Fichier .env configuré" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor White
Write-Host "  1. Exécutez la migration SQL dans Supabase Dashboard" -ForegroundColor Cyan
Write-Host "     Fichier: supabase/migrations/001_initial_schema.sql" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Créez le bucket Storage 'audio'" -ForegroundColor Cyan
Write-Host "     Dashboard > Storage > New bucket > 'audio' (private)" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Déployez les Edge Functions" -ForegroundColor Cyan
if ($supabaseCLI) {
    Write-Host "     supabase functions deploy generate-audio" -ForegroundColor Gray
    Write-Host "     supabase functions deploy stripe-webhook" -ForegroundColor Gray
} else {
    Write-Host "     Via Dashboard > Edge Functions" -ForegroundColor Gray
}
Write-Host ""
Write-Host "  4. Lancez l'application:" -ForegroundColor Cyan
Write-Host "     flutter run -d chrome" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

# Demander si l'utilisateur veut ouvrir le guide
Write-Host ""
$openGuide = Read-Host "Voulez-vous ouvrir le guide complet? (O/N)"
if ($openGuide -eq "O" -or $openGuide -eq "o") {
    $guidePath = Join-Path $PSScriptRoot "setup_supabase_guide.md"
    if (Test-Path $guidePath) {
        Start-Process $guidePath
    }
}
