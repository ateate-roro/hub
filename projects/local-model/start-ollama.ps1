# start-ollama.ps1
# Checks if Ollama is running; if not, starts it.
# Run this before each conversation/session to ensure local inference is available.

$ollamaExe = "C:\Users\19198\AppData\Local\Programs\Ollama\ollama.exe"
$ollamaUrl = "http://localhost:11434/api/tags"
$timeoutSec = 5

function Test-OllamaRunning {
    try {
        $response = Invoke-RestMethod -Uri $ollamaUrl -Method GET -TimeoutSec $timeoutSec -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Start-Ollama {
    Write-Host "Ollama not running. Starting Ollama..." -ForegroundColor Yellow
    Start-Process -FilePath $ollamaExe -ArgumentList "serve" -WindowStyle Hidden
    # Wait for Ollama to become available
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 2
        if (Test-OllamaRunning) {
            Write-Host "Ollama is now running." -ForegroundColor Green
            return $true
        }
    }
    Write-Host "WARNING: Ollama did not start within 60 seconds." -ForegroundColor Red
    return $false
}

# Main
if (Test-OllamaRunning) {
    Write-Host "Ollama is already running." -ForegroundColor Green
} else {
    Start-Ollama
}
