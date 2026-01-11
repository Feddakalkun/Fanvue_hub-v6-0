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

# Voice Pack URLs (Curated from open sources)
# Format: Name, URL, Description
$VoicePacks = @(
    @{
        Name        = "Emma"
        URL         = "https://huggingface.co/datasets/Matthijs/cmu-arctic-xvectors/resolve/main/cmu_us_slt_arctic/wav/arctic_a0001.wav"
        Transcript  = "Author of the danger trail, Philip Steels, etc."
        Description = "Young American Female - Clear, professional"
    },
    @{
        Name        = "Sarah"
        URL         = "https://huggingface.co/datasets/Matthijs/cmu-arctic-xvectors/resolve/main/cmu_us_clb_arctic/wav/arctic_a0001.wav"
        Transcript  = "Author of the danger trail, Philip Steels, etc."
        Description = "Mature American Female - Warm, friendly"
    },
    @{
        Name        = "Alex"
        URL         = "https://huggingface.co/datasets/Matthijs/cmu-arctic-xvectors/resolve/main/cmu_us_bdl_arctic/wav/arctic_a0001.wav"
        Transcript  = "Author of the danger trail, Philip Steels, etc."
        Description = "Young American Male - Energetic, clear"
    },
    @{
        Name        = "James"
        URL         = "https://huggingface.co/datasets/Matthijs/cmu-arctic-xvectors/resolve/main/cmu_us_rms_arctic/wav/arctic_a0001.wav"
        Transcript  = "Author of the danger trail, Philip Steels, etc."
        Description = "Deep American Male - Authoritative, smooth"
    },
    @{
        Name        = "Lily"
        URL         = "https://huggingface.co/datasets/Matthijs/cmu-arctic-xvectors/resolve/main/cmu_us_fem_arctic/wav/arctic_a0001.wav"
        Transcript  = "Author of the danger trail, Philip Steels, etc."
        Description = "British Female - Elegant, articulate"
    },
    @{
        Name        = "Sophie"
        URL         = "https://huggingface.co/datasets/anton-l/common_voice_12_0-fr/resolve/main/audio/test/00/common_voice_fr_19917699.mp3"
        Transcript  = "Bonjour, comment allez-vous?"
        Description = "French Female - Soft, romantic"
    },
    @{
        Name        = "Lucas"
        URL         = "https://huggingface.co/datasets/mozilla-foundation/common_voice_11_0/resolve/main/audio/de/test/common_voice_de_19897199.mp3"
        Transcript  = "Guten Tag, wie geht es Ihnen?"
        Description = "German Male - Professional, clear"
    },
    @{
        Name        = "Aria"
        URL         = "https://huggingface.co/datasets/mozilla-foundation/common_voice_11_0/resolve/main/audio/it/test/common_voice_it_19878923.mp3"
        Transcript  = "Ciao bella, come stai?"
        Description = "Italian Female - Expressive, melodic"
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
        
        # Download audio file
        Invoke-WebRequest -Uri $voice.URL -OutFile $audioFile -UseBasicParsing
        
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
    }
}

Write-Host ""
Write-Host "============================================================================"
Write-Host "  Voice Pack Installation Complete"
Write-Host "============================================================================"
Write-Host "Downloaded: $Downloaded voices"
Write-Host "Failed: $Failed voices"
Write-Host "Total Available: $($Downloaded + (Get-ChildItem $VoicesDir -Directory | Measure-Object).Count) voices"
Write-Host ""
Write-Host "Voices installed in: $VoicesDir"
Write-Host ""
