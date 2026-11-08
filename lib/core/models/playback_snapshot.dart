enum PlaybackRepeatMode { off, all, one }

class QueueEntry {
  const QueueEntry({required this.entryId, required this.trackId});

  final String entryId;
  final String trackId;
}

/// Estado recuperável; reprodução ativa não é persistida.
class PlaybackSnapshot {
  PlaybackSnapshot({
    Iterable<QueueEntry> entries = const [],
    this.currentEntryId,
    this.position = Duration.zero,
    this.repeatMode = PlaybackRepeatMode.off,
    this.shuffleEnabled = false,
    Iterable<String> baseUpcomingEntryIds = const [],
  }) : entries = List.unmodifiable(entries),
       baseUpcomingEntryIds = List.unmodifiable(baseUpcomingEntryIds);

  final List<QueueEntry> entries;
  final String? currentEntryId;
  final Duration position;
  final PlaybackRepeatMode repeatMode;
  final bool shuffleEnabled;
  final List<String> baseUpcomingEntryIds;

  bool get isPlaying => false;
}
