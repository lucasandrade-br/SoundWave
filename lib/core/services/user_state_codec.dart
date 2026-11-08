import 'dart:convert';

import '../data/music_catalog.dart';
import '../models/listening_context.dart';
import '../models/playback_snapshot.dart';
import '../models/user_settings.dart';
import '../models/user_state.dart';
import 'search_text.dart';

class DecodedUserState {
  const DecodedUserState(this.state, {required this.repaired});
  final UserState state;
  final bool repaired;
}

class UserStateCodec {
  const UserStateCodec(this.catalog);
  final MusicCatalog catalog;

  String encode(UserState state) => jsonEncode({
    'schemaVersion': 1,
    'profile': {
      'name': state.profile.name,
      'handle': state.profile.handle,
      'favoriteGenres': state.profile.favoriteGenres.toList(),
    },
    'periods': {
      'morningStartHour': state.periods.morningStartHour,
      'afternoonStartHour': state.periods.afternoonStartHour,
      'nightStartHour': state.periods.nightStartHour,
      'initialContexts': {
        for (final pair in state.periods.initialContexts.entries)
          pair.key.id: pair.value.map((context) => context.id).toList(),
      },
    },
    'demoClock': {
      'enabled': state.demoClock.enabled,
      'minuteOfDay': state.demoClock.minuteOfDay,
    },
    'favoriteTrackIds': state.favoriteTrackIds.toList(),
    'savedCollectionIds': state.savedCollectionIds.toList(),
    'recentSearches': state.recentSearches,
    'contextCounts': state.contextCounts,
    'history': [
      for (final item in state.history)
        {
          'id': item.id,
          'trackId': item.trackId,
          'realTime': item.realTime.toIso8601String(),
          'effectiveTime': item.effectiveTime.toIso8601String(),
          'period': item.period.id,
          'contextId': item.context?.id,
        },
    ],
    'playback': {
      'entries': [
        for (final entry in state.playback.entries)
          {'entryId': entry.entryId, 'trackId': entry.trackId},
      ],
      'currentEntryId': state.playback.currentEntryId,
      'positionMs': state.playback.position.inMilliseconds,
      'repeatMode': state.playback.repeatMode.name,
      'shuffleEnabled': state.playback.shuffleEnabled,
      'baseUpcomingEntryIds': state.playback.baseUpcomingEntryIds,
    },
  });

  DecodedUserState decode(String source) {
    final value = jsonDecode(source);
    if (value is! Map<String, dynamic> ||
        value['schemaVersion'] is! int ||
        value['schemaVersion'] != 1) {
      throw const FormatException('Formato de estado não suportado.');
    }
    final reader = _StateReader(catalog);
    final state = UserState(
      profile: reader.profile(value['profile']),
      periods: reader.periods(value['periods']),
      demoClock: reader.demoClock(value['demoClock']),
      favoriteTrackIds: reader.knownIds(
        value['favoriteTrackIds'],
        (id) => catalog.trackById(id) != null,
      ),
      savedCollectionIds: reader.knownIds(
        value['savedCollectionIds'],
        (id) => catalog.collectionById(id) != null,
      ),
      recentSearches: reader.searches(value['recentSearches']),
      history: reader.history(value['history']),
      contextCounts: reader.counts(value['contextCounts']),
      playback: reader.playback(value['playback']),
    );
    return DecodedUserState(state, repaired: reader.repaired);
  }
}

class _StateReader {
  _StateReader(this.catalog);
  final MusicCatalog catalog;
  bool repaired = false;

  Map<String, dynamic> map(Object? value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    repaired = true;
    return {};
  }

  List<dynamic> list(Object? value) {
    if (value == null) return [];
    if (value is List) return value;
    repaired = true;
    return [];
  }

  String text(Object? value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    repaired = true;
    return fallback;
  }

  int integer(Object? value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    repaired = true;
    return fallback;
  }

  bool boolean(Object? value, bool fallback) {
    if (value == null) return fallback;
    if (value is bool) return value;
    repaired = true;
    return fallback;
  }

  List<String> strings(Object? value) {
    final result = <String>[];
    for (final item in list(value)) {
      if (item is! String || item.trim().isEmpty || item.length > 200) {
        repaired = true;
        continue;
      }
      final term = item.trim();
      if (!result.contains(term)) result.add(term);
    }
    return result;
  }

  Set<String> knownIds(Object? value, bool Function(String) exists) {
    return strings(value).where((id) {
      if (exists(id)) return true;
      repaired = true;
      return false;
    }).toSet();
  }

