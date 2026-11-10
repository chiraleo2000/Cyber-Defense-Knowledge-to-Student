/// Shared risk scoring — ported from webapp-source/check-kon-oon.html
/// (`tierFor`, `adviceFor`, `scoreSeg` / `scoreChk`).

enum RiskTier {
  safe,
  watch,
  high,
  critical,
}

class TierInfo {
  const TierInfo({
    required this.tier,
    required this.label,
    required this.colorArgb,
  });

  final RiskTier tier;
  final String label;

  /// ARGB without alpha channel semantics — UI maps these to Material colors.
  final int colorArgb;
}

TierInfo tierFor(int score) {
  if (score < 30) {
    return const TierInfo(
      tier: RiskTier.safe,
      label: 'ปลอดภัย',
      colorArgb: 0xFF1F7A4C,
    );
  }
  if (score < 60) {
    return const TierInfo(
      tier: RiskTier.watch,
      label: 'เฝ้าระวัง',
      colorArgb: 0xFFB7791F,
    );
  }
  if (score < 80) {
    return const TierInfo(
      tier: RiskTier.high,
      label: 'เสี่ยงสูง',
      colorArgb: 0xFFC05621,
    );
  }
  return const TierInfo(
    tier: RiskTier.critical,
    label: 'อันตรายเฉียบพลัน',
    colorArgb: 0xFFC53030,
  );
}

List<String> adviceFor(int score) {
  if (score < 30) {
    return const [
      'ยังไม่พบสัญญาณอันตรายชัดเจน แต่ควรติดตามสถานการณ์ต่อไป',
      'ศึกษา 5 สัญญาณอันตรายไว้ล่วงหน้าเพื่อรู้ทันหากเกิดเหตุจริง',
    ];
  }
  if (score < 60) {
    return const [
      'หยุดคิดสักครู่ อย่าเพิ่งดำเนินการใดๆ ต่อ',
      'โทรกลับหน่วยงานผ่านเบอร์ทางการเพื่อตรวจสอบ',
      'ปรึกษาคนใกล้ตัวก่อนตัดสินใจ',
    ];
  }
  if (score < 80) {
    return const [
      'วางสายหรือหยุดการสนทนาทันที',
      'ห้ามโอนเงินหรือให้ข้อมูลส่วนตัวเพิ่มเติมเด็ดขาด',
      'แจ้งอาจารย์ที่ปรึกษาหรือครอบครัวทันที',
    ];
  }
  return const [
    'วางสายทันทีและอย่ากลับไปคุยต่อ',
    'โทรแจ้งสายด่วน 1441 หรือ 191 ทันที',
    'หากโอนเงินไปแล้ว รีบติดต่อธนาคารเพื่อขออายัดบัญชี',
  ];
}

/// Sum selected item weights and clamp to 0–100 (webapp `scoreSeg` / `scoreChk`).
int scoreWeighted(List<int> weights, List<bool> selected) {
  assert(weights.length == selected.length);
  var total = 0;
  for (var i = 0; i < weights.length; i++) {
    if (selected[i]) total += weights[i];
  }
  if (total < 0) return 0;
  if (total > 100) return 100;
  return total;
}
