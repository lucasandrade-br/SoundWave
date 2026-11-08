import 'package:flutter/material.dart';

import '../models/listening_context.dart';
import '../theme/soundwave_theme.dart';

String compactDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  if (minutes == 0) return '${seconds}s';
  return seconds == 0
      ? '${minutes}min'
      : '${minutes}min${seconds.toString().padLeft(2, '0')}';
}

String trackDuration(Duration duration) =>
    '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

extension ContextAppearance on ListeningContext {
  IconData get icon => switch (this) {
    ListeningContext.study => Icons.menu_book_outlined,
    ListeningContext.workout => Icons.bolt_outlined,
    ListeningContext.work => Icons.laptop_mac_outlined,
    ListeningContext.travel => Icons.explore_outlined,
    ListeningContext.reading => Icons.auto_stories_outlined,
    ListeningContext.sleep => Icons.bedtime_outlined,
  };

  String get caption => switch (this) {
    ListeningContext.study => 'FOCO',
    ListeningContext.workout => 'RITMO',
    ListeningContext.work => 'FLUXO',
    ListeningContext.travel => 'CAMINHO',
    ListeningContext.reading => 'PAUSA',
    ListeningContext.sleep => 'DESCANSO',
  };
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Material(
    color: SoundWaveColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SoundWaveRadii.card),
      side: const BorderSide(color: SoundWaveColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class MusicArtwork extends StatelessWidget {
  const MusicArtwork({super.key, this.contextType, this.size = 48, this.icon});
  final ListeningContext? contextType;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = contextType?.index.isOdd == true
        ? SoundWaveColors.purple
        : SoundWaveColors.cyan;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            size < 80 ? SoundWaveRadii.control : SoundWaveRadii.artwork,
          ),
          border: Border.all(color: SoundWaveColors.border),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withValues(alpha: .12), SoundWaveColors.elevated],
          ),
        ),
        child: Icon(
          icon ?? contextType?.icon ?? Icons.music_note_rounded,
          size: size * .48,
          color: SoundWaveColors.secondary,
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: SoundWaveColors.secondary,
              fontSize: 12,
              letterSpacing: .9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (action != null)
          onAction == null
              ? Text(
                  action!,
                  style: const TextStyle(
                    color: SoundWaveColors.secondary,
                    fontSize: 12,
                  ),
                )
              : TextButton(onPressed: onAction, child: Text(action!)),
      ],
    ),
  );
}

class EmptyCatalogState extends StatelessWidget {
  const EmptyCatalogState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.headphones_outlined, color: SoundWaveColors.secondary),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(message, style: const TextStyle(color: SoundWaveColors.secondary)),
        if (onAction != null) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ],
    ),
  );
}
