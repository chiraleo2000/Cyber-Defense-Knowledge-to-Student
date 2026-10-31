/* เช็คก่อนโอน — service worker
   เป้าหมาย: เปิดหน้าเนื้อหาและเว็บแอปได้แม้สัญญาณมือถือไม่ดี/ออฟไลน์
   - PRECACHE ถูกสร้างอัตโนมัติด้วย  python tools/build_sw.py  (อย่าแก้ระหว่าง BEGIN/END ด้วยมือ)
   - ไฟล์ของเว็บเอง: network-first (รอเครือข่ายไม่เกิน 4 วินาที) แล้วถอยไปใช้แคช เพื่อให้ได้เนื้อหาใหม่เสมอเมื่อออนไลน์
   - ฟอนต์/ไอคอน: cache-first
   - ไม่แตะคำขอข้ามโดเมน (Google Fonts, jsDelivr, Worker ของผู้ช่วย AI) และไม่แคชไฟล์ใน downloads/ (PDF/โปสเตอร์ ขนาดใหญ่)
*/
// BEGIN-GENERATED
const VERSION = "cko-2e8c56a9e9";
const PRECACHE = [
  "./",
  "index.html",
  "manifest.webmanifest",
  "assets/css/style.css",
  "assets/js/app.js",
  "assets/js/marked.min.js",
  "icons/icon-192.png",
  "icons/icon-512.png",
  "icons/apple-touch-icon.png",
  "webapp/",
  "webapp/index.html",
  "assets/fonts/sarabun-latin-400-normal.woff2",
  "assets/fonts/sarabun-latin-600-normal.woff2",
  "assets/fonts/sarabun-latin-700-normal.woff2",
  "assets/fonts/sarabun-thai-400-normal.woff2",
  "assets/fonts/sarabun-thai-600-normal.woff2",
  "assets/fonts/sarabun-thai-700-normal.woff2",
  "content/%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B8%A7%E0%B8%B4%E0%B9%80%E0%B8%84%E0%B8%A3%E0%B8%B2%E0%B8%B0%E0%B8%AB%E0%B9%8C%E0%B8%AA%E0%B8%96%E0%B8%B2%E0%B8%99%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B8%93%E0%B9%8C.md",
  "content/%E0%B8%82%E0%B9%88%E0%B8%B2%E0%B8%A7%E0%B8%A5%E0%B9%88%E0%B8%B2%E0%B8%AA%E0%B8%B8%E0%B8%94%E0%B9%81%E0%B8%A5%E0%B8%B0%E0%B8%9A%E0%B8%97%E0%B8%A7%E0%B8%B4%E0%B9%80%E0%B8%84%E0%B8%A3%E0%B8%B2%E0%B8%B0%E0%B8%AB%E0%B9%8C.md",
  "content/%E0%B8%82%E0%B9%89%E0%B8%AD%E0%B9%80%E0%B8%AA%E0%B8%99%E0%B8%AD%E0%B9%81%E0%B8%99%E0%B8%B0%E0%B9%80%E0%B8%8A%E0%B8%B4%E0%B8%87%E0%B8%99%E0%B9%82%E0%B8%A2%E0%B8%9A%E0%B8%B2%E0%B8%A2.md",
  "content/%E0%B8%84%E0%B8%94%E0%B8%B5%E0%B8%88%E0%B8%A3%E0%B8%B4%E0%B8%87%E0%B9%83%E0%B8%99%E0%B9%84%E0%B8%97%E0%B8%A2.md",
  "content/%E0%B8%84%E0%B8%B9%E0%B9%88%E0%B8%A1%E0%B8%B7%E0%B8%AD%E0%B8%A3%E0%B8%B1%E0%B8%9A%E0%B8%A1%E0%B8%B7%E0%B8%AD.md",
  "content/%E0%B8%94%E0%B8%B2%E0%B8%A7%E0%B8%99%E0%B9%8C%E0%B9%82%E0%B8%AB%E0%B8%A5%E0%B8%94.md",
  "content/%E0%B8%96%E0%B8%B9%E0%B8%81%E0%B8%AB%E0%B8%A5%E0%B8%AD%E0%B8%81%E0%B9%81%E0%B8%A5%E0%B9%89%E0%B8%A7%E0%B8%97%E0%B8%B3%E0%B8%AD%E0%B8%A2%E0%B9%88%E0%B8%B2%E0%B8%87%E0%B9%84%E0%B8%A3.md",
  "content/%E0%B8%A1%E0%B8%B8%E0%B8%A1%E0%B8%A1%E0%B8%AD%E0%B8%87%E0%B8%A3%E0%B8%B0%E0%B8%94%E0%B8%B1%E0%B8%9A%E0%B9%82%E0%B8%A5%E0%B8%81.md",
  "content/%E0%B8%A3%E0%B8%B9%E0%B9%89%E0%B8%97%E0%B8%B1%E0%B8%99%E0%B8%AA%E0%B8%84%E0%B8%A3%E0%B8%B4%E0%B8%9B%E0%B8%95%E0%B9%8C%E0%B8%A1%E0%B8%B4%E0%B8%88%E0%B8%89%E0%B8%B2%E0%B8%8A%E0%B8%B5%E0%B8%9E.md",
  "content/%E0%B8%AB%E0%B8%99%E0%B9%89%E0%B8%B2%E0%B9%81%E0%B8%A3%E0%B8%81.md",
  "content/%E0%B9%81%E0%B8%9A%E0%B8%9A%E0%B8%AA%E0%B8%B3%E0%B8%A3%E0%B8%A7%E0%B8%88%E0%B8%84%E0%B8%A7%E0%B8%B2%E0%B8%A1%E0%B8%95%E0%B8%A3%E0%B8%B0%E0%B8%AB%E0%B8%99%E0%B8%B1%E0%B8%81%E0%B8%A3%E0%B8%B9%E0%B9%89.md",
  "content/%E0%B9%81%E0%B8%9C%E0%B8%99%E0%B8%9E%E0%B8%B1%E0%B8%92%E0%B8%99%E0%B8%B2%E0%B8%95%E0%B9%88%E0%B8%AD.md",
  "content/%E0%B9%81%E0%B8%AB%E0%B8%A5%E0%B9%88%E0%B8%87%E0%B8%97%E0%B8%B5%E0%B9%88%E0%B8%A1%E0%B8%B2%E0%B8%82%E0%B8%AD%E0%B8%87%E0%B8%AA%E0%B8%B7%E0%B9%88%E0%B8%AD.md",
  "content/%E0%B9%83%E0%B8%8A%E0%B9%89%E0%B8%9A%E0%B8%99%E0%B8%A1%E0%B8%B7%E0%B8%AD%E0%B8%96%E0%B8%B7%E0%B8%AD.md"
];
// END-GENERATED

