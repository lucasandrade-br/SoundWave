import 'package:flutter/material.dart';
import '../core/theme/soundwave_theme.dart';
import '../core/widgets/soundwave_header.dart';
import '../core/widgets/presentation_banner.dart';
import '../features/player/playback_widgets.dart';
import '../features/player/player_page.dart';
import 'app_bootstrap.dart';
import 'scrolling_page.dart';

class AppFrame extends StatelessWidget {
  const AppFrame({
    super.key,
    required this.services,
    required this.selectedTab,
    required this.onTab,
    required this.body,
  });
  final AppBootstrap services;
  final int selectedTab;
  final ValueChanged<int> onTab;
  final Widget body;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: services.userStore,
    builder: (context, _) => Container(
      color: SoundWaveColors.background,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(color: SoundWaveColors.border),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              bottom: false,
              child: PageChrome(
                leading: [
                  SoundWaveHeader(onProfile: () => onTab(3)),
                  PresentationBanner(
                    store: services.userStore,
                    clock: services.clock,
                  ),
                  if (services.userStore.warning case final warning?)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text(
                        warning,
                        style: const TextStyle(color: SoundWaveColors.error),
                      ),
                    ),
                ],
                child: body,
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MiniPlayer(
                    player: services.playback,
                    store: services.userStore,
                    onOpen: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PlayerPage(services: services),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: SoundWaveColors.border),
                      ),
                    ),
                    child: NavigationBar(
                      selectedIndex: selectedTab,
                      onDestinationSelected: onTab,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_rounded),
                          label: 'Início',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.search_rounded),
                          label: 'Buscar',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.library_music_outlined),
                          selectedIcon: Icon(Icons.library_music_rounded),
                          label: 'Biblioteca',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person_outline_rounded),
                          selectedIcon: Icon(Icons.person_rounded),
                          label: 'Perfil',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