  List<String> searches(Object? value) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in strings(value)) {
      final term = cleanSearchTerm(raw);
      if (seen.add(normalizeSearchText(term))) {
        result.add(term);
      } else {
        repaired = true;
      }
    }
    return result.take(10).toList();
  }

  UserProfile profile(Object? value) {
    final data = map(value);
    try {
      return UserProfile(
        name: text(data['name'], 'Lucas Carvalho'),
        handle: text(data['handle'], 'lucas.wav'),
        favoriteGenres: strings(data['favoriteGenres']),
      );
    } on ArgumentError {
      repaired = true;
      return UserProfile();
    }
  }

  PeriodSettings periods(Object? value) {
    final data = map(value);
    final pairs = map(data['initialContexts']);
    final validPairs = <DayPeriod, List<ListeningContext>>{};
    for (final period in DayPeriod.values) {
      final rawPair = pairs[period.id];
      final items = strings(rawPair).map(ListeningContext.fromId).toList();
      if (items.length == 2 &&
          !items.contains(null) &&
          items.toSet().length == 2) {
        validPairs[period] = items.cast<ListeningContext>();
      } else {
        if (rawPair != null) repaired = true;
        validPairs[period] = PeriodSettings.defaultPairs[period]!;
      }
    }
    try {
      return PeriodSettings(
        morningStartHour: integer(data['morningStartHour'], 6),
        afternoonStartHour: integer(data['afternoonStartHour'], 12),
        nightStartHour: integer(data['nightStartHour'], 18),
        initialContexts: validPairs,
      );
    } on ArgumentError {
      repaired = true;
      return PeriodSettings();
    }
  }

  DemoClockSettings demoClock(Object? value) {
    final data = map(value);
    try {
      return DemoClockSettings(
        enabled: boolean(data['enabled'], false),
        minuteOfDay: integer(data['minuteOfDay'], 480),
      );
    } on ArgumentError {
      repaired = true;
      return DemoClockSettings();
    }
  }

  Map<String, int> counts(Object? value) {
    final allowed = {
      for (final period in DayPeriod.values)
        for (final context in ListeningContext.values)
          '${period.id}:${context.id}',
    };
    final result = <String, int>{};
    for (final entry in map(value).entries) {
      if (allowed.contains(entry.key) &&
          entry.value is int &&
          entry.value >= 0) {
        result[entry.key] = entry.value as int;
      } else {
        repaired = true;
      }
    }
    return result;
  }

  List<PlaybackHistoryEntry> history(Object? value) {
    final result = <PlaybackHistoryEntry>[];
    final ids = <String>{};
    for (final raw in list(value)) {
      final data = map(raw);
      final id = text(data['id']);
      final trackId = text(data['trackId']);
      final real = DateTime.tryParse(text(data['realTime']));
      final effective = DateTime.tryParse(text(data['effectiveTime']));
      final period = DayPeriod.fromId(data['period']);
      final context = ListeningContext.fromId(data['contextId']);
      if (id.isEmpty ||
          !ids.add(id) ||
          catalog.trackById(trackId) == null ||
          real == null ||
          effective == null ||
          period == null) {
        repaired = true;
        continue;
      }
      if (data['contextId'] != null && context == null) repaired = true;
      result.add(
        PlaybackHistoryEntry(
          id: id,
          trackId: trackId,
          realTime: real,
          effectiveTime: effective,
          period: period,
          context: context,
        ),
      );
      if (result.length == 100) break;
    }
    return result;
  }

  PlaybackSnapshot playback(Object? value) {
    final data = map(value);
    final entries = <QueueEntry>[];
    final ids = <String>{};
    for (final raw in list(data['entries']).take(500)) {
      final entry = map(raw);
      final id = text(entry['entryId']);
      final trackId = text(entry['trackId']);
      if (id.isEmpty || !ids.add(id) || catalog.trackById(trackId) == null) {
        repaired = true;
        continue;
      }
      entries.add(QueueEntry(entryId: id, trackId: trackId));
    }
    final selectedId = text(data['currentEntryId']);
    final index = entries.indexWhere((entry) => entry.entryId == selectedId);
    final current = entries.isEmpty ? null : entries[index < 0 ? 0 : index];
    if (selectedId.isNotEmpty && index < 0) repaired = true;
    final rawPosition = integer(data['positionMs'], 0);
    final maximum = current == null
        ? 0
        : catalog.trackById(current.trackId)!.duration.inMilliseconds;
    final position = index < 0 ? 0 : rawPosition.clamp(0, maximum);
    if (position != rawPosition) repaired = true;
    final upcomingIds = entries
        .skip(index < 0 ? 1 : index + 1)
        .map((e) => e.entryId)
        .toSet();
    final baseOrder = <String>[];
    for (final id in strings(data['baseUpcomingEntryIds'])) {
      if (upcomingIds.contains(id)) {
        baseOrder.add(id);
      } else {
        repaired = true;
      }
    }
    baseOrder.addAll(upcomingIds.where((id) => !baseOrder.contains(id)));
    final rawMode = text(data['repeatMode'], 'off');
    final repeat = PlaybackRepeatMode.values
        .where((mode) => mode.name == rawMode)
        .firstOrNull;
    if (repeat == null) repaired = true;
    return PlaybackSnapshot(
      entries: entries,
      currentEntryId: current?.entryId,
      position: Duration(milliseconds: position),
      repeatMode: repeat ?? PlaybackRepeatMode.off,
      shuffleEnabled: boolean(data['shuffleEnabled'], false),
      baseUpcomingEntryIds: baseOrder,
    );
  }
}
