# -*- coding: utf-8 -*-
"""ทดสอบเว็บไซต์ในเครื่อง: ไฟล์หลัก, ทุก route (.md), PDF, โปสเตอร์, และลิงก์ภายในทุกหน้า

วิธีใช้:
  1) เปิดเซิร์ฟเวอร์ในโฟลเดอร์ docs/:   python -m http.server 8910
  2) รันสคริปต์นี้:                       python tools/test_site.py [PORT]
     (PORT ไม่ระบุ = 8910)
"""
import glob, os, re, sys, urllib.parse, urllib.request, urllib.error
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

PORT = sys.argv[1] if len(sys.argv) > 1 else "8910"
BASE = "http://localhost:" + PORT
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = os.path.join(ROOT, "docs", "content")
results = []


def check(path, expect_ctype=None, min_len=1):
    url = BASE + "/" + urllib.parse.quote(path)
    try:
        with urllib.request.urlopen(url, timeout=20) as r:
            body = r.read()
            ct = r.headers.get("Content-Type", "")
            ok = (r.status == 200) and (len(body) >= min_len)
            if expect_ctype and expect_ctype not in ct:
                ok = False
            return ok, r.status, len(body), ct
    except urllib.error.HTTPError as e:
        return False, e.code, 0, ""
    except Exception as e:
        return False, "ERR:" + type(e).__name__, 0, ""


def row(label, ok, status, size):
    results.append(("PASS" if ok else "FAIL", label, status, size))


# 1) ไฟล์หลัก ( .nojekyll เป็นไฟล์ว่างโดยตั้งใจ จึง min_len=0 )
core = [("index.html", "text/html", 1), ("assets/js/app.js", "javascript", 1),
        ("assets/js/marked.min.js", "javascript", 1), ("assets/css/style.css", "css", 1),
        ("webapp/index.html", "text/html", 1), (".nojekyll", None, 0)]
for f, ct, ml in core:
    ok, st, sz, _ = check(f, ct, ml)
    row("core: " + f, ok, st, sz)

# 2) หน้าเนื้อหา (.md ตามชื่อไฟล์จริง)
md_files = sorted(os.path.basename(p) for p in glob.glob(os.path.join(CONTENT, "*.md")))
for name in md_files:
    ok, st, sz, _ = check("content/" + name, None, 50)
    row("route: content/" + name, ok, st, sz)

# 3) PDF และโปสเตอร์
for p in sorted(glob.glob(os.path.join(ROOT, "docs", "downloads", "*.pdf"))):
    ok, st, sz, _ = check("downloads/" + os.path.basename(p), "pdf", 1000)
    row("pdf: " + os.path.basename(p), ok, st, sz)
for p in sorted(glob.glob(os.path.join(ROOT, "docs", "downloads", "posters", "*.png"))):
    ok, st, sz, _ = check("downloads/posters/" + os.path.basename(p), "png", 1000)
    row("poster: " + os.path.basename(p), ok, st, sz)

# 4) ลิงก์ภายในทุกไฟล์ .md -> ตรวจว่าไฟล์ปลายทางมีจริง
broken = []
md_set = set(md_files)
for p in glob.glob(os.path.join(CONTENT, "*.md")):
    txt = open(p, encoding="utf-8").read()
    for m in re.finditer(r"\]\(([^)]+)\)", txt):
        href = m.group(1).strip()
        if href.startswith(("http", "#", "mailto")):
            continue
        target = href.split("#")[0]
        if not target:
            continue
        if target.endswith(".md"):
            exists = os.path.basename(target) in md_set or os.path.exists(os.path.join(CONTENT, target))
        else:
            exists = os.path.exists(os.path.join(CONTENT, target)) or os.path.exists(os.path.join(ROOT, "docs", target))
        if not exists:
            broken.append((os.path.basename(p), href))

print("==== SITE TEST RESULTS ====")
for mark, label, st, sz in results:
    print(f"[{mark}] {label}  (HTTP {st}, {sz} bytes)")
passc = sum(1 for r in results if r[0] == "PASS")
failc = sum(1 for r in results if r[0] == "FAIL")
print(f"\nPASS={passc} FAIL={failc}")
print("\n==== BROKEN INTERNAL LINKS ====")
print("  none" if not broken else "\n".join(f"  in {s}: {h}" for s, h in broken))
sys.exit(0 if failc == 0 and not broken else 1)
