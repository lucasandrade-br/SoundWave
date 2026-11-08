import '../models/user_settings.dart';

class DemoClock {
  DemoClock({
    required DemoClockSettings Function() settings,
    DateTime Function()? now,
  }) : _settings = settings,
       _now = now ?? DateTime.now;

  final DemoClockSettings Function() _settings;
  final DateTime Function() _now;

  DateTime get realTime => _now();

  DateTime get effectiveTime {
    final actual = realTime;
    final config = _settings();
    if (!config.enabled) return actual;
    return actual.copyWith(
      hour: config.minuteOfDay ~/ 60,
      minute: config.minuteOfDay % 60,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }
}
