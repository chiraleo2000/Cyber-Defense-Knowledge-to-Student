import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'screens/agent_screen.dart';
import 'screens/call_guardian_screen.dart';
import 'screens/help_screen.dart';
import 'screens/home_quiz_screen.dart';
import 'screens/image_screen.dart';
import 'screens/invest_screen.dart';
import 'screens/romance_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/video_screen.dart';
import 'screens/voice_screen.dart';
import 'widgets/disclaimer_banner.dart';

final _router = GoRouter(
  initialLocation: '/quiz',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(
        location: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(path: '/quiz', builder: (_, __) => const HomeQuizScreen()),
        GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
        GoRoute(path: '/video', builder: (_, __) => const VideoScreen()),
        GoRoute(path: '/image', builder: (_, __) => const ImageScreen()),
        GoRoute(path: '/voice', builder: (_, __) => const VoiceScreen()),
        GoRoute(path: '/romance', builder: (_, __) => const RomanceScreen()),
        GoRoute(path: '/invest', builder: (_, __) => const InvestScreen()),
        GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
        GoRoute(path: '/agent', builder: (_, __) => const AgentScreen()),
        GoRoute(path: '/guardian', builder: (_, __) => const CallGuardianScreen()),
      ],
    ),
  ],
);

class CheckBeforeTransferApp extends StatelessWidget {
  const CheckBeforeTransferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'เช็คก่อนโอน',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('th', 'TH'),
      routerConfig: _router,
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const _tabs = [
    ('/quiz', 'หน้าแรก', Icons.home_outlined),
    ('/scan', 'สแกน', Icons.search),
    ('/help', 'SOS', Icons.emergency_outlined),
    ('/agent', 'AI', Icons.smart_toy_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = _tabs.indexWhere((t) => location.startsWith(t.$1));
    final showBack = location != '/quiz';

    return Scaffold(
      appBar: AppBar(
        title: const Text('เช็คก่อนโอน'),
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/quiz');
                  }
                },
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'วิดีโอคอล',
            onPressed: () => context.go('/video'),
            icon: const Icon(Icons.videocam_outlined),
          ),
          IconButton(
            tooltip: 'ถอดเสียง',
            onPressed: () => context.go('/voice'),
            icon: const Icon(Icons.mic_none),
          ),
        ],
      ),
      body: Column(
        children: [
          const DisclaimerBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx < 0 ? 0 : idx,
        onDestinationSelected: (i) => context.go(_tabs[i].$1),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.$3), label: t.$2),
        ],
      ),
    );
  }
}
