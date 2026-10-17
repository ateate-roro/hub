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

function Warm-Up-Models {
    # Warm up preferred models into GPU memory so OpenCode doesn't hit
    # ECONNRESET on first use (large models take time to load).
    $models = @("qwen3-coder:30b", "devstral:24b")
    Write-Host "Warming up local models into GPU memory..." -ForegroundColor Yellow
    foreach ($model in $models) {
        $job = Start-Job -ScriptBlock {
            param($m)
            try {
                $response = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/generate" -Method POST -ContentType "application/json" -Body "{\"model\":\"$m\",\"prompt\":\"hi\",\"stream\":false}" -TimeoutSec 120 -ErrorAction Stop
                Write-Host "Warmed up $m" -ForegroundColor Green
            } catch {
                Write-Host "Failed to warm up $m: $($_.Exception.Message)" -ForegroundColor Red
            }
        } -ArgumentList $model
        $job
    }
    # Wait for all warm-up jobs to complete
    $jobs | Wait-Job -Timeout 120
    Write-Host "Model warm-up complete." -ForegroundColor Green
}

# Main
if (Test-OllamaRunning) {
    # Ollama responds on localhost, but may be bound to 127.0.0.1 only
    # (not reachable from WSL). Restart to ensure 0.0.0.0 binding.
    Write-Host "Ollama already running - restarting with 0.0.0.0 binding for WSL access" -ForegroundColor Yellow
    Stop-Ollama
    Start-Ollama
    Warm-Up-Models
} else {
    Start-Ollama
    Warm-Up-Models
}
