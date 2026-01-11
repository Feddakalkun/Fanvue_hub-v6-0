# ============================================================================
# VoxCPM Voice Pack Installer
# Downloads curated voice samples for TTS
# ============================================================================

$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
$RootPath = Split-Path -Parent $ScriptPath
$VoicesDir = Join-Path $RootPath "VoxCPM\voxcpm-plus\voices"

Write-Host "============================================================================"
Write-Host "  VoxCPM Voice Pack Installer"
Write-Host "============================================================================"
Write-Host ""

# Create voices directory if it doesn't exist
if (-not (Test-Path $VoicesDir)) {
    New-Item -ItemType Directory -Path $VoicesDir -Force | Out-Null
}

# Voice Pack URLs (Open Speech Repository - Public Domain)
$VoicePacks = @(
    @{
        Name        = "Emma"
        URL         = "https://www.voiptroubleshooter.com/open_speech/american/OSR_us_000_0010_8k.wav"
        Transcript  = "She had your dark suit in greasy wash water all year."
        Description = "Young American Female - Clear, professional"
    },
    @{
        Name        = "Sarah"
        URL         = "https://www.voiptroubleshooter.com/open_speech/american/OSR_us_000_0011_8k.wav"
        Transcript  = "Don't ask me to carry an oily rag like that."
        Description = "Mature American Female - Warm, friendly"
    },
    @{
        Name        = "Alex"
        URL         = "https://www.voiptroubleshooter.com/open_speech/american/OSR_us_000_0012_8k.wav"
        Transcript  = "The young prince became king heir."
        Description = "Young American Male - Energetic, clear"
    },
    @{
        Name        = "James"
        URL         = "https://www.voiptroubleshooter.com/open_speech/american/OSR_us_000_0013_8k.wav"
        Transcript  = "The lake sparkled in the red hot sun."
        Description = "Deep American Male - Authoritative, smooth"
    },
    @{
        Name        = "Lily"
        URL         = "https://www.voiptroubleshooter.com/open_speech/american/OSR_us_000_0014_8k.wav"
        Transcript  = "Bring your best compass to the third class."
        Description = "Professional Female - Elegant, articulate"
    },
    @{
        Name        = "Sophie"
        URL         = "https://www.voiptroubleshooter.com/open_speech/american/OSR_us_000_0015_8k.wav"
        Transcript  = "They took their kids from the public school."
        Description = "Soft Female - Gentle, expressive"
    },
    @{
        Name        = "Lucas"
        URL         = "https://www.voiptroubleshooter.com/open_speech/american/OSR_us_000_0016_8k.wav"
        Transcript  = "The latch on the back gate needed a nail."
        Description = "Professional Male - Clear, confident"
    },
    @{
        Name        = "Aria"
        URL         = "https://www.voiptroubleshooter.com/open_speech/american/OSR_us_000_0017_8k.wav"
        Transcript  = "March the tired soldiers into the compound."
        Description = "Melodic Female - Expressive, warm"
    },
    @{
        Name        = "Default"
        URL         = "https://github.com/gradio-app/gradio/raw/main/test/test_files/audio_sample.wav"
        Transcript  = "Hello, this is a test audio sample."
        Description = "Generic English - Neutral baseline"
    }
)

Write-Host "Downloading $($VoicePacks.Count) voice samples..."
Write-Host ""

$Downloaded = 0
$Failed = 0

foreach ($voice in $VoicePacks) {
    $voiceName = $voice.Name
    $voiceDir = Join-Path $VoicesDir $voiceName
    
    # Create voice directory
    if (-not (Test-Path $voiceDir)) {
        New-Item -ItemType Directory -Path $voiceDir -Force | Out-Null
    }
    
    # Determine file extension
    $ext = if ($voice.URL -match '\.mp3$') { ".mp3" } else { ".wav" }
    $audioFile = Join-Path $voiceDir "voice$ext"
    $txtFile = Join-Path $voiceDir "voice.txt"
    $infoFile = Join-Path $voiceDir "info.txt"
    
    # Skip if already downloaded
    if (Test-Path $audioFile) {
        Write-Host "[SKIP] $voiceName - already exists" -ForegroundColor Yellow
        continue
    }
    
    try {
        Write-Host "[DOWN] $voiceName - $($voice.Description)" -ForegroundColor Cyan
        
        # Download audio file with retry logic
        $maxRetries = 3
        $retryCount = 0
        $success = $false
        
        while (-not $success -and $retryCount -lt $maxRetries) {
            try {
                Invoke-WebRequest -Uri $voice.URL -OutFile $audioFile -UseBasicParsing -TimeoutSec 30
                $success = $true
            }
            catch {
                $retryCount++
                if ($retryCount -lt $maxRetries) {
                    Write-Host "  Retry $retryCount/$maxRetries..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                }
                else {
                    throw
                }
            }
        }
        
        # Save transcript
        Set-Content -Path $txtFile -Value $voice.Transcript -Encoding UTF8
        
        # Save info
        Set-Content -Path $infoFile -Value "Voice: $voiceName`nDescription: $($voice.Description)`nSource: $($voice.URL)" -Encoding UTF8
        
        Write-Host "[OK]   $voiceName downloaded successfully" -ForegroundColor Green
        $Downloaded++
    }
    catch {
        Write-Host "[FAIL] $voiceName - $($_.Exception.Message)" -ForegroundColor Red
        $Failed++
        
        # Clean up partial download
        if (Test-Path $audioFile) {
            Remove-Item $audioFile -Force
        }
    }
}

Write-Host ""
Write-Host "============================================================================"
Write-Host "  Voice Pack Installation Complete"
Write-Host "============================================================================"
Write-Host "Downloaded: $Downloaded voices"
Write-Host "Failed: $Failed voices"
Write-Host "Total Available: $((Get-ChildItem $VoicesDir -Directory -ErrorAction SilentlyContinue | Measure-Object).Count) voices"
Write-Host ""
Write-Host "Voices installed in: $VoicesDir"
Write-Host ""

if ($Failed -gt 0 -and $Downloaded -eq 0) {
    Write-Host "[WARNING] All downloads failed. Check your internet connection." -ForegroundColor Red
    Write-Host "You can retry by running download-voices.bat again." -ForegroundColor Yellow
}
