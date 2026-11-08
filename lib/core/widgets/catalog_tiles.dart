import 'package:flutter/material.dart';
import '../models/catalog_models.dart';
import '../theme/soundwave_theme.dart';
import 'catalog_widgets.dart';

class TrackCatalogTile extends StatelessWidget {
  const TrackCatalogTile({
    super.key,
    required this.track,
    required this.onTap,
    required this.favorite,
    required this.onFavorite,
    required this.onAdd,
  });
  final Track track;
  final VoidCallback onTap, onFavorite, onAdd;
  final bool favorite;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: SurfaceCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      onTap: onTap,
      child: Row(
        children: [
          MusicArtwork(contextType: track.contexts.first, size: 36),
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
                  '${track.artist} · ${trackDuration(track.duration)}',
                  style: const TextStyle(
                    color: SoundWaveColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Opções de ${track.title}',
            onSelected: (value) => value == 'favorite' ? onFavorite() : onAdd(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'favorite',
                child: Text(favorite ? 'Descurtir música' : 'Curtir música'),
              ),
              const PopupMenuItem(
                value: 'queue',
                child: Text('Adicionar à fila'),
              ),
            ],
            icon: Icon(
              favorite ? Icons.favorite_rounded : Icons.more_vert_rounded,
              color: favorite
                  ? SoundWaveColors.purple
                  : SoundWaveColors.secondary,
            ),
          ),
        ],
      ),
    ),
  );
}

class CollectionCatalogTile extends StatelessWidget {
  const CollectionCatalogTile({
    super.key,
    required this.collection,
    required this.duration,
    required this.onTap,
    this.saved = false,
    this.onSave,
  });
  final MusicCollection collection;
  final Duration duration;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool saved;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          MusicArtwork(
            contextType: collection.context,
            size: 40,
            icon: collection.type == CollectionType.group
                ? Icons.person_rounded
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${collection.trackIds.length} faixas · ${compactDuration(duration)}',
                  style: const TextStyle(
                    color: SoundWaveColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onSave != null)
            IconButton(
              tooltip: saved
                  ? 'Remover ${collection.title} da biblioteca'
                  : 'Salvar ${collection.title} na biblioteca',
              onPressed: onSave,
              icon: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: saved
                    ? SoundWaveColors.purple
                    : SoundWaveColors.secondary,
              ),
            )
          else
            const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}
