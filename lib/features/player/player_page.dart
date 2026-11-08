import '../../app/scrolling_page.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/app_bootstrap.dart';
import '../../core/theme/soundwave_theme.dart';
import '../../core/widgets/catalog_widgets.dart';
import '../../core/widgets/presentation_banner.dart';
import 'playback_controller.dart';
import 'playback_widgets.dart';
import 'queue_panel.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key, required this.services});
  final AppBootstrap services;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: SoundWaveColors.background,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Scaffold(
          backgroundColor: SoundWaveColors.background,
          body: SafeArea(
            child: ListenableBuilder(
              listenable: Listenable.merge([
                services.playback,
                services.userStore,
              ]),
              builder: (context, _) {
                final player = services.playback;
                final track = player.currentTrack;
                return ScrollingPage(
                  padding: const EdgeInsets.all(20),
                  children: [
                    PresentationBanner(
                      store: services.userStore,
                      clock: services.clock,
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Fechar player',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                        const Expanded(
                          child: Text(
                            'TOCANDO AGORA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: SoundWaveColors.secondary,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Abrir fila',
                          onPressed: () => showQueuePanel(context, services),
                          icon: const Icon(Icons.queue_music_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    if (track == null)
                      const EmptyCatalogState(
                        title: 'Escolha sua próxima música',
                        message: 'Abra uma seleção na biblioteca para começar.',
                      )
                    else ...[
                      Center(
                        child: MusicArtwork(
                          contextType: track.contexts.first,
                          size: min(MediaQuery.sizeOf(context).width - 64, 300),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  track.artist,
                                  style: const TextStyle(
                                    color: SoundWaveColors.secondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TrackFavoriteButton(
                            store: services.userStore,
                            trackId: track.id,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SeekControl(
                        key: ValueKey(player.currentEntry!.entryId),
                        player: player,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: 'Faixa anterior',
                            onPressed: player.busy ? null : player.previous,
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 24),
                          PlayPauseButton(player: player, large: true),
                          const SizedBox(width: 24),
                          IconButton(
                            tooltip: 'Próxima faixa',
                            onPressed: player.busy || !player.canNext
                                ? null
                                : player.next,
                            icon: const Icon(Icons.skip_next_rounded, size: 32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PlaybackModeButtons(player: player),
                      Center(
                        child: Text(
                          player.status.label,
                          style: const TextStyle(
                            color: SoundWaveColors.secondary,
                          ),
                        ),
                      ),
                      PlaybackError(player: player),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => showQueuePanel(context, services),
                        icon: const Icon(Icons.queue_music_rounded),
                        label: const Text('Fila de reprodução'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

class SeekControl extends StatefulWidget {
  const SeekControl({super.key, required this.player});
  final PlaybackController player;
  @override
  State<SeekControl> createState() => _SeekControlState();
}

class _SeekControlState extends State<SeekControl> {
  double? _drag;
  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final maximum = max(1, player.duration.inMilliseconds).toDouble();
    final value = (_drag ?? player.position.inMilliseconds.toDouble()).clamp(
      0.0,
      maximum,
    );
    return Column(
      children: [
        Slider(
          semanticFormatterCallback: (v) =>
              'Posição ${trackDuration(Duration(milliseconds: v.round()))}',
          label: trackDuration(Duration(milliseconds: value.round())),
          value: value,
          max: maximum,
          onChanged: player.busy ? null : (v) => setState(() => _drag = v),
          onChangeEnd: player.busy
              ? null
              : (v) async {
                  await player.seek(Duration(milliseconds: v.round()));
                  if (mounted) setState(() => _drag = null);
                },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(trackDuration(Duration(milliseconds: value.round()))),
            Text(trackDuration(player.duration)),
          ],
        ),
      ],
    );
  }
}
