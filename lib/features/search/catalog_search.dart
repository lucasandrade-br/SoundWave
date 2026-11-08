import '../../core/data/music_catalog.dart';
import '../../core/models/catalog_models.dart';
import '../../core/models/listening_context.dart';
import '../../core/services/search_text.dart';

class CatalogSearchResult {
  CatalogSearchResult(
    Iterable<Track> tracks,
    Iterable<MusicCollection> collections,
  ) : tracks = List.unmodifiable(tracks),
      collections = List.unmodifiable(collections);
  final List<Track> tracks;
  final List<MusicCollection> collections;
  bool get isEmpty => tracks.isEmpty && collections.isEmpty;
}

CatalogSearchResult searchCatalog(
  MusicCatalog catalog,
  String query, {
  ListeningContext? context,
}) {
  final normalized = normalizeSearchText(query);
  final tokens = normalized.isEmpty ? <String>[] : normalized.split(' ');
  bool matches(Iterable<String> fields) {
    final text = normalizeSearchText(fields.join(' '));
    return tokens.every(text.contains);
  }

  final tracks = catalog.tracks.where((track) {
    if (context != null && !track.contexts.contains(context)) return false;
    return matches([
      track.title,
      track.artist,
      ...track.tags,
      ...track.contexts.map((c) => c.label),
      ...catalog.collections
          .where((c) => c.trackIds.contains(track.id))
          .map((c) => c.title),
    ]);
  });
  final collections = catalog.collections.where((collection) {
    final members = catalog.tracksFor(collection);
    if (context != null && !members.any((t) => t.contexts.contains(context))) {
      return false;
    }
    return matches([
      collection.title,
      collection.creator,
      collection.description,
      if (collection.context != null) collection.context!.label,
      ...members.expand((t) => t.tags),
    ]);
  });
  return CatalogSearchResult(tracks, collections);
}
