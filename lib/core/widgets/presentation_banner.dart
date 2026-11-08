import 'package:flutter/material.dart';
import '../services/demo_clock.dart';
import '../services/user_store.dart';
import '../models/user_settings.dart';
import '../theme/soundwave_theme.dart';

class PresentationBanner extends StatelessWidget {
  const PresentationBanner({
    super.key,
    required this.store,
    required this.clock,
  });
  final UserStore store;
  final DemoClock clock;
  @override
  Widget build(BuildContext context) {
    if (!store.state.demoClock.enabled) return const SizedBox.shrink();
    final time = clock.effectiveTime;
    final hour =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text(
            'Apresentação · $hour · ${store.state.periods.periodAt(time).label}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: SoundWaveColors.cyan, fontSize: 12),
          ),
          TextButton(
            onPressed: () => store.updateDemoClock(
              DemoClockSettings(
                enabled: false,
                minuteOfDay: store.state.demoClock.minuteOfDay,
              ),
            ),
            child: const Text(
              'Usar horário real',
              maxLines: 1,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
