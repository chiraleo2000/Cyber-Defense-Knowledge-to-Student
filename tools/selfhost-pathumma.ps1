#Requires -Version 5.1
# Self-host Pathumma ด้วย vLLM แล้วเปิด HTTPS สาธารณะผ่าน Cloudflare Tunnel
# เพื่อให้ Cloudflare Worker เรียกได้ (Worker เรียก localhost ของเครื่องคุณไม่ได้)
#
# ต้องมี: Docker Desktop + GPU NVIDIA (แนะนำ VRAM 16GB ขึ้นไป) + cloudflared
# ติดตั้ง cloudflared:  winget install Cloudflare.cloudflared
#
# ใช้:
#   powershell -File .\tools\selfhost-pathumma.ps1
#   powershell -File .\tools\selfhost-pathumma.ps1 -Tunnel
param(
  [string]$Model = "nectec/Pathumma-llm-text-1.0.0",
  [int]$Port = 8000,
  [switch]$Tunnel
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host "ยังไม่มี Docker — ติดตั้ง Docker Desktop แล้วเปิดใช้งาน GPU/WSL2 ก่อน"
  Write-Host "  winget install Docker.DockerDesktop"
  exit 1
}

Write-Host "==> เริ่ม vLLM (OpenAI-compatible) ที่พอร์ต $Port โมเดล $Model"
Write-Host "    ครั้งแรกจะดาวน์โหลดโมเดลจาก Hugging Face อาจใช้เวลาและพื้นที่ดิสก์มาก"
Write-Host ""

$dockerArgs = @(
  "run", "--rm", "--gpus", "all",
  "-p", "${Port}:8000",
  "vllm/vllm-openai:latest",
  "--model", $Model,
  "--served-model-name", $Model,
  "--max-model-len", "4096"
)

if ($Tunnel) {
  if (-not (Get-Command cloudflared -ErrorAction SilentlyContinue)) {
    Write-Host "ยังไม่มี cloudflared — ติดตั้งแล้วรันใหม่:"
    Write-Host "  winget install Cloudflare.cloudflared"
    exit 1
  }
  Write-Host "==> เปิด Cloudflare Tunnel ไปที่ http://127.0.0.1:$Port"
  Write-Host "    คัดลอก URL https://....trycloudflare.com แล้วตั้ง worker:"
  Write-Host "      UPSTREAM_BASE_URL = https://<tunnel-host>/v1"
  Write-Host "      MODEL_NAME        = $Model   (ใน worker/wrangler.toml)"
  Write-Host ""
  $vllm = Start-Process -FilePath "docker" -ArgumentList $dockerArgs -PassThru -NoNewWindow
  try {
    Start-Sleep -Seconds 8
    & cloudflared tunnel --url "http://127.0.0.1:$Port"
  } finally {
    if (-not $vllm.HasExited) { Stop-Process -Id $vllm.Id -Force -ErrorAction SilentlyContinue }
  }
} else {
  Write-Host "ทดสอบในเครื่อง:  curl http://127.0.0.1:$Port/v1/models"
  Write-Host "เมื่อพร้อมให้ Worker เรียกได้ ให้รันสคริปต์นี้อีกครั้งด้วย -Tunnel"
  Write-Host "หรือมีเซิร์ฟเวอร์สาธารณะอยู่แล้ว ตั้ง UPSTREAM_BASE_URL = https://<host>/v1"
  Write-Host ""
  & docker @dockerArgs
}
