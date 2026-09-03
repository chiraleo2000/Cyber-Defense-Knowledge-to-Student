/* เช็คก่อนโอน — client-side markdown site renderer
   ไม่มี build step: โหลดไฟล์ .md จาก content/ ตรงๆ แล้ว render ด้วย marked.js (self-hosted)
   Routing: #/<slug> เช่น #/domestic-cases -> โหลด content/domestic-cases.md
*/
(function () {
  "use strict";

  var PAGES = [
    { slug: "index", label: "หน้าแรก", group: "เริ่มต้น", keywords: "home เริ่มต้น สัญญาณอันตราย" },
    { slug: "domestic-cases", label: "สถิติและคดีจริง (ไทย)", group: "ข้อมูลและสถิติ",
      keywords: "ในประเทศ ไทย ACSC AOC สถิติ คดีจริง แก๊งคอลเซ็นเตอร์ ไทม์ไลน์" },
    { slug: "international-cases", label: "มุมมองระดับโลก", group: "ข้อมูลและสถิติ",
      keywords: "ต่างประเทศ สากล โลก FBI IC3 virtual kidnapping romance scam" },
    { slug: "analysis-statistics", label: "การวิเคราะห์สถานการณ์", group: "ข้อมูลและสถิติ",
      keywords: "วิเคราะห์ กลโกง 5 ระยะ KPI ตัวชี้วัด แผนดำเนินงาน" },
    { slug: "handbook", label: "คู่มือรับมือฉบับเต็ม", group: "คู่มือและแนวทาง",
      keywords: "คู่มือ รับมือ 3 เสาหลัก ตรวจจับ วิดีโอคอล romance scam ลงทุน" },
    { slug: "recommendations", label: "ข้อเสนอแนะเชิงนโยบาย", group: "คู่มือและแนวทาง",
      keywords: "นโยบาย ข้อเสนอแนะ มหาวิทยาลัย สถาบันการเงิน ครอบครัว หน่วยงาน" },
    { slug: "media-sources", label: "แหล่งที่มาของสื่อ", group: "คู่มือและแนวทาง",
      keywords: "แหล่งข่าว อ้างอิง สำนักข่าว ตรวจสอบข่าว หน่วยงาน" },
    { slug: "survey-report", label: "แบบสำรวจความตระหนักรู้", group: "คู่มือและแนวทาง",
      keywords: "แบบสอบถาม สำรวจ วิจัย ตระหนักรู้" },
    { slug: "downloads", label: "ดาวน์โหลดโปสเตอร์/เอกสาร", group: "ดาวน์โหลด",
      keywords: "โปสเตอร์ PDF facebook instagram แคปชั่น ดาวน์โหลด" }
  ];

  var contentEl = document.getElementById("doc-content");
  var navEl = document.getElementById("side-nav");
  var searchEl = document.getElementById("search-box");
  var sidebarEl = document.getElementById("sidebar");
  var menuBtn = document.getElementById("menu-btn");
  var themeBtn = document.getElementById("theme-btn");

  var cache = {}; // slug -> {raw, html, title}

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
        html += '<a href="#/' + p.slug + '" data-slug="' + p.slug + '">' + p.label + "</a>";
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

  function currentSlug() {
    var h = window.location.hash.replace(/^#\/?/, "");
    return h || "index";
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

  function wrapTables(html) {
    // wrap <table> in a scrollable container so wide tables never overflow the page,
    // and rewrite internal "xxx.md" links to hash routes so the SPA router handles them
    // instead of the browser trying to navigate to a raw markdown file.
    var div = document.createElement("div");
    div.innerHTML = html;
    var tables = div.querySelectorAll("table");
    for (var i = 0; i < tables.length; i++) {
      var wrap = document.createElement("div");
      wrap.className = "table-wrap";
      tables[i].parentNode.insertBefore(wrap, tables[i]);
      wrap.appendChild(tables[i]);
    }
    var links = div.querySelectorAll("a[href$='.md']");
    for (var j = 0; j < links.length; j++) {
      var href = links[j].getAttribute("href");
      var slug = href.replace(/\.md$/, "");
      links[j].setAttribute("href", "#/" + slug);
    }
    return div.innerHTML;
  }

  function render(slug) {
    if (cache[slug]) {
      paint(cache[slug]);
      return;
    }
    contentEl.innerHTML = '<p style="color:var(--ink-soft)">กำลังโหลด…</p>';
    fetch("content/" + slug + ".md", { cache: "no-cache" })
      .then(function (r) {
        if (!r.ok) throw new Error("not found");
        return r.text();
      })
      .then(function (raw) {
        var parsed = stripFrontMatter(raw);
        var html = wrapTables(marked.parse(parsed.body));
        var titleMatch = parsed.body.match(/^#\s+(.+)$/m);
        var title = (parsed.meta && parsed.meta.title) || (titleMatch ? titleMatch[1] : slug);
        cache[slug] = { html: html, title: title };
        paint(cache[slug]);
      })
      .catch(function () {
        contentEl.innerHTML =
          '<div class="doc"><h1>ไม่พบหน้านี้</h1><p>ไม่พบเนื้อหาที่ต้องการ กรุณาเลือกหัวข้อจากเมนูด้านซ้าย</p></div>';
      });
  }

  function paint(entry) {
    contentEl.innerHTML = '<article class="doc">' + entry.html + "</article>";
    document.title = entry.title + " — เช็คก่อนโอน";
    window.scrollTo(0, 0);
    highlightActive();
    if (sidebarEl.classList.contains("open")) sidebarEl.classList.remove("open");
  }

  window.addEventListener("hashchange", function () {
    render(currentSlug());
  });

  searchEl.addEventListener("input", function (e) {
    buildNav(e.target.value.trim());
  });

  menuBtn.addEventListener("click", function () {
    sidebarEl.classList.toggle("open");
  });

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
    themeBtn.textContent = t === "dark" ? "☀︎ โหมดสว่าง" : t === "light" ? "☾ โหมดมืด" : "◐ ธีมอัตโนมัติ";
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

  buildNav("");
  applyStoredTheme();
  render(currentSlug());
})();
