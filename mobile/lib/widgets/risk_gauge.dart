import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/scoring.dart';
import '../core/theme.dart';
import 'tier_pill.dart';

class RiskResultCard extends StatelessWidget {
  const RiskResultCard({
    super.key,
    required this.score,
    this.title,
  });

  final int score;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final info = tierFor(score);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                RiskGauge(score: score, color: Color(info.colorArgb)),
                const SizedBox(width: 16),
                Expanded(child: TierPill(info: info)),
              ],
            ),
            const SizedBox(height: 14),
            AdviceList(items: adviceFor(score)),
            if (score >= 60) ...[
              const SizedBox(height: 8),
              Text(
                'อย่าโอนเงิน / อย่าให้ OTP / อย่าส่งเงินสด — โทร 1441 ได้ทันทีจากหน้าขอความช่วยเหลือ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.danger,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RiskGauge extends StatelessWidget {
  const RiskGauge({
    super.key,
    required this.score,
    required this.color,
  });

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 78,
      child: CustomPaint(
        painter: _GaugePainter(progress: score / 100, color: color),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            '$score',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 4);
    final radius = size.width * 0.42;
    final track = Paint()
      ..color = AppTheme.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final prog = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      track,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress.clamp(0.0, 1.0),
      false,
      prog,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
