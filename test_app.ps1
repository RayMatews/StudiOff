# ====================================
# StudiOff - Script de Test
# ====================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  StudiOff - Tests de l'application" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$errors = @()
$warnings = @()

# ====================================
# 1. Vérification des prérequis
# ====================================
Write-Host "[1/6] Vérification des prérequis..." -ForegroundColor Yellow

# Flutter
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "  ✓ Flutter: $flutterVersion" -ForegroundColor Green
} catch {
    $errors += "Flutter non installé"
    Write-Host "  ✗ Flutter non trouvé" -ForegroundColor Red
}

# Supabase CLI (optionnel)
try {
    $supabaseVersion = supabase --version 2>&1
    Write-Host "  ✓ Supabase CLI: $supabaseVersion" -ForegroundColor Green
} catch {
    $warnings += "Supabase CLI non installé (optionnel pour le mode démo)"
    Write-Host "  ⚠ Supabase CLI non trouvé (optionnel)" -ForegroundColor DarkYellow
}

Write-Host ""

# ====================================
# 2. Vérification de la structure
# ====================================
Write-Host "[2/6] Vérification de la structure du projet..." -ForegroundColor Yellow

$requiredFiles = @(
    "pubspec.yaml",
    "lib/main.dart",
    "lib/app/app.dart",
    "lib/app/router.dart",
    "lib/services/supabase_service.dart",
    "lib/services/audio_service.dart",
    "lib/services/auth_service.dart",
    "lib/services/stripe_service.dart",
    "lib/models/user_profile.dart",
    "lib/models/audio_project.dart",
    "lib/models/subscription.dart",
    "lib/providers/auth_provider.dart",
    "lib/providers/audio_provider.dart",
    "supabase/migrations/001_initial_schema.sql",
    "supabase/functions/generate-audio/index.ts",
    "supabase/functions/stripe-webhook/index.ts",
    "supabase/functions/create-checkout-session/index.ts",
    "supabase/functions/create-portal-session/index.ts"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        $missingFiles += $file
        Write-Host "  ✗ $file MANQUANT" -ForegroundColor Red
    }
}

if ($missingFiles.Count -gt 0) {
    $errors += "Fichiers manquants: $($missingFiles -join ', ')"
}

Write-Host ""

# ====================================
# 3. Vérification des dépendances
# ====================================
Write-Host "[3/6] Vérification des dépendances Flutter..." -ForegroundColor Yellow

$pubGetResult = flutter pub get 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Dépendances installées" -ForegroundColor Green
} else {
    $errors += "Erreur lors de l'installation des dépendances"
    Write-Host "  ✗ Erreur: $pubGetResult" -ForegroundColor Red
}

Write-Host ""

# ====================================
# 4. Analyse du code
# ====================================
Write-Host "[4/6] Analyse statique du code Dart..." -ForegroundColor Yellow

$analyzeResult = flutter analyze 2>&1
$analyzeErrors = $analyzeResult | Select-String -Pattern "error" | Measure-Object
$analyzeWarnings = $analyzeResult | Select-String -Pattern "warning" | Measure-Object

if ($analyzeErrors.Count -eq 0) {
    Write-Host "  ✓ Aucune erreur d'analyse" -ForegroundColor Green
} else {
    Write-Host "  ✗ $($analyzeErrors.Count) erreur(s) trouvée(s)" -ForegroundColor Red
    $errors += "$($analyzeErrors.Count) erreurs d'analyse Dart"
}

if ($analyzeWarnings.Count -gt 0) {
    Write-Host "  ⚠ $($analyzeWarnings.Count) warning(s)" -ForegroundColor DarkYellow
}

Write-Host ""

# ====================================
# 5. Tests unitaires
# ====================================
Write-Host "[5/6] Exécution des tests unitaires..." -ForegroundColor Yellow

$testResult = flutter test 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Tests passés" -ForegroundColor Green
} else {
    $warnings += "Certains tests ont échoué"
    Write-Host "  ⚠ Certains tests ont échoué" -ForegroundColor DarkYellow
}

Write-Host ""

# ====================================
# 6. Test de compilation Web
# ====================================
Write-Host "[6/6] Test de compilation Web..." -ForegroundColor Yellow

$buildResult = flutter build web --dart-define=DEMO_MODE=true 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Build Web réussi" -ForegroundColor Green
    
    # Taille du build
    $buildSize = (Get-ChildItem -Path "build/web" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "  ℹ Taille du build: $([math]::Round($buildSize, 2)) MB" -ForegroundColor Cyan
} else {
    $errors += "Erreur de compilation Web"
    Write-Host "  ✗ Build Web échoué" -ForegroundColor Red
}

Write-Host ""

# ====================================
# Résumé
# ====================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RÉSUMÉ DES TESTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "✓ TOUS LES TESTS PASSÉS !" -ForegroundColor Green
    Write-Host ""
    Write-Host "Vous pouvez maintenant lancer l'application:" -ForegroundColor White
    Write-Host "  Mode démo:    flutter run -d chrome --dart-define=DEMO_MODE=true" -ForegroundColor Cyan
    Write-Host "  Production:   .\run_dev.ps1" -ForegroundColor Cyan
} elseif ($errors.Count -eq 0) {
    Write-Host "⚠ TESTS PASSÉS AVEC AVERTISSEMENTS" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "Avertissements:" -ForegroundColor DarkYellow
    foreach ($warning in $warnings) {
        Write-Host "  - $warning" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "✗ TESTS ÉCHOUÉS" -ForegroundColor Red
    Write-Host ""
    Write-Host "Erreurs:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    if ($warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "Avertissements:" -ForegroundColor DarkYellow
        foreach ($warning in $warnings) {
            Write-Host "  - $warning" -ForegroundColor DarkYellow
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

# Return exit code
if ($errors.Count -gt 0) {
    exit 1
} else {
    exit 0
}
