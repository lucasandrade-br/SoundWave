import '../../app/scrolling_page.dart';
import 'package:flutter/material.dart';
import '../../core/data/music_catalog.dart';
import '../../core/models/catalog_models.dart';
import '../../core/services/user_store.dart';
import '../../core/theme/soundwave_theme.dart';
import '../../core/widgets/catalog_widgets.dart';
import '../../core/widgets/catalog_tiles.dart';
import 'library_catalog.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({
    super.key,
    required this.catalog,
    required this.store,
    required this.filter,
    required this.onFilterChanged,
    required this.onOpenCollection,
    required this.onOpenFavorites,
    required this.onPlayTracks,
    required this.onAddTrack,
  });
  final MusicCatalog catalog;
  final UserStore store;
  final LibraryFilter filter;
  final ValueChanged<LibraryFilter> onFilterChanged;
  final ValueChanged<MusicCollection> onOpenCollection;
  final VoidCallback onOpenFavorites;
  final void Function(List<Track>, int) onPlayTracks;
  final ValueChanged<Track> onAddTrack;

  @override
  Widget build(BuildContext context) {
    final state = store.state;
    final liked = catalog.tracks
        .where((t) => state.favoriteTrackIds.contains(t.id))
        .toList();
    final recent = recentTracks(catalog, state);
    bool accepts(MusicCollection c) => switch (filter) {
      LibraryFilter.playlists => c.type == CollectionType.playlist,
      LibraryFilter.albums => c.type == CollectionType.album,
      LibraryFilter.artists => false,
      _ => true,
    };
    final saved = catalog.collections
        .where((c) => state.savedCollectionIds.contains(c.id) && accepts(c))
        .toList();
    final ready = catalog.collections
        .where(
          (c) =>
              (c.type == CollectionType.playlist ||
                  c.type == CollectionType.album) &&
              accepts(c),
        )
        .toList();
    final artists = artistCollections(catalog);
    Widget collectionTile(MusicCollection c, {String section = 'ready'}) =>
        CollectionCatalogTile(
          key: ValueKey('library-$section-${c.id}'),
          collection: c,
          duration: catalog.durationOf(c),
          onTap: () => onOpenCollection(c),
          saved: state.savedCollectionIds.contains(c.id),
          onSave: catalog.collectionById(c.id) == null
              ? null
              : () => store.setCollectionSaved(
                  c.id,
                  !store.state.savedCollectionIds.contains(c.id),
                ),
        );
    Widget trackTile(Track track, int index) => TrackCatalogTile(
      key: ValueKey('recent-${track.id}'),
      track: track,
      onTap: () => onPlayTracks(recent, index),
      favorite: state.favoriteTrackIds.contains(track.id),
      onFavorite: () => store.setTrackFavorite(
        track.id,
        !store.state.favoriteTrackIds.contains(track.id),
      ),
      onAdd: () => onAddTrack(track),
    );
    return ScrollingPage(
      key: const PageStorageKey('library-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text('Biblioteca', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        const Text(
          'Suas coleções e favoritos em um só lugar.',
          style: TextStyle(color: SoundWaveColors.secondary),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (value, label) in [
              (LibraryFilter.all, 'Tudo'),
              (LibraryFilter.playlists, 'Playlists'),
              (LibraryFilter.artists, 'Artistas'),
              (LibraryFilter.albums, 'Álbuns'),
            ])
              ChoiceChip(
                label: Text(label),
                selected: filter == value,
                onSelected: (_) => onFilterChanged(value),
              ),
            if (filter == LibraryFilter.collections)
              InputChip(
                label: const Text('Coleções prontas'),
                onDeleted: () => onFilterChanged(LibraryFilter.all),
                deleteButtonTooltipMessage: 'Mostrar toda a biblioteca',
              ),
          ],
        ),
        const SizedBox(height: 24),
        if (filter == LibraryFilter.all ||
            filter == LibraryFilter.playlists) ...[
          SurfaceCard(
            onTap: onOpenFavorites,
            child: Row(
              children: [
                const MusicArtwork(icon: Icons.favorite_rounded, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Músicas curtidas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${liked.length} faixas salvas',
                        style: const TextStyle(
                          color: SoundWaveColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Tocar músicas curtidas',
                  onPressed: liked.isEmpty
                      ? null
                      : () => onPlayTracks(liked, 0),
                  icon: const Icon(Icons.play_arrow_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (filter != LibraryFilter.artists &&
            filter != LibraryFilter.collections) ...[
          const SectionHeading(title: 'COLEÇÕES SALVAS'),
          if (saved.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Use o coração de uma coleção para salvá-la aqui.',
                style: TextStyle(color: SoundWaveColors.secondary),
              ),
            ),
          for (final c in saved) collectionTile(c, section: 'saved'),
          const SizedBox(height: 12),
        ],
        if (filter != LibraryFilter.artists) ...[
          const SectionHeading(title: 'COLEÇÕES PRONTAS'),
          if (ready.isEmpty)
            const EmptyCatalogState(
              title: 'Nenhuma coleção neste filtro',
              message: 'Escolha outro filtro para explorar o catálogo.',
            ),
          for (final c in ready) collectionTile(c),
        ],
        if (filter == LibraryFilter.all || filter == LibraryFilter.artists) ...[
          const SizedBox(height: 20),
          const SectionHeading(title: 'ARTISTAS'),
          if (artists.isEmpty)
            const Text('Nenhum artista disponível no catálogo.'),
          for (final artist in artists) collectionTile(artist),
        ],
        if (filter == LibraryFilter.all) ...[
          const SizedBox(height: 20),
          SectionHeading(
            title: 'TOCADOS RECENTEMENTE',
            action: recent.isEmpty ? null : 'Ver tudo',
            onAction: recent.isEmpty
                ? null
                : () => onOpenCollection(
                    MusicCollection(
                      id: 'recent_tracks',
                      title: 'Tocados recentemente',
                      description:
                          'Suas últimas faixas, das mais recentes para as anteriores.',
                      type: CollectionType.group,
                      trackIds: recent.map((t) => t.id),
                    ),
                  ),
          ),
          if (recent.isEmpty)
            const Text(
              'As músicas que você ouvir aparecerão aqui.',
              style: TextStyle(color: SoundWaveColors.secondary),
            ),
          for (final (index, track) in recent.take(4).indexed)
            trackTile(track, index),
        ],
      ],
    );
  }
}
