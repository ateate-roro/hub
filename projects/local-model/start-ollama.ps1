# start-ollama.ps1
# Ensures Ollama is running bound to 0.0.0.0:11434 so it is reachable from WSL.
# If Ollama is already running but bound to 127.0.0.1 only, kills and restarts
# with the correct binding. Run this before each conversation/session.

# Bind Ollama to all interfaces so WSL (and other LAN clients) can reach it.
$env:OLLAMA_HOST = "0.0.0.0:11434"

$ollamaExe = "C:\Users\19198\AppData\Local\Programs\Ollama\ollama.exe"
$ollamaUrl = "http://127.0.0.1:11434/api/tags"
$timeoutSec = 5

function Test-OllamaRunning {
    try {
        $response = Invoke-RestMethod -Uri $ollamaUrl -Method GET -TimeoutSec $timeoutSec -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Stop-Ollama {
    Write-Host "Stopping existing Ollama..." -ForegroundColor Yellow
    Get-Process ollama -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 3
}

function Start-Ollama {
    Write-Host "Starting Ollama bound to 0.0.0.0:11434..." -ForegroundColor Yellow
    Start-Process -FilePath $ollamaExe -ArgumentList "serve" -WindowStyle Hidden
    # Wait for Ollama to become available
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 2
        if (Test-OllamaRunning) {
            Write-Host "Ollama is now running on 0.0.0.0:11434." -ForegroundColor Green
            return $true
        }
    }
    Write-Host "WARNING: Ollama did not start within 60 seconds." -ForegroundColor Red
    return $false
}

# Main
if (Test-OllamaRunning) {
    # Ollama responds on localhost, but may be bound to 127.0.0.1 only
    # (not reachable from WSL). Restart to ensure 0.0.0.0 binding.
    Write-Host "Ollama already running - restarting with 0.0.0.0 binding for WSL access" -ForegroundColor Yellow
    Stop-Ollama
    Start-Ollama
} else {
    Start-Ollama
}
