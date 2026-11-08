import '../../core/data/music_catalog.dart';
import '../../core/models/catalog_models.dart';
import '../../core/models/user_state.dart';
import '../../core/services/search_text.dart';

enum LibraryFilter { all, playlists, artists, albums, collections }

List<MusicCollection> artistCollections(MusicCatalog catalog) {
  final groups = <String, List<Track>>{};
  for (final track in catalog.tracks) {
    groups.putIfAbsent(normalizeSearchText(track.artist), () => []).add(track);
  }
  return groups.entries
      .map(
        (item) => MusicCollection(
          id: 'artist_${Uri.encodeComponent(item.key)}',
          title: item.value.first.artist,
          description: 'Faixas deste artista no catálogo local.',
          type: CollectionType.group,
          creator: item.value.first.artist,
          trackIds: item.value.map((t) => t.id),
        ),
      )
      .toList();
}

List<Track> recentTracks(MusicCatalog catalog, UserState state) => state.history
    .map((h) => h.trackId)
    .toSet()
    .map(catalog.trackById)
    .whereType<Track>()
    .toList();
