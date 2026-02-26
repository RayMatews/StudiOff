# ===============================
# Continue + Claude Auto Setup
# ===============================

$CLAUDE_KEY = "TA_CLE"

$continuePath = "$env:USERPROFILE\.continue"
$configFile = "$continuePath\config.json"

if (!(Test-Path $continuePath)) {
    New-Item -ItemType Directory -Path $continuePath | Out-Null
}

$config = @"
{
  "models": [
    {
      "title": "Claude",
      "provider": "anthropic",
      "model": "claude-3-5-sonnet-latest",
      "apiKey": "$CLAUDE_KEY"
    }
  ],
  "defaultModel": "Claude",

  "contextProviders": [
    { "name": "code" },
    { "name": "docs" },
    { "name": "diff" },
    { "name": "terminal" }
  ]
}
"@

$config | Out-File -Encoding utf8 $configFile

Write-Host "Claude configured."

code .

