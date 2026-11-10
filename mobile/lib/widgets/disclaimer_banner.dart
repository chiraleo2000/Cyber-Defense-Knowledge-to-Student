import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/hotlines.dart';
import '../core/theme.dart';

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.ribbonBg,
      child: InkWell(
        onTap: () => launchUrl(Uri(scheme: 'tel', path: '1441')),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.ribbonLine)),
          ),
          child: Text(
            kDisclaimerText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.danger,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
