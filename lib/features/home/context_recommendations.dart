import '../../core/models/listening_context.dart';
import '../../core/models/user_state.dart';

List<ListeningContext> recommendedContexts(UserState state, DayPeriod period) {
  final preferred = state.periods.initialContexts[period]!;
  int priority(ListeningContext context) {
    final index = preferred.indexOf(context);
    return index >= 0 ? index : preferred.length + context.index;
  }

  final ordered = [...ListeningContext.values]
    ..sort((a, b) {
      final countA = state.contextCounts['${period.id}:${a.id}'] ?? 0;
      final countB = state.contextCounts['${period.id}:${b.id}'] ?? 0;
      final countOrder = countB.compareTo(countA);
      return countOrder != 0 ? countOrder : priority(a).compareTo(priority(b));
    });
  return List.unmodifiable(ordered.take(2));
}
