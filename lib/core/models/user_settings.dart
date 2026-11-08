import 'listening_context.dart';

class UserProfile {
  UserProfile({
    String name = 'Lucas Carvalho',
    String handle = 'lucas.wav',
    Iterable<String> favoriteGenres = const [],
  }) : name = name.trim(),
       handle = handle.trim(),
       favoriteGenres = Set.unmodifiable(
         favoriteGenres.map((value) => value.trim()).where((v) => v.isNotEmpty),
       ) {
    if (this.name.isEmpty || this.name.length > 50 || this.handle.length > 30) {
      throw ArgumentError('Nome ou identificação fora dos limites.');
    }
  }

  final String name;
  final String handle;
  final Set<String> favoriteGenres;

  String get initials => name
      .split(RegExp(r'\s+'))
      .take(2)
      .map((part) => String.fromCharCode(part.runes.first))
      .join()
      .toUpperCase();
}

class PeriodSettings {
  PeriodSettings({
    this.morningStartHour = 6,
    this.afternoonStartHour = 12,
    this.nightStartHour = 18,
    Map<DayPeriod, List<ListeningContext>>? initialContexts,
  }) : initialContexts = Map.unmodifiable({
         for (final period in DayPeriod.values)
           period: List<ListeningContext>.unmodifiable(
             (initialContexts ?? defaultPairs)[period] ?? const [],
           ),
       }) {
    if (morningStartHour < 0 ||
        morningStartHour >= afternoonStartHour ||
        afternoonStartHour >= nightStartHour ||
        nightStartHour > 23) {
      throw ArgumentError(
        'Os inícios de períodos devem ser crescentes entre 0 e 23.',
      );
    }
    for (final pair in this.initialContexts.values) {
      if (pair.length != 2 || pair.toSet().length != 2) {
        throw ArgumentError(
          'Cada período precisa de dois contextos distintos.',
        );
      }
    }
  }

  static const defaultPairs = {
    DayPeriod.morning: [ListeningContext.study, ListeningContext.workout],
    DayPeriod.afternoon: [ListeningContext.work, ListeningContext.travel],
    DayPeriod.night: [ListeningContext.reading, ListeningContext.sleep],
  };

  final int morningStartHour;
  final int afternoonStartHour;
  final int nightStartHour;
  final Map<DayPeriod, List<ListeningContext>> initialContexts;

  DayPeriod periodAt(DateTime time) {
    if (time.hour >= nightStartHour || time.hour < morningStartHour) {
      return DayPeriod.night;
    }
    if (time.hour >= afternoonStartHour) return DayPeriod.afternoon;
    return DayPeriod.morning;
  }
}

class DemoClockSettings {
  DemoClockSettings({this.enabled = false, this.minuteOfDay = 8 * 60}) {
    if (minuteOfDay < 0 || minuteOfDay >= 24 * 60) {
      throw ArgumentError.value(minuteOfDay, 'minuteOfDay');
    }
  }

  final bool enabled;
  final int minuteOfDay;
}
