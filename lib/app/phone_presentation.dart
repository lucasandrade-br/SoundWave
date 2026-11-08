import 'package:flutter/material.dart';
import '../core/theme/soundwave_theme.dart';

/// Moldura de apresentação: mantém o Navigator inteiro em 390 × 844, incluindo
/// player, fila e diálogos. O FittedBox ajusta a escala ao monitor disponível.
class PhonePresentation extends StatelessWidget {
  const PhonePresentation({super.key, required this.child});
  final Widget child;
  static const viewport = Size(390, 844);
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF06070A),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'SoundWave · apresentação mobile',
            style: TextStyle(color: SoundWaveColors.secondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 414,
                  height: 868,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF13161C),
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: const Color(0xFF414650),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: SizedBox(
                          key: const ValueKey('phone-viewport'),
                          width: viewport.width,
                          height: viewport.height,
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              size: viewport,
                              padding: EdgeInsets.zero,
                              viewPadding: EdgeInsets.zero,
                              viewInsets: EdgeInsets.zero,
                              systemGestureInsets: EdgeInsets.zero,
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '390 × 844 · visualização no navegador',
            style: TextStyle(color: SoundWaveColors.secondary, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
