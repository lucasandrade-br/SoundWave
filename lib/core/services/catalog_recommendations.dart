import '../data/music_catalog.dart';
import '../models/catalog_models.dart';
import 'search_text.dart';

List<Track> suggestedTracks(
  MusicCatalog catalog, {
  Track? current,
  Set<String> queuedTrackIds = const {},
  Set<String> favoriteGenres = const {},
}) {
  final genres = favoriteGenres.map(normalizeSearchText).toSet();
  return catalog.tracks
      .where(
        (track) =>
            !queuedTrackIds.contains(track.id) &&
            (current == null ||
                track.contexts.intersection(current.contexts).isNotEmpty) &&
            (genres.isEmpty ||
                track.tags.any(
                  (tag) => genres.contains(normalizeSearchText(tag)),
                )),
      )
      .toList();
}
