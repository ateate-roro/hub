# start-ollama.ps1
# Ensures Ollama is running bound to 0.0.0.0:11434 so it is reachable from WSL.
# If Ollama is already running but bound to 127.0.0.1 only, kills and restarts
# with the correct binding.
# Auto-started two ways, so a fresh boot is always correct:
#   1. Windows logon: Startup\Ollama.lnk -> this script (stock tray disabled).
#   2. WSL boot hook: /etc/wsl.conf [boot] command -> wsl-ollama-bootfix.sh
#      invokes this script if Ollama is not reachable from WSL.
# Safe to run manually at any time (idempotent).

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

function Test-OllamaBoundAllInterfaces {
    # True when the listener is a wildcard reachable from WSL: 0.0.0.0 (IPv4
    # all-interfaces) or "::" (Ollama 0.40+ dual-stack wildcard, which also
    # serves IPv4). A 127.0.0.1-only listener means the fix failed.
    $listeners = Get-NetTCPConnection -LocalPort 11434 -State Listen -ErrorAction SilentlyContinue
    return [bool]($listeners | Where-Object { $_.LocalAddress -in @("0.0.0.0", "::") })
}

function Stop-Ollama {
    Write-Host "Stopping existing Ollama..." -ForegroundColor Yellow
    # ollama* catches the server ("ollama"), the tray ("ollama app") and any
    # renamed helper, so nothing can respawn a 127.0.0.1-only server.
    Get-Process -Name "ollama*" -ErrorAction SilentlyContinue | Stop-Process -Force
    # Wait until port 11434 is actually released (up to 15s) so the restart
    # cannot race a still-dying process and silently keep the old binding.
    for ($i = 0; $i -lt 15; $i++) {
        $listener = Get-NetTCPConnection -LocalPort 11434 -State Listen -ErrorAction SilentlyContinue
        if (-not $listener) { break }
        Start-Sleep -Seconds 1
    }
    Start-Sleep -Seconds 1
}

function Start-Ollama {
    Write-Host "Starting Ollama bound to 0.0.0.0:11434..." -ForegroundColor Yellow
    Start-Process -FilePath $ollamaExe -ArgumentList "serve" -WindowStyle Hidden
    # Wait until the API answers AND the listener is on 0.0.0.0 (API-only
    # checks can be fooled by a leftover 127.0.0.1 listener).
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 2
        if ((Test-OllamaRunning) -and (Test-OllamaBoundAllInterfaces)) {
            Write-Host "Ollama is now running on 0.0.0.0:11434." -ForegroundColor Green
            return $true
        }
    }
    Write-Host "WARNING: Ollama did not start within 60 seconds (or is not bound to 0.0.0.0)." -ForegroundColor Red
    return $false
}

function Warm-Up-Models {
    # Warm up preferred models into GPU memory so OpenCode doesn't hit
    # ECONNRESET on first use (large models take time to load).
    $models = @("qwen3-coder:30b", "devstral:24b")
    Write-Host "Warming up local models into GPU memory..." -ForegroundColor Yellow
    $jobs = foreach ($model in $models) {
        Start-Job -ScriptBlock {
            param($m)
            try {
                $response = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/generate" -Method POST -ContentType "application/json" -Body "{\"model\":\"$m\",\"prompt\":\"hi\",\"stream\":false}" -TimeoutSec 120 -ErrorAction Stop
                Write-Host "Warmed up $m" -ForegroundColor Green
            } catch {
                Write-Host "Failed to warm up ${m}: $($_.Exception.Message)" -ForegroundColor Red
            }
        } -ArgumentList $model
    }
    # Wait for all warm-up jobs to complete, surface their output, then clean
    # up. (The previous version referenced an unassigned $jobs variable, so
    # Wait-Job always failed and the script never actually waited.)
    if ($jobs) {
        $jobs | Wait-Job -Timeout 120 | Out-Null
        $jobs | Receive-Job
        $jobs | Remove-Job -Force -ErrorAction SilentlyContinue
    }
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
