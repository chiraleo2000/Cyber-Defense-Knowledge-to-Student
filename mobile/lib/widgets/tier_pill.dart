import 'package:flutter/material.dart';

import '../core/scoring.dart';
import '../core/theme.dart';

class TierPill extends StatelessWidget {
  const TierPill({super.key, required this.info});

  final TierInfo info;

  Color get _bg {
    switch (info.tier) {
      case RiskTier.safe:
        return const Color(0xFFE6F4EC);
      case RiskTier.watch:
        return const Color(0xFFFFF6E0);
      case RiskTier.high:
        return const Color(0xFFFFEDD5);
      case RiskTier.critical:
        return const Color(0xFFFEE2E2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(info.colorArgb);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            info.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class AdviceList extends StatelessWidget {
  const AdviceList({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final a in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.accent),
                const SizedBox(width: 8),
                Expanded(child: Text(a, style: const TextStyle(height: 1.45))),
              ],
            ),
          ),
      ],
    );
  }
}
