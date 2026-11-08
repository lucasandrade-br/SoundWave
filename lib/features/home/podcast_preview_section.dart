import 'package:flutter/material.dart';
import '../../core/theme/soundwave_theme.dart';
import '../../core/widgets/catalog_widgets.dart';

/// Prévia visual autorizada: nenhum episódio é adicionado ao catálogo/player.
class PodcastPreviewSection extends StatelessWidget {
  const PodcastPreviewSection({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SectionHeading(title: 'PODCASTS'),
      const Text(
        'Conversas para o seu momento',
        style: TextStyle(color: SoundWaveColors.secondary),
      ),
      const SizedBox(height: 14),
      LayoutBuilder(
        builder: (context, constraints) {
          final single =
              constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (title, subtitle, icon, color) in [
                (
                  'Mente em foco',
                  'Ideias e criatividade',
                  Icons.mic_rounded,
                  SoundWaveColors.purple,
                ),
                (
                  'Além da rotina',
                  'Histórias para acompanhar',
                  Icons.headphones_rounded,
                  SoundWaveColors.cyan,
                ),
              ])
                SizedBox(
                  width: single
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 12) / 2,
                  child: SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 104,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              SoundWaveRadii.control,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withValues(alpha: .22),
                                SoundWaveColors.elevated,
                              ],
                            ),
                          ),
                          child: Icon(icon, size: 42, color: color),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: SoundWaveColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Em breve',
                          style: TextStyle(
                            color: SoundWaveColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}
