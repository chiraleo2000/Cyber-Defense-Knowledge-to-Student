#Requires -Version 5.1
# ทดสอบว่า worker ตอบ /health และ /chat ได้
# ใช้: powershell -File .\test-chat.ps1 -WorkerUrl https://check-kon-oon-agent-proxy.<subdomain>.workers.dev
param(
  [Parameter(Mandatory = $true)]
  [string]$WorkerUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$base = $WorkerUrl.TrimEnd("/")
if ($base -match "/chat$") { $base = $base -replace "/chat$", "" }

Write-Host "==> GET $base/health"
$health = Invoke-RestMethod -Uri "$base/health" -Method GET
$health | ConvertTo-Json -Compress
if (-not $health.ok) { throw "health check failed" }
if (-not $health.configured) {
  Write-Host "worker ยังไม่ได้ตั้ง UPSTREAM_API_KEY / UPSTREAM_BASE_URL"
  exit 2
}

$chatUrl = "$base/chat"
$body = @{ messages = @(@{ role = "user"; content = "สวัสดีครับ ทดสอบระบบ ตอบสั้นๆ ได้ไหม" }) } | ConvertTo-Json
Write-Host "==> POST $chatUrl"
try {
  $res = Invoke-RestMethod -Uri $chatUrl -Method POST -ContentType "application/json; charset=utf-8" -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
  $res | ConvertTo-Json -Depth 5
  if (-not $res.reply) { throw "no reply field" }
  Write-Host "OK — worker เชื่อม Pathumma ได้"
} catch {
  Write-Host "ล้มเหลว: $_"
  if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message }
  exit 1
}
