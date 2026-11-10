import 'package:check_before_transfer/core/checklists.dart';
import 'package:check_before_transfer/core/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('quiz scoring fixtures', () {
    test('tier boundaries match webapp', () {
      expect(tierFor(0).tier, RiskTier.safe);
      expect(tierFor(29).tier, RiskTier.safe);
      expect(tierFor(30).tier, RiskTier.watch);
      expect(tierFor(59).tier, RiskTier.watch);
      expect(tierFor(60).tier, RiskTier.high);
      expect(tierFor(79).tier, RiskTier.high);
      expect(tierFor(80).tier, RiskTier.critical);
      expect(tierFor(100).label, 'อันตรายเฉียบพลัน');
    });

    test('OTP alone is already critical (>=60)', () {
      final weights = kQuizItems.map((e) => e.weight).toList();
      final selected = List<bool>.filled(weights.length, false);
      final otpIndex = kQuizItems.indexWhere((e) => e.question.contains('OTP'));
      expect(otpIndex, greaterThanOrEqualTo(0));
      selected[otpIndex] = true;
      final score = scoreWeighted(weights, selected);
      expect(score, 60);
      expect(tierFor(score).tier, RiskTier.high);
      expect(adviceFor(score).any((a) => a.contains('1441') || a.contains('วางสาย')), isTrue);
    });

    test('hostage image cue alone scores 70 (high risk)', () {
      final weights = kQuizItems.map((e) => e.weight).toList();
      final selected = List<bool>.filled(weights.length, false);
      final idx = kQuizItems.indexWhere((e) => e.question.contains('ถูกทำร้าย'));
      selected[idx] = true;
      final score = scoreWeighted(weights, selected);
      expect(score, 70);
      expect(tierFor(score).tier, RiskTier.high);
    });

    test('Telegram + OTP + hostage clamps at 100', () {
      final weights = kQuizItems.map((e) => e.weight).toList();
      final selected = List<bool>.filled(weights.length, false);
      for (var i = 0; i < kQuizItems.length; i++) {
        final q = kQuizItems[i].question;
        if (q.contains('Telegram') || q.contains('OTP') || q.contains('ถูกทำร้าย')) {
          selected[i] = true;
        }
      }
      expect(scoreWeighted(weights, selected), 100);
      expect(tierFor(100).tier, RiskTier.critical);
    });

    test('video checklist max is 100', () {
      final weights = kVideoItems.map((e) => e.weight).toList();
      final selected = List<bool>.filled(weights.length, true);
      expect(scoreWeighted(weights, selected), 100);
    });
  });
}
