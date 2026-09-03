#Requires -Version 5.1
# Deploy Agent Proxy ขึ้น Cloudflare Workers (Windows)
# ใช้: คลิกขวา → Run with PowerShell หรือในโฟลเดอร์ worker/:  powershell -File .\deploy.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Need-Node {
  if (Get-Command npm -ErrorAction SilentlyContinue) { return }
  Write-Host ""
  Write-Host "ยังไม่มี Node.js บนเครื่องนี้ ติดตั้งแล้วปิด-เปิดเทอร์มินัล แล้วรันสคริปต์นี้อีกครั้ง:"
  Write-Host "  winget install OpenJS.NodeJS.LTS"
  Write-Host ""
  exit 1
}

Need-Node

Write-Host "==> เข้าสู่ระบบ Cloudflare (จะเปิดเบราว์เซอร์ให้กดอนุญาต)"
npx --yes wrangler@4 login

Write-Host ""
Write-Host "==> ตั้ง API key ของ ThaiLLM Playground (thaillm.or.th)"
Write-Host "    วางคีย์แล้วกด Enter — ค่านี้ไม่ถูกบันทึกลงไฟล์ในเครื่อง/repo"
npx --yes wrangler@4 secret put UPSTREAM_API_KEY

Write-Host ""
Write-Host "==> ตั้ง UPSTREAM_BASE_URL (ThaiLLM: http://thaillm.or.th/api/v1 — ไม่ต้องมี /chat/completions)"
npx --yes wrangler@4 secret put UPSTREAM_BASE_URL

Write-Host ""
Write-Host "==> Deploy worker"
npx --yes wrangler@4 deploy

Write-Host ""
Write-Host "เมื่อได้ URL เช่น https://check-kon-oon-agent-proxy.<subdomain>.workers.dev"
Write-Host "ให้เปิดเว็บแอปครั้งเดียวด้วยพารามิเตอร์ (เบราว์เซอร์จะจำ URL ไว้เอง):"
Write-Host "  https://chiraleo2000.github.io/Cyber-Defense-Knowledge-to-Student/webapp/?agent=https://<worker>.workers.dev/chat"
Write-Host ""
Write-Host "ทดสอบด้วย:  powershell -File .\test-chat.ps1 -WorkerUrl https://<worker>.workers.dev"
