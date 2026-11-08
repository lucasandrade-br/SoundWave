import 'package:flutter/material.dart';
import '../../app/app_bootstrap.dart';
import '../../core/models/catalog_models.dart';
import '../../core/services/catalog_recommendations.dart';
import '../../core/theme/soundwave_theme.dart';
import '../../core/widgets/catalog_widgets.dart';
import 'playback_widgets.dart';

Future<void> showQueuePanel(BuildContext context, AppBootstrap services) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => FractionallySizedBox(
        heightFactor: .9,
        child: QueuePanel(services: services),
      ),
    );

class QueuePanel extends StatefulWidget {
  const QueuePanel({super.key, required this.services});
  final AppBootstrap services;
  @override
  State<QueuePanel> createState() => _QueuePanelState();
}

class _QueuePanelState extends State<QueuePanel> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      widget.services.playback,
      widget.services.userStore,
    ]),
    builder: (context, _) {
      final player = widget.services.playback;
      final current = player.currentTrack;
      final future = player.upcoming;
      final queued = player.entries.map((e) => e.trackId).toSet();
      final genres = widget.services.userStore.state.profile.favoriteGenres;
      final suggestions = suggestedTracks(
        widget.services.catalog,
        current: current,
        queuedTrackIds: queued,
        favoriteGenres: genres,
      );
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fila de reprodução',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar fila',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (current != null)
                SurfaceCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      MusicArtwork(
                        contextType: current.contexts.first,
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOCANDO AGORA',
                              style: TextStyle(
                                color: SoundWaveColors.cyan,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              current.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              player.status.label,
                              style: const TextStyle(
                                color: SoundWaveColors.secondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PlayPauseButton(player: player),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final (index, label) in [
                    (0, 'A seguir'),
                    (1, 'Histórico'),
                    (2, 'Sugeridas'),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: _tab == index,
                      onSelected: (_) => setState(() => _tab = index),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _tab == 0
                  ? future.isEmpty
                        ? const Center(
                            child: Text('Você chegou ao fim da fila.'),
                          )
                        : ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            buildDefaultDragHandles: false,
                            itemCount: future.length,
                            onReorderItem: (oldIndex, newIndex) =>
                                player.reorderUpcoming(
                                  oldIndex,
                                  newIndex > oldIndex ? newIndex + 1 : newIndex,
                                ),
                            itemBuilder: (context, index) {
                              final entry = future[index];
                              final track = widget.services.catalog.trackById(
                                entry.trackId,
                              )!;
                              return Padding(
                                key: ValueKey(entry.entryId),
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SurfaceCard(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    0,
                                    10,
                                  ),
                                  onTap: () => player.playEntry(entry.entryId),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _QueueTrack(track: track),
                                      ),
                                      PopupMenuButton<String>(
                                        tooltip: 'Opções de ${track.title}',
                                        onSelected: (action) {
                                          if (action == 'remove') {
                                            player.removeUpcoming(
                                              entry.entryId,
                                            );
                                          }
                                          if (action == 'up') {
                                            player.reorderUpcoming(
                                              index,
                                              index - 1,
                                            );
                                          }
                                          if (action == 'down') {
                                            player.reorderUpcoming(
                                              index,
                                              index + 2,
                                            );
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          if (index > 0)
                                            const PopupMenuItem(
                                              value: 'up',
                                              child: Text('Mover para cima'),
                                            ),
                                          if (index < future.length - 1)
                                            const PopupMenuItem(
                                              value: 'down',
                                              child: Text('Mover para baixo'),
                                            ),
                                          const PopupMenuItem(
                                            value: 'remove',
                                            child: Text('Remover da fila'),
                                          ),
                                        ],
                                      ),
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: const Tooltip(
                                          message: 'Arrastar para reordenar',
                                          child: SizedBox(
                                            width: 40,
                                            height: 48,
                                            child: Icon(
                                              Icons.drag_handle_rounded,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                  : _tab == 1
                  ? ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (widget.services.userStore.state.history.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('Nenhuma reprodução no histórico.'),
                          ),
                        for (final item
                            in widget.services.userStore.state.history)
                          ListTile(
                            title: _QueueTrack(
                              track: widget.services.catalog.trackById(
                                item.trackId,
                              )!,
                            ),
                            onTap: () => player.playTracks([
                              widget.services.catalog.trackById(item.trackId)!,
                            ]),
                          ),
                      ],
                    )
                  : ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (suggestions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Nenhuma sugestão disponível para a fila e os gêneros atuais.',
                            ),
                          ),
                        for (final track in suggestions)
                          ListTile(
                            title: _QueueTrack(track: track),
                            trailing: IconButton(
                              tooltip: 'Adicionar ${track.title} à fila',
                              onPressed: () => player.addTracks([track]),
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      );
    },
  );
}

class _QueueTrack extends StatelessWidget {
  const _QueueTrack({required this.track});
  final Track track;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(track.title, style: Theme.of(context).textTheme.titleMedium),
      Text(
        '${track.artist} · ${trackDuration(track.duration)}',
        style: const TextStyle(color: SoundWaveColors.secondary, fontSize: 12),
      ),
    ],
  );
}
