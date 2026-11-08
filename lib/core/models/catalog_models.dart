import 'listening_context.dart';

enum TrackType { music, podcast }

enum CollectionType { playlist, album, context, group }

class Track {
  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.assetPath,
    required this.duration,
    required Iterable<ListeningContext> contexts,
    required Iterable<String> tags,
    this.albumId,
    this.artworkPath,
    this.type = TrackType.music,
  }) : contexts = Set.unmodifiable(contexts),
       tags = List.unmodifiable(tags);

  final String id;
  final String title;
  final String artist;
  final String assetPath;
  final Duration duration;
  final Set<ListeningContext> contexts;
  final List<String> tags;
  final String? albumId;
  final String? artworkPath;
  final TrackType type;
}

class MusicCollection {
  MusicCollection({
    required this.id,
    required this.title,
    required this.description,
    required Iterable<String> trackIds,
    this.creator = 'SoundWave Demo',
    this.type = CollectionType.playlist,
    this.context,
    this.coverPath,
  }) : trackIds = List.unmodifiable(trackIds);

  final String id;
  final String title;
  final String description;
  final String creator;
  final CollectionType type;
  final ListeningContext? context;
  final String? coverPath;
  final List<String> trackIds;
}
