# StudiOff - Supabase Setup Script
# Run this after creating your Supabase project

Write-Host "=== StudiOff Supabase Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "[!] Created .env from .env.example" -ForegroundColor Yellow
        Write-Host "    Please edit .env with your actual values before continuing." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press Enter after you've updated .env..." -ForegroundColor White
        Read-Host
    } else {
        Write-Host "[ERROR] No .env.example found!" -ForegroundColor Red
        exit 1
    }
}

# Load .env file
Get-Content .env | ForEach-Object {
    if ($_ -match "^\s*([^#][^=]+)=(.*)$") {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

$SUPABASE_URL = $env:SUPABASE_URL
$SUPABASE_ANON_KEY = $env:SUPABASE_ANON_KEY

if ([string]::IsNullOrEmpty($SUPABASE_URL) -or $SUPABASE_URL -like "*your-project*") {
    Write-Host "[ERROR] SUPABASE_URL not configured in .env" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Environment loaded" -ForegroundColor Green
Write-Host "     URL: $SUPABASE_URL" -ForegroundColor Gray
Write-Host ""

# Check if Supabase CLI is installed
$supabaseCli = Get-Command supabase -ErrorAction SilentlyContinue
if (-not $supabaseCli) {
    Write-Host "[!] Supabase CLI not found. Installing..." -ForegroundColor Yellow
    Write-Host ""
    
    # Try to install via npm (most common)
    $npm = Get-Command npm -ErrorAction SilentlyContinue
    if ($npm) {
        npm install -g supabase
    } else {
        Write-Host "[ERROR] npm not found. Please install Supabase CLI manually:" -ForegroundColor Red
        Write-Host "        https://supabase.com/docs/guides/cli" -ForegroundColor Gray
        exit 1
    }
}

Write-Host "[OK] Supabase CLI available" -ForegroundColor Green
Write-Host ""

# Link to remote project
Write-Host "=== Linking to Supabase Project ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "You'll need your Project Reference ID from:" -ForegroundColor White
Write-Host "  Supabase Dashboard > Settings > General > Reference ID" -ForegroundColor Gray
Write-Host ""

$projectRef = Read-Host "Enter your Project Reference ID"
if ([string]::IsNullOrEmpty($projectRef)) {
    Write-Host "[ERROR] Project Reference ID required" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Linking project..." -ForegroundColor White
supabase link --project-ref $projectRef

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to link project" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Project linked" -ForegroundColor Green
Write-Host ""

# Push database migrations
Write-Host "=== Deploying Database Schema ===" -ForegroundColor Cyan
Write-Host ""
supabase db push

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to push database migrations" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Database schema deployed" -ForegroundColor Green
Write-Host ""

# Deploy Edge Functions
Write-Host "=== Deploying Edge Functions ===" -ForegroundColor Cyan
Write-Host ""

$functions = @("generate-audio", "create-checkout-session", "create-portal-session", "stripe-webhook")
foreach ($func in $functions) {
    Write-Host "  Deploying $func..." -ForegroundColor White
    supabase functions deploy $func --no-verify-jwt
}

Write-Host "[OK] Edge Functions deployed" -ForegroundColor Green
Write-Host ""

# Set secrets
Write-Host "=== Setting Edge Function Secrets ===" -ForegroundColor Cyan
Write-Host ""

$stripeSecret = $env:STRIPE_SECRET_KEY
$stripeWebhook = $env:STRIPE_WEBHOOK_SECRET
$elevenLabsKey = $env:ELEVENLABS_API_KEY

if (-not [string]::IsNullOrEmpty($stripeSecret) -and $stripeSecret -notlike "*your-*") {
    supabase secrets set STRIPE_SECRET_KEY=$stripeSecret
    Write-Host "  [OK] STRIPE_SECRET_KEY set" -ForegroundColor Green
}

if (-not [string]::IsNullOrEmpty($stripeWebhook) -and $stripeWebhook -notlike "*your-*") {
    supabase secrets set STRIPE_WEBHOOK_SECRET=$stripeWebhook
    Write-Host "  [OK] STRIPE_WEBHOOK_SECRET set" -ForegroundColor Green
}

if (-not [string]::IsNullOrEmpty($elevenLabsKey) -and $elevenLabsKey -notlike "*your-*") {
    supabase secrets set ELEVENLABS_API_KEY=$elevenLabsKey
    Write-Host "  [OK] ELEVENLABS_API_KEY set" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Run the app with real backend:" -ForegroundColor Gray
Write-Host "     .\run_dev.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Configure Stripe products (if not done):" -ForegroundColor Gray
Write-Host "     - Create 'Starter' product at `$59 CAD/month" -ForegroundColor Gray
Write-Host "     - Create 'Pro' product at `$179 CAD/month" -ForegroundColor Gray
Write-Host ""
