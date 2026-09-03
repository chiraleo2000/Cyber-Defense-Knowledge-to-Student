# -*- coding: utf-8 -*-
"""
สร้างไฟล์ PDF ภาษาไทยจากไฟล์ Markdown ในโฟลเดอร์ docs/content/
- ใช้ Chrome/Edge headless (--print-to-pdf) ซึ่งรองรับภาษาไทยได้ดี (เอนจิน Skia/PDF เดียวกับ PDF เดิม)
- ฝังฟอนต์ Sarabun (self-hosted, woff2) เป็น base64 ใน HTML ชั่วคราว เพื่อให้ render ไทยได้แม้ไม่มีฟอนต์ในเครื่อง
- ชื่อไฟล์ PDF เป็นภาษาไทยตามตาราง SLUGS ด้านล่าง (ตรงกับชื่อไฟล์ .md)

วิธีใช้:
    python tools/build_pdfs.py            # สร้าง PDF ทุกหน้า
    python tools/build_pdfs.py <ชื่อไฟล์.md>   # สร้างเฉพาะไฟล์เดียว
"""
import base64
import os
import re
import subprocess
import sys
import tempfile

import markdown

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = os.path.join(ROOT, "docs", "content")
DOWNLOADS = os.path.join(ROOT, "docs", "downloads")
FONTS = os.path.join(ROOT, "docs", "assets", "fonts")

# ไฟล์ .md ในระบบเป็นชื่อไทยอยู่แล้ว — PDF ใช้ชื่อเดียวกัน (เปลี่ยนแค่นามสกุล)
# สคริปต์นี้จึงอ่านทุกไฟล์ .md ในโฟลเดอร์ content แล้วสร้าง PDF ชื่อเดียวกัน

CHROME_CANDIDATES = [
    os.path.join(os.environ.get("ProgramFiles", r"C:\Program Files"),
                 "Google", "Chrome", "Application", "chrome.exe"),
    os.path.join(os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)"),
                 "Google", "Chrome", "Application", "chrome.exe"),
    os.path.join(os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)"),
                 "Microsoft", "Edge", "Application", "msedge.exe"),
    os.path.join(os.environ.get("ProgramFiles", r"C:\Program Files"),
                 "Microsoft", "Edge", "Application", "msedge.exe"),
]


def find_browser():
    for p in CHROME_CANDIDATES:
        if os.path.exists(p):
            return p
    raise RuntimeError("ไม่พบ Chrome หรือ Edge สำหรับสร้าง PDF")


def font_face(family, weight, thai_file, latin_file):
    def b64(fn):
        with open(os.path.join(FONTS, fn), "rb") as f:
            return base64.b64encode(f.read()).decode("ascii")
    return (
        "@font-face{{font-family:'{fam}';font-style:normal;font-weight:{w};"
        "src:url(data:font/woff2;base64,{thai}) format('woff2');"
        "unicode-range:U+0E01-0E5B,U+200C-200D,U+25CC;}}"
        "@font-face{{font-family:'{fam}';font-style:normal;font-weight:{w};"
        "src:url(data:font/woff2;base64,{latin}) format('woff2');}}"
    ).format(fam=family, w=weight, thai=b64(thai_file), latin=b64(latin_file))


def build_css():
    faces = (
        font_face("Sarabun", 400, "sarabun-thai-400-normal.woff2", "sarabun-latin-400-normal.woff2")
        + font_face("Sarabun", 600, "sarabun-thai-600-normal.woff2", "sarabun-latin-600-normal.woff2")
        + font_face("Sarabun", 700, "sarabun-thai-700-normal.woff2", "sarabun-latin-700-normal.woff2")
    )
    return faces + """
    @page { size: A4; margin: 18mm 16mm; }
    * { box-sizing: border-box; }
    body { font-family:'Sarabun',sans-serif; color:#171F35; line-height:1.65;
           font-size:12.5pt; margin:0; }
    h1 { font-weight:700; font-size:21pt; color:#0E4744; margin:0 0 6pt;
         border-bottom:3px solid #0E7C7B; padding-bottom:6pt; }
    h2 { font-weight:700; font-size:15.5pt; color:#0E4744; margin:16pt 0 6pt; }
    h3 { font-weight:600; font-size:13pt; color:#065352; margin:12pt 0 4pt; }
    p, li { font-size:12.5pt; }
    a { color:#065352; text-decoration:none; }
    blockquote { border-left:4px solid #C97A2B; background:#FBF1E1; margin:10pt 0;
                 padding:8pt 12pt; color:#8F551C; }
    table { border-collapse:collapse; width:100%; margin:10pt 0; font-size:11pt; }
    th, td { border:1px solid #DDE3EE; padding:6pt 8pt; text-align:left;
             vertical-align:top; }
    th { background:#EAF0F7; font-weight:600; }
    tr:nth-child(even) td { background:#F7F9FC; }
    code { font-family:'JetBrains Mono',monospace; background:#EAF0F7; padding:1px 4px;
           border-radius:3px; font-size:10.5pt; }
    hr { border:none; border-top:1px solid #DDE3EE; margin:14pt 0; }
    .foot { margin-top:18pt; padding-top:8pt; border-top:1px solid #DDE3EE;
            color:#8992A6; font-size:10pt; }
    """


def strip_front_matter(text):
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.S)
    meta = {}
    if m:
        for line in m.group(1).splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                meta[k.strip()] = v.strip()
        text = text[m.end():]
    return meta, text


def md_to_pdf(md_path, css, browser):
    with open(md_path, "r", encoding="utf-8") as f:
        raw = f.read()
    meta, body = strip_front_matter(raw)
    title = meta.get("title") or os.path.splitext(os.path.basename(md_path))[0]
    html_body = markdown.markdown(body, extensions=["tables", "fenced_code", "sane_lists"])
    doc = (
        "<!doctype html><html lang='th'><head><meta charset='utf-8'>"
        "<title>{t}</title><style>{css}</style></head><body>{b}"
        "<div class='foot'>เอกสารนี้สร้างจากเว็บไซต์ \"เช็คก่อนโอน\" — "
        "ศูนย์ข้อมูลภัยหลอกลวงไซเบอร์สำหรับนักศึกษา · เผยแพร่แบบ open source</div>"
        "</body></html>"
    ).format(t=title, css=css, b=html_body)

    base = os.path.splitext(os.path.basename(md_path))[0]
    out_pdf = os.path.join(DOWNLOADS, base + ".pdf")

    tmp = tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8")
    tmp.write(doc)
    tmp.close()
    tmp_url = "file:///" + tmp.name.replace("\\", "/")
    try:
        subprocess.run(
            [browser, "--headless", "--disable-gpu", "--no-pdf-header-footer",
             "--print-to-pdf=" + out_pdf, "--print-to-pdf-no-header", tmp_url],
            check=True, timeout=90,
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
    finally:
        os.unlink(tmp.name)
    return out_pdf


def main():
    os.makedirs(DOWNLOADS, exist_ok=True)
    browser = find_browser()
    css = build_css()
    if len(sys.argv) > 1:
        targets = [os.path.join(CONTENT, sys.argv[1])]
    else:
        targets = [os.path.join(CONTENT, f) for f in os.listdir(CONTENT) if f.endswith(".md")]
    for md in sorted(targets):
        out = md_to_pdf(md, css, browser)
        size = os.path.getsize(out) if os.path.exists(out) else 0
        print("OK", os.path.basename(out), size, "bytes")


if __name__ == "__main__":
    main()
