import '../../app/scrolling_page.dart';
import 'package:flutter/material.dart';
import '../../app/app_bootstrap.dart';
import '../../core/models/catalog_models.dart';
import '../../core/theme/soundwave_theme.dart';
import '../../core/widgets/catalog_widgets.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({
    super.key,
    required this.services,
    required this.collection,
    required this.onBack,
  });
  final AppBootstrap services;
  final MusicCollection collection;
  final VoidCallback onBack;
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  bool _sortByTitle = false;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      widget.services.playback,
      widget.services.userStore,
    ]),
    builder: (context, _) {
      final services = widget.services;
      final collection = widget.collection;
      final tracks = collection.id == 'liked_tracks'
          ? services.catalog.tracks
                .where(
                  (t) =>
                      services.userStore.state.favoriteTrackIds.contains(t.id),
                )
                .toList()
          : services.catalog.tracksFor(collection);
      final ordered = [...tracks];
      if (_sortByTitle) ordered.sort((a, b) => a.title.compareTo(b.title));
      final saved = services.userStore.state.savedCollectionIds.contains(
        collection.id,
      );
      final canSave = services.catalog.collectionById(collection.id) != null;
      return ScrollingPage(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Voltar da coleção',
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Expanded(
                child: Text(
                  'SUA SELEÇÃO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SoundWaveColors.secondary,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções da coleção',
                enabled: ordered.isNotEmpty,
                onSelected: (_) => services.playback.addTracks(ordered),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'queue',
                    child: Text('Adicionar todas à fila'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: MusicArtwork(contextType: collection.context, size: 140),
          ),
          const SizedBox(height: 24),
          Text(
            collection.title,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            collection.description,
            style: const TextStyle(color: SoundWaveColors.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            '${ordered.length} faixas · ${compactDuration(ordered.fold(Duration.zero, (d, t) => d + t.duration))}',
            style: const TextStyle(color: SoundWaveColors.secondary),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: ordered.isEmpty
                    ? null
                    : () => services.playback.playTracks(
                        ordered,
                        context: collection.context,
                      ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Tocar tudo'),
              ),
              IconButton(
                tooltip: 'Tocar coleção em ordem aleatória',
                onPressed: ordered.isEmpty
                    ? null
                    : () => services.playback.playTracks(
                        ordered,
                        context: collection.context,
                        shuffled: true,
                      ),
                icon: const Icon(Icons.shuffle_rounded),
              ),
              if (canSave)
                IconButton(
                  tooltip: saved
                      ? 'Remover coleção da biblioteca'
                      : 'Salvar coleção na biblioteca',
                  onPressed: () => services.userStore.setCollectionSaved(
                    collection.id,
                    !saved,
                  ),
                  icon: Icon(
                    saved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: saved
                        ? SoundWaveColors.purple
                        : SoundWaveColors.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Faixas da seleção',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              PopupMenuButton<bool>(
                tooltip: 'Ordenar faixas',
                onSelected: (value) => setState(() => _sortByTitle = value),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: false,
                    child: Text('Ordem original'),
                  ),
                  const PopupMenuItem(value: true, child: Text('Título')),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.sort_rounded),
                ),
              ),
            ],
          ),
          if (ordered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Nenhuma música nesta seleção ainda.'),
            ),
          for (final (index, track) in ordered.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SurfaceCard(
                padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                onTap: () => services.playback.playTracks(
                  ordered,
                  startIndex: index,
                  context: collection.context,
                ),
                child: Row(
                  children: [
                    MusicArtwork(contextType: track.contexts.first, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  services.playback.currentTrack?.id == track.id
                                  ? SoundWaveColors.cyan
                                  : SoundWaveColors.text,
                            ),
                          ),
                          Text(
                            '${track.artist} · ${trackDuration(track.duration)}',
                            style: const TextStyle(
                              color: SoundWaveColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Opções de ${track.title}',
                      onSelected: (value) => value == 'queue'
                          ? services.playback.addTracks([track])
                          : services.userStore.setTrackFavorite(
                              track.id,
                              !services.userStore.state.favoriteTrackIds
                                  .contains(track.id),
                            ),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'favorite',
                          child: Text(
                            services.userStore.state.favoriteTrackIds.contains(
                                  track.id,
                                )
                                ? 'Descurtir música'
                                : 'Curtir música',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'queue',
                          child: Text('Adicionar à fila'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}