const NETWORK_TIMEOUT_MS = 4000;

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(VERSION).then((cache) =>
      // add ทีละไฟล์: ไฟล์ใดไฟล์หนึ่งโหลดไม่ได้ ไม่ทำให้ติดตั้งล้มทั้งชุด
      Promise.all(PRECACHE.map((url) => cache.add(new Request(url, { cache: "reload" })).catch(() => null)))
    ).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k.indexOf("cko-") === 0 && k !== VERSION).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

function isStaticAsset(url) {
  return /\/assets\/fonts\/|\/icons\//.test(url.pathname);
}

function networkWithTimeout(request) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error("timeout")), NETWORK_TIMEOUT_MS);
    fetch(request).then((res) => { clearTimeout(timer); resolve(res); }, (err) => { clearTimeout(timer); reject(err); });
  });
}

self.addEventListener("fetch", (event) => {
  const req = event.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;
  if (url.pathname.indexOf("/downloads/") !== -1) return;

  if (isStaticAsset(url)) {
    event.respondWith(
      caches.match(req, { ignoreSearch: true }).then((hit) => hit || fetch(req).then((res) => {
        const copy = res.clone();
        caches.open(VERSION).then((c) => c.put(req, copy));
        return res;
      }))
    );
    return;
  }

  event.respondWith(
    networkWithTimeout(req)
      .then((res) => {
        if (res && res.ok) {
          const copy = res.clone();
          caches.open(VERSION).then((c) => c.put(req, copy));
        }
        return res;
      })
      .catch(() =>
        caches.match(req, { ignoreSearch: true }).then((hit) => {
          if (hit) return hit;
          if (req.mode === "navigate") {
            // ออฟไลน์และยังไม่เคยเปิดหน้านี้: เปิดหน้าแรกของส่วนที่กำลังเข้า (เว็บแอป หรือเว็บข้อมูล)
            const inWebapp = url.pathname.indexOf("/webapp/") !== -1;
            return caches.match(inWebapp ? "webapp/index.html" : "index.html", { ignoreSearch: true });
          }
          return new Response("", { status: 504, statusText: "offline" });
        })
      )
  );
});
