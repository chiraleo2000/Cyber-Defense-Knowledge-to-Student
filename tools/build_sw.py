# -*- coding: utf-8 -*-
"""สร้างรายการไฟล์แคช (PRECACHE) และเลขเวอร์ชันใน docs/sw.js ให้ตรงกับไฟล์จริงในโฟลเดอร์ docs/

ใช้ทุกครั้งที่เพิ่ม/ลบ/แก้ไฟล์เนื้อหา (.md), CSS, JS, ไอคอน หรือเว็บแอป ก่อน commit:
    python tools/build_sw.py

เวอร์ชันแคช = แฮชของเนื้อหาไฟล์ทั้งหมดที่แคช เมื่อมีไฟล์ใดเปลี่ยน เบราว์เซอร์จะติดตั้ง service worker ตัวใหม่
และล้างแคชเก่าให้อัตโนมัติ (ผู้ใช้ไม่ต้องล้างแคชเอง)
"""
import hashlib
import os
import re
import sys
import urllib.parse

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(ROOT, "docs")
SW = os.path.join(DOCS, "sw.js")

STATIC = [
    "./", "index.html", "manifest.webmanifest",
    "assets/css/style.css", "assets/js/app.js", "assets/js/marked.min.js",
    "icons/icon-192.png", "icons/icon-512.png", "icons/apple-touch-icon.png",
    "webapp/", "webapp/index.html",
]


def collect():
    items = list(STATIC)
    for sub in ("assets/fonts",):
        for name in sorted(os.listdir(os.path.join(DOCS, sub))):
            items.append(sub + "/" + name)
    for name in sorted(os.listdir(os.path.join(DOCS, "content"))):
        if name.endswith(".md"):
            items.append("content/" + name)
    return items


def file_for(item):
    if item == "./":
        return os.path.join(DOCS, "index.html")
    if item.endswith("/"):
        return os.path.join(DOCS, item, "index.html")
    return os.path.join(DOCS, item)


def main():
    items = collect()
    h = hashlib.sha256()
    for it in items:
        p = file_for(it)
        if not os.path.exists(p):
            sys.exit("ไม่พบไฟล์ที่ต้องแคช: " + it)
        h.update(it.encode("utf-8"))
        with open(p, "rb") as f:
            h.update(f.read())
    version = "cko-" + h.hexdigest()[:10]
    # URL ภาษาไทยแปลงเป็น %XX เพื่อให้ตรงกับคำขอจริงของเบราว์เซอร์
    quoted = [urllib.parse.quote(it, safe="/.-_~") if it != "./" else "./" for it in items]
    block = "// BEGIN-GENERATED\nconst VERSION = \"%s\";\nconst PRECACHE = [\n%s\n];\n// END-GENERATED" % (
        version, ",\n".join('  "%s"' % q for q in quoted))
    with open(SW, "r", encoding="utf-8") as f:
        src = f.read()
    new, n = re.subn(r"// BEGIN-GENERATED.*?// END-GENERATED", lambda m: block, src, flags=re.S)
    if n != 1:
        sys.exit("ไม่พบเครื่องหมาย BEGIN-GENERATED/END-GENERATED ใน sw.js")
    with open(SW, "w", encoding="utf-8", newline="\n") as f:
        f.write(new)
    print("OK sw.js version=%s files=%d" % (version, len(items)))


if __name__ == "__main__":
    main()
