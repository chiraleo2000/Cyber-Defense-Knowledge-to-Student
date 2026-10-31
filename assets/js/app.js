/* เช็คก่อนโอน — client-side markdown site renderer
   ไม่มี build step: โหลดไฟล์ .md จาก content/ ตรงๆ แล้ว render ด้วย marked.js (self-hosted)
   Routing: #/<slug> โดย slug เป็นชื่อไฟล์ไทย เช่น #/คดีจริงในไทย -> โหลด content/คดีจริงในไทย.md (encode อัตโนมัติ)
   ลิงก์ภายในหน้า (#หัวข้อ) ไม่เปลี่ยนเส้นทาง: เลื่อนไปยังหัวข้อนั้นเท่านั้น

   ส่วนเสริมสำหรับมือถือ (ต.ค. 2569): สารบัญย่อ, ตารางแบบการ์ด, ปุ่มแชร์, drawer มี backdrop,
   วันที่อัปเดต, ลงทะเบียน service worker (ใช้ออฟไลน์/ติดตั้งลงหน้าจอโฮม)
*/
(function () {
  "use strict";

  // slug = ชื่อไฟล์ .md ภาษาไทย (ไม่รวมนามสกุล) — router จะ encode ให้เองตอน fetch
  var PAGES = [
    { slug: "หน้าแรก", label: "หน้าแรก", group: "เริ่มต้น", keywords: "home เริ่มต้น สัญญาณอันตราย" },
    { slug: "ข่าวล่าสุดและบทวิเคราะห์", label: "ข่าวล่าสุดและบทวิเคราะห์ (ต.ค. 2569)", group: "เริ่มต้น",
      keywords: "ข่าว ล่าสุด วิเคราะห์ แนวโน้ม อัปเดต ตุลาคม 2569 ACSC IC3 FTC GASA กัมพูชา AI เสียงปลอม ธนาคาร ม้า เงินสด" },
    { slug: "ถูกหลอกแล้วทำอย่างไร", label: "ถูกหลอกแล้วทำอย่างไร + หลัก 4 ไม่", group: "เริ่มต้น",
      keywords: "ถูกหลอก รับมือ แจ้งความ อายัดบัญชี 1441 4 ไม่ ไม่กดลิงก์ ไม่เชื่อ ไม่รีบ ไม่โอน 72 ชั่วโมง ป้องกัน" },
    { slug: "รู้ทันสคริปต์มิจฉาชีพ", label: "รู้ทันสคริปต์มิจฉาชีพ + ดึงสติก่อนโอน", group: "เริ่มต้น",
      keywords: "สคริปต์ กลลวง แพทเทิร์น ดึงสติ ตกใจ ข่มขู่ อันตราย amygdala ธงแดง หายใจ วางสาย telegram ห้องสอบสวน รหัสไลน์ ค่าไถ่ เปลี่ยนเบอร์" },
    { slug: "ใช้บนมือถือ", label: "ใช้บนมือถือ / ติดตั้งลงหน้าจอ", group: "เริ่มต้น",
      keywords: "มือถือ mobile ติดตั้ง แอป หน้าจอโฮม iphone android ออฟไลน์ pwa qr โทร 1441 191 การ์ดฉุกเฉิน" },
    { slug: "คดีจริงในไทย", label: "สถิติและคดีจริง (ไทย)", group: "ข้อมูลและสถิติ",
      keywords: "ในประเทศ ไทย ACSC AOC สถิติ คดีจริง แก๊งคอลเซ็นเตอร์ ไทม์ไลน์ ปทุมวัน พญาไท รังสิต สะพานสูง telegram ค่าไถ่ ตุลาคม 2569" },
    { slug: "มุมมองระดับโลก", label: "มุมมองระดับโลก", group: "ข้อมูลและสถิติ",
      keywords: "ต่างประเทศ สากล โลก FBI IC3 FTC GASA UNODC กัมพูชา virtual kidnapping romance scam AI" },
    { slug: "การวิเคราะห์สถานการณ์", label: "การวิเคราะห์สถานการณ์", group: "ข้อมูลและสถิติ",
      keywords: "วิเคราะห์ กลโกง 5 ระยะ KPI ตัวชี้วัด แผนดำเนินงาน" },
    { slug: "คู่มือรับมือ", label: "คู่มือรับมือฉบับเต็ม", group: "คู่มือและแนวทาง",
      keywords: "คู่มือ รับมือ 3 เสาหลัก ตรวจจับ วิดีโอคอล romance scam ลงทุน" },
    { slug: "ข้อเสนอแนะเชิงนโยบาย", label: "ข้อเสนอแนะเชิงนโยบาย", group: "คู่มือและแนวทาง",
      keywords: "นโยบาย ข้อเสนอแนะ มหาวิทยาลัย สถาบันการเงิน ครอบครัว หน่วยงาน" },
    { slug: "แหล่งที่มาของสื่อ", label: "แหล่งที่มาของสื่อ", group: "คู่มือและแนวทาง",
      keywords: "แหล่งข่าว อ้างอิง สำนักข่าว ตรวจสอบข่าว หน่วยงาน" },
    { slug: "แบบสำรวจความตระหนักรู้", label: "แบบสำรวจความตระหนักรู้", group: "คู่มือและแนวทาง",
      keywords: "แบบสอบถาม สำรวจ วิจัย ตระหนักรู้" },
    { slug: "แผนพัฒนาต่อ", label: "แผนพัฒนาต่อ (Roadmap)", group: "คู่มือและแนวทาง",
      keywords: "roadmap แผนพัฒนา อนาคต ฟีเจอร์ แอปเตือนสาย streaming ผู้พิทักษ์สาย สิ่งที่มีตอนนี้ ต่อยอด" },
    { slug: "ดาวน์โหลด", label: "ดาวน์โหลดโปสเตอร์/เอกสาร", group: "ดาวน์โหลด",
      keywords: "โปสเตอร์ PDF facebook instagram แคปชั่น ดาวน์โหลด" }
  ];

  var DEFAULT_SLUG = "หน้าแรก";
  var THAI_MONTHS = ["ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.", "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."];

  var contentEl = document.getElementById("doc-content");
  var navEl = document.getElementById("side-nav");
  var searchEl = document.getElementById("search-box");
  var sidebarEl = document.getElementById("sidebar");
  var menuBtn = document.getElementById("menu-btn");
  var themeBtn = document.getElementById("theme-btn");
  var backdropEl = document.getElementById("backdrop");
  var toastEl = document.getElementById("toast");

  var cache = {}; // slug -> {html, title, updated}
  var currentRendered = null; // slug ที่แสดงอยู่ตอนนี้ (กัน render ซ้ำเมื่อกดลิงก์ภายในหน้า)

  function buildNav(filterText) {
    var groups = {};
    var order = [];
    var q = filterText ? filterText.toLowerCase() : "";
    PAGES.forEach(function (p) {
      if (q) {
        var haystack = (p.label + " " + (p.keywords || "")).toLowerCase();
        if (haystack.indexOf(q) === -1) return;
      }
      if (!groups[p.group]) { groups[p.group] = []; order.push(p.group); }
      groups[p.group].push(p);
    });
    var html = "";
    order.forEach(function (g) {
      html += '<div class="group-label">' + g + "</div>";
      groups[g].forEach(function (p) {
        html += '<a href="#/' + encodeURIComponent(p.slug) + '" data-slug="' + p.slug + '">' + p.label + "</a>";
      });
    });
    navEl.innerHTML = html || '<p style="padding:0 10px;color:var(--ink-soft);font-size:0.85rem;">ไม่พบผลลัพธ์</p>';
    highlightActive();
  }

  function highlightActive() {
    var current = currentSlug();
    var links = navEl.querySelectorAll("a[data-slug]");
    for (var i = 0; i < links.length; i++) {
      links[i].classList.toggle("active", links[i].getAttribute("data-slug") === current);
    }
  }

  // hash แบบ "#/slug" = เส้นทางหน้า ; hash แบบ "#หัวข้อ" (ไม่มี /) = ลิงก์ภายในหน้า
  function isRouteHash(h) { return h.indexOf("#/") === 0; }

  function currentSlug() {
    var raw = window.location.hash;
    if (!raw || raw === "#" || !isRouteHash(raw)) return currentRendered || DEFAULT_SLUG;
    var h = raw.replace(/^#\/?/, "");
    try { h = decodeURIComponent(h); } catch (e) {}
    return h || DEFAULT_SLUG;
  }

  // --- minimal front-matter stripper (YAML between leading --- ... ---) ---
  function stripFrontMatter(raw) {
    var m = raw.match(/^---\s*[\r\n]+([\s\S]*?)[\r\n]+---\s*[\r\n]+/);
    var meta = {};
    if (m) {
      m[1].split(/\r?\n/).forEach(function (line) {
        var idx = line.indexOf(":");
        if (idx > -1) meta[line.slice(0, idx).trim()] = line.slice(idx + 1).trim();
      });
      raw = raw.slice(m[0].length);
    }
    return { meta: meta, body: raw };
  }

  // "2569-10-30" -> "30 ต.ค. 2569"
  function formatThaiDate(s) {
    var m = /^(\d{4})-(\d{1,2})-(\d{1,2})$/.exec(s || "");
    if (!m) return "";
    var mo = parseInt(m[2], 10);
    if (mo < 1 || mo > 12) return "";
    return parseInt(m[3], 10) + " " + THAI_MONTHS[mo - 1] + " " + m[1];
  }

  function slugifyHeading(text) {
    return text.trim().toLowerCase()
      .replace(/[^\p{L}\p{M}\p{N}\s-]/gu, "")
      .replace(/\s+/g, "-");
  }

  function wrapTables(html) {
    // wrap <table> in a scrollable container so wide tables never overflow the page,
    // และใส่ class "stack" + data-label ให้เซลล์ เพื่อให้ CSS แสดงเป็นการ์ดบนจอแคบ
    // และ rewrite internal "xxx.md" links to hash routes so the SPA router handles them
    // instead of the browser trying to navigate to a raw markdown file.
    var div = document.createElement("div");
    div.innerHTML = html;
    var tables = div.querySelectorAll("table");
    for (var i = 0; i < tables.length; i++) {
      var table = tables[i];
      var labels = [];
      var ths = table.querySelectorAll("thead th");
      for (var k = 0; k < ths.length; k++) labels.push(ths[k].textContent.trim());
      if (labels.length) {
        table.classList.add("stack");
        var rows = table.querySelectorAll("tbody tr");
        for (var r = 0; r < rows.length; r++) {
          var cells = rows[r].children;
          for (var c = 0; c < cells.length; c++) cells[c].setAttribute("data-label", labels[c] || "");
        }
      }
      var wrap = document.createElement("div");
      wrap.className = "table-wrap";
      table.parentNode.insertBefore(wrap, table);
      wrap.appendChild(table);
    }
    var links = div.querySelectorAll("a[href$='.md']");
    for (var j = 0; j < links.length; j++) {
      var href = links[j].getAttribute("href");
      // ลิงก์ในไฟล์ .md อาจถูก encode มาแล้วหรือเป็นไทยดิบ — decode ก่อนแล้วค่อย encode ใหม่ให้สม่ำเสมอ
      var slug = href.replace(/\.md$/, "");
      try { slug = decodeURIComponent(slug); } catch (e) {}
      links[j].setAttribute("href", "#/" + encodeURIComponent(slug));
    }
    return div.innerHTML;
  }

  function render(slug) {
    if (cache[slug]) {
      paint(slug, cache[slug]);
      return;
    }
    contentEl.innerHTML = '<p style="color:var(--ink-soft)">กำลังโหลด…</p>';
    fetch("content/" + encodeURIComponent(slug) + ".md", { cache: "no-cache" })
      .then(function (r) {
        if (!r.ok) throw new Error("not found");
        return r.text();
      })
      .then(function (raw) {
        var parsed = stripFrontMatter(raw);
        var html = wrapTables(marked.parse(parsed.body));
        var titleMatch = parsed.body.match(/^#\s+(.+)$/m);
        var title = (parsed.meta && parsed.meta.title) || (titleMatch ? titleMatch[1] : slug);
        cache[slug] = { html: html, title: title, updated: formatThaiDate(parsed.meta && parsed.meta.updated) };
        paint(slug, cache[slug]);
      })
      .catch(function () {
        contentEl.innerHTML =
          '<div class="doc"><h1>ไม่พบหน้านี้</h1><p>ไม่พบเนื้อหาที่ต้องการ (หากออฟไลน์ ให้เปิดหน้านี้ตอนมีสัญญาณหนึ่งครั้งก่อน) กรุณาเลือกหัวข้อจากเมนู หรือโทร <a href="tel:1441">1441</a> หากกำลังถูกหลอกอยู่</p></div>';
      });
  }

  function ensureHeadingIds(article) {
    var hs = article.querySelectorAll("h2, h3");
    var used = {};
    for (var i = 0; i < hs.length; i++) {
      var id = hs[i].id || slugifyHeading(hs[i].textContent);
      if (!id) continue;
      var base = id, n = 2;
      while (used[id]) { id = base + "-" + n; n++; }
      used[id] = true;
      hs[i].id = id;
    }
  }

  function buildToc(article) {
    var h2s = article.querySelectorAll("h2[id]");
    if (h2s.length < 4) return;
    var details = document.createElement("details");
    details.className = "toc";
    var summary = document.createElement("summary");
    summary.textContent = "ไปหัวข้อ (" + h2s.length + ")";
    details.appendChild(summary);
    var ol = document.createElement("ol");
    for (var i = 0; i < h2s.length; i++) {
      var li = document.createElement("li");
      var a = document.createElement("a");
      a.href = "#" + h2s[i].id;
      a.setAttribute("data-go", h2s[i].id);
      a.textContent = h2s[i].textContent;
      li.appendChild(a);
      ol.appendChild(li);
    }
    details.appendChild(ol);
    var h1 = article.querySelector("h1");
    var anchor = article.querySelector(".meta") || h1;
    if (anchor && anchor.nextSibling) anchor.parentNode.insertBefore(details, anchor.nextSibling);
    else article.insertBefore(details, article.firstChild);
  }

  function buildActions(article, entry) {
    var box = document.createElement("div");
    box.className = "doc-actions";
    var share = document.createElement("button");
    share.type = "button";
    share.className = "primary";
    share.textContent = "แชร์หน้านี้";
    share.addEventListener("click", function () { sharePage(entry.title); });
    var top = document.createElement("button");
    top.type = "button";
    top.textContent = "↑ กลับขึ้นบน";
    top.addEventListener("click", function () { window.scrollTo({ top: 0, behavior: "smooth" }); });
    var call = document.createElement("a");
    call.href = "tel:1441";
    call.textContent = "📞 โทร 1441";
    box.appendChild(share);
    box.appendChild(top);
    box.appendChild(call);
    article.appendChild(box);
  }

  function showToast(msg) {
    if (!toastEl) return;
    toastEl.textContent = msg;
    toastEl.hidden = false;
    clearTimeout(showToast._t);
    showToast._t = setTimeout(function () { toastEl.hidden = true; }, 2600);
  }

  function sharePage(title) {
    var url = window.location.href;
    if (navigator.share) {
      navigator.share({ title: title + " — เช็คก่อนโอน", text: "เช็คก่อนโอน: " + title, url: url }).catch(function () {});
      return;
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url).then(function () { showToast("คัดลอกลิงก์แล้ว"); }, function () { showToast(url); });
    } else {
      showToast(url);
    }
  }

  function paint(slug, entry) {
    currentRendered = slug;
    contentEl.innerHTML = '<article class="doc">' + entry.html + "</article>";
    var article = contentEl.firstChild;
    if (entry.updated) {
      var h1 = article.querySelector("h1");
      if (h1) {
        var meta = document.createElement("p");
        meta.className = "meta";
        meta.textContent = "อัปเดตล่าสุด " + entry.updated;
        h1.parentNode.insertBefore(meta, h1.nextSibling);
      }
    }
    ensureHeadingIds(article);
    buildToc(article);
    buildActions(article, entry);
    document.title = entry.title + " — เช็คก่อนโอน";
    window.scrollTo(0, 0);
    highlightActive();
    closeDrawer();
  }

  // --- drawer (เมนูบนมือถือ) ---
  function openDrawer() {
    sidebarEl.classList.add("open");
    if (backdropEl) backdropEl.hidden = false;
    document.body.classList.add("drawer-open");
    menuBtn.setAttribute("aria-expanded", "true");
  }
  function closeDrawer() {
    sidebarEl.classList.remove("open");
    if (backdropEl) backdropEl.hidden = true;
    document.body.classList.remove("drawer-open");
    menuBtn.setAttribute("aria-expanded", "false");
  }

  window.addEventListener("hashchange", function () {
    var h = window.location.hash;
    if (h && !isRouteHash(h)) return; // ลิงก์ภายในหน้า: จัดการโดย click handler ไม่ render ใหม่
    var slug = currentSlug();
    if (slug === currentRendered && cache[slug]) { highlightActive(); return; }
    render(slug);
  });

  // ลิงก์ภายในหน้า (#หัวข้อ) และสารบัญ: เลื่อนไปยังหัวข้อ โดยไม่แตะ hash ของ router
  contentEl.addEventListener("click", function (e) {
    var a = e.target.closest ? e.target.closest("a") : null;
    if (!a) return;
    var href = a.getAttribute("href") || "";
    if (href.charAt(0) !== "#" || isRouteHash(href) || href === "#") return;
    e.preventDefault();
    var id = a.getAttribute("data-go") || href.slice(1);
    try { id = decodeURIComponent(id); } catch (err) {}
    var target = document.getElementById(id);
    if (target) {
      target.scrollIntoView({ behavior: "smooth", block: "start" });
      var toc = contentEl.querySelector(".toc");
      if (toc && toc.contains(a)) toc.removeAttribute("open");
    }
  });

  searchEl.addEventListener("input", function (e) {
    buildNav(e.target.value.trim());
  });

  menuBtn.addEventListener("click", function () {
    if (sidebarEl.classList.contains("open")) closeDrawer(); else openDrawer();
  });
  if (backdropEl) backdropEl.addEventListener("click", closeDrawer);
  document.addEventListener("keydown", function (e) { if (e.key === "Escape") closeDrawer(); });
  // หมุนจอ/ขยายเป็นจอใหญ่ ให้ปิด drawer ค้าง
  window.addEventListener("resize", function () { if (window.innerWidth > 860) closeDrawer(); });

  // --- theme toggle: cycles system -> light -> dark -> system ---
  function applyStoredTheme() {
    var t = null;
    try { t = localStorage.getItem("cko-theme"); } catch (e) {}
    if (t === "light" || t === "dark") {
      document.documentElement.setAttribute("data-theme", t);
    } else {
      document.documentElement.removeAttribute("data-theme");
    }
    updateThemeBtn();
  }
  function updateThemeBtn() {
    var t = document.documentElement.getAttribute("data-theme");
    var long = t === "dark" ? "☀︎ โหมดสว่าง" : t === "light" ? "☾ โหมดมืด" : "◐ ธีมอัตโนมัติ";
    // จอแคบแสดงเฉพาะสัญลักษณ์ ส่วนข้อความเต็มอยู่ใน aria-label/title
    themeBtn.textContent = window.innerWidth <= 860 ? long.charAt(0) : long;
    themeBtn.setAttribute("aria-label", long.slice(2).trim() || "สลับธีม");
    themeBtn.title = long;
  }
  themeBtn.addEventListener("click", function () {
    var t = document.documentElement.getAttribute("data-theme");
    var next = t === "dark" ? "light" : t === "light" ? null : "dark";
    if (next) document.documentElement.setAttribute("data-theme", next);
    else document.documentElement.removeAttribute("data-theme");
    try {
      if (next) localStorage.setItem("cko-theme", next);
      else localStorage.removeItem("cko-theme");
    } catch (e) {}
    updateThemeBtn();
  });
  window.addEventListener("resize", updateThemeBtn);

  // --- service worker: ใช้ออฟไลน์ + ติดตั้งลงหน้าจอโฮม (ต้องเป็น https หรือ localhost) ---
  function registerServiceWorker() {
    if (!("serviceWorker" in navigator)) return;
    var h = window.location.hostname;
    var secure = window.location.protocol === "https:" || h === "localhost" || h === "127.0.0.1";
    if (!secure) return;
    window.addEventListener("load", function () {
      navigator.serviceWorker.register("sw.js").catch(function () { /* ไม่มีผลต่อการใช้งานปกติ */ });
    });
  }

  buildNav("");
  applyStoredTheme();
  render(currentSlug());
  registerServiceWorker();
})();
