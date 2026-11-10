import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/hotlines.dart';
import '../core/theme.dart';

class SosBar extends StatelessWidget {
  const SosBar({super.key});

  Future<void> _call(Hotline h) async {
    final uri = h.telUri;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final h in kHotlines)
          ActionChip(
            avatar: const Icon(Icons.call, size: 16, color: AppTheme.danger),
            label: Text(h.number),
            onPressed: () => _call(h),
          ),
      ],
    );
  }
}

class HotlineGrid extends StatelessWidget {
  const HotlineGrid({super.key});

  Future<void> _call(Hotline h) async {
    final uri = h.telUri;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final h in kHotlines)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _call(h),
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Column(
                  children: [
                    Text(
                      h.number,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.danger,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      h.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
