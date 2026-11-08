import 'package:flutter/material.dart';

import '../models/catalog_models.dart';
import '../theme/soundwave_theme.dart';
import 'catalog_widgets.dart';

/// Prévia de catálogo da E02; não seleciona música nem modifica a futura fila.
Future<void> showCatalogPreview(
  BuildContext context, {
  required String title,
  required List<Track> tracks,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: .65,
    minChildSize: .35,
    maxChildSize: .95,
    expand: false,
    builder: (context, scrollController) => ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Fechar seleção',
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${tracks.length} faixas • Instrumentais de demonstração',
          style: const TextStyle(color: SoundWaveColors.secondary),
        ),
        const SizedBox(height: 16),
        const Text(
          'Reprodução em breve',
          style: TextStyle(color: SoundWaveColors.cyan),
        ),
        const SizedBox(height: 16),
        if (tracks.isEmpty) const Text('Nenhuma música nesta seleção ainda.'),
        for (final track in tracks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                MusicArtwork(contextType: track.contexts.first, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        track.artist,
                        style: const TextStyle(
                          color: SoundWaveColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  trackDuration(track.duration),
                  style: const TextStyle(color: SoundWaveColors.secondary),
                ),
              ],
            ),
          ),
      ],
    ),
  ),
);
