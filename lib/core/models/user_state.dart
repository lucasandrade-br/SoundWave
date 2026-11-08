import 'listening_context.dart';
import 'playback_snapshot.dart';
import 'user_settings.dart';

class PlaybackHistoryEntry {
  const PlaybackHistoryEntry({
    required this.id,
    required this.trackId,
    required this.realTime,
    required this.effectiveTime,
    required this.period,
    this.context,
  });

  final String id;
  final String trackId;
  final DateTime realTime;
  final DateTime effectiveTime;
  final DayPeriod period;
  final ListeningContext? context;
}

class UserState {
  UserState({
    UserProfile? profile,
    PeriodSettings? periods,
    DemoClockSettings? demoClock,
    PlaybackSnapshot? playback,
    Iterable<String> favoriteTrackIds = const [],
    Iterable<String> savedCollectionIds = const [],
    Iterable<String> recentSearches = const [],
    Iterable<PlaybackHistoryEntry> history = const [],
    Map<String, int> contextCounts = const {},
  }) : profile = profile ?? UserProfile(),
       periods = periods ?? PeriodSettings(),
       demoClock = demoClock ?? DemoClockSettings(),
       playback = playback ?? PlaybackSnapshot(),
       favoriteTrackIds = Set.unmodifiable(favoriteTrackIds),
       savedCollectionIds = Set.unmodifiable(savedCollectionIds),
       recentSearches = List.unmodifiable(recentSearches.take(10)),
       history = List.unmodifiable(history.take(100)),
       contextCounts = Map.unmodifiable(contextCounts);

  final UserProfile profile;
  final PeriodSettings periods;
  final DemoClockSettings demoClock;
  final PlaybackSnapshot playback;
  final Set<String> favoriteTrackIds;
  final Set<String> savedCollectionIds;
  final List<String> recentSearches;
  final List<PlaybackHistoryEntry> history;
  final Map<String, int> contextCounts;

  UserState copyWith({
    UserProfile? profile,
    PeriodSettings? periods,
    DemoClockSettings? demoClock,
    PlaybackSnapshot? playback,
    Iterable<String>? favoriteTrackIds,
    Iterable<String>? savedCollectionIds,
    Iterable<String>? recentSearches,
    Iterable<PlaybackHistoryEntry>? history,
    Map<String, int>? contextCounts,
  }) => UserState(
    profile: profile ?? this.profile,
    periods: periods ?? this.periods,
    demoClock: demoClock ?? this.demoClock,
    playback: playback ?? this.playback,
    favoriteTrackIds: favoriteTrackIds ?? this.favoriteTrackIds,
    savedCollectionIds: savedCollectionIds ?? this.savedCollectionIds,
    recentSearches: recentSearches ?? this.recentSearches,
    history: history ?? this.history,
    contextCounts: contextCounts ?? this.contextCounts,
  );
}
