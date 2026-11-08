import 'package:flutter/material.dart';

import '../theme/soundwave_theme.dart';

class SoundWaveHeader extends StatelessWidget {
  const SoundWaveHeader({super.key, required this.onProfile});
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: SoundWaveColors.surface,
            borderRadius: BorderRadius.circular(SoundWaveRadii.control),
            border: Border.all(color: SoundWaveColors.border),
          ),
          child: const Icon(Icons.music_note_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'SoundWave',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          tooltip: 'Abrir perfil',
          onPressed: onProfile,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SoundWaveRadii.control),
            ),
          ),
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ],
    ),
  );
}
