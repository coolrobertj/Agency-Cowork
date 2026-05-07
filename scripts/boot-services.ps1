# boot-services.ps1 -- Start all Agency Cowork background services
# Designed to run at Windows logon via Task Scheduler (headless, no window).
# Idempotent: skips services that are already running.

$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)  # agency-cowork root

# Prefer pwsh (PS 7+) over powershell.exe (PS 5.1) for broader syntax compatibility
$PwshExe = "powershell.exe"
if (Get-Command pwsh -ErrorAction SilentlyContinue) { $PwshExe = "pwsh.exe" }

# Log to file so output isn't lost in headless execution
$logDir = "$Root\logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
Start-Transcript -Path "$logDir\boot-services.log" -Append -Force | Out-Null

function Write-Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] $msg"
}

# ---------- 1. Task Scheduler Daemon ----------
$schedulerPid = "$Root\skills\task-scheduler\scheduler.pid"
$schedulerRunning = $false

if (Test-Path $schedulerPid) {
    $savedPid = (Get-Content $schedulerPid -ErrorAction SilentlyContinue).Trim()
    if ($savedPid -and (Get-Process -Id $savedPid -ErrorAction SilentlyContinue)) {
        Write-Log "Task Scheduler already running (PID $savedPid) -- skipping"
        $schedulerRunning = $true
    } else {
        Write-Log "Stale scheduler PID file -- removing"
        Remove-Item $schedulerPid -Force
    }
}

if (-not $schedulerRunning) {
    Write-Log "Starting Task Scheduler daemon..."
    $si = New-Object System.Diagnostics.ProcessStartInfo
    $si.FileName = $PwshExe
    $si.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Root\skills\task-scheduler\scripts\scheduler-service.ps1`""
    $si.CreateNoWindow = $true
    $si.UseShellExecute = $false
    $si.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $proc = [System.Diagnostics.Process]::Start($si)
    Start-Sleep -Seconds 3
    if (Test-Path $schedulerPid) {
        Write-Log "Task Scheduler confirmed running (PID $(Get-Content $schedulerPid))"
    } else {
        Write-Log "WARNING: Task Scheduler may have failed to start (no PID file after 3s)"
    }
}

# ---------- 2. Teams Trouter Monitor ----------
$monitorPid = "$Root\skills\teams\monitor\monitor.pid"
$monitorRunning = $false

if (Test-Path $monitorPid) {
    $savedPid = (Get-Content $monitorPid -ErrorAction SilentlyContinue).Trim()
    if ($savedPid -and (Get-Process -Id $savedPid -ErrorAction SilentlyContinue)) {
        Write-Log "Teams Monitor already running (PID $savedPid) -- skipping"
        $monitorRunning = $true
    } else {
        Write-Log "Stale monitor PID file -- removing"
        Remove-Item $monitorPid -Force
    }
}

if (-not $monitorRunning) {
    Write-Log "Starting Teams Trouter Monitor..."
    $si = New-Object System.Diagnostics.ProcessStartInfo
    $si.FileName = "python"
    $si.Arguments = "-m scripts.monitor.service start"
    $si.WorkingDirectory = "$Root\skills\teams"
    $si.CreateNoWindow = $true
    $si.UseShellExecute = $false
    $si.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $proc = [System.Diagnostics.Process]::Start($si)
    Start-Sleep -Seconds 3
    if (Test-Path $monitorPid) {
        Write-Log "Teams Monitor confirmed running (PID $(Get-Content $monitorPid))"
    } else {
        Write-Log "WARNING: Teams Monitor may have failed to start (no PID file after 3s)"
    }
}

Write-Log "Boot complete."
Stop-Transcript | Out-Null
