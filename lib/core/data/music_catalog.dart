import '../models/catalog_models.dart';
import '../models/listening_context.dart';

class MusicCatalog {
  MusicCatalog({
    required Iterable<Track> tracks,
    required Iterable<MusicCollection> collections,
  }) : tracks = List.unmodifiable(tracks),
       collections = List.unmodifiable(collections) {
    _tracks = Map.unmodifiable({
      for (final track in this.tracks) track.id: track,
    });
    _collections = Map.unmodifiable({
      for (final collection in this.collections) collection.id: collection,
    });
    if (_tracks.length != this.tracks.length ||
        _collections.length != this.collections.length) {
      throw ArgumentError('IDs de catálogo duplicados.');
    }
    for (final track in this.tracks) {
      if (track.id.isEmpty ||
          track.title.isEmpty ||
          track.artist.isEmpty ||
          !track.assetPath.startsWith('assets/audio/') ||
          track.duration <= Duration.zero ||
          track.contexts.isEmpty) {
        throw ArgumentError('Faixa inválida: ${track.id}');
      }
      if (track.albumId != null &&
          _collections[track.albumId]?.type != CollectionType.album) {
        throw ArgumentError('Álbum inexistente: ${track.albumId}');
      }
    }
    for (final collection in this.collections) {
      if (collection.id.isEmpty ||
          collection.title.isEmpty ||
          collection.trackIds.any((id) => !_tracks.containsKey(id)) ||
          collection.trackIds.toSet().length != collection.trackIds.length) {
        throw ArgumentError('Coleção inválida: ${collection.id}');
      }
      if (collection.context != null &&
          collection.trackIds.any(
            (id) => !_tracks[id]!.contexts.contains(collection.context),
          )) {
        throw ArgumentError('Faixa incompatível com o contexto da coleção.');
      }
    }
  }

  final List<Track> tracks;
  final List<MusicCollection> collections;
  late final Map<String, Track> _tracks;
  late final Map<String, MusicCollection> _collections;

  Track? trackById(String id) => _tracks[id];
  MusicCollection? collectionById(String id) => _collections[id];

  List<Track> tracksFor(MusicCollection collection) =>
      List.unmodifiable(collection.trackIds.map((id) => _tracks[id]!).toList());

  Duration durationOf(MusicCollection collection) => tracksFor(
    collection,
  ).fold(Duration.zero, (duration, track) => duration + track.duration);

  MusicCollection contextCollection(ListeningContext context) =>
      collections.firstWhere((collection) => collection.context == context);
}
