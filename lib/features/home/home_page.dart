import '../../app/scrolling_page.dart';
import 'package:flutter/material.dart' hide DayPeriod;

import '../../core/data/music_catalog.dart';
import '../../core/models/catalog_models.dart';
import '../../core/models/listening_context.dart';
import '../../core/models/user_state.dart';
import '../../core/theme/soundwave_theme.dart';
import '../../core/widgets/catalog_widgets.dart';
import 'context_recommendations.dart';
import 'podcast_preview_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.catalog,
    required this.userState,
    required this.effectiveTime,
    required this.realTime,
    required this.onOpenCollection,
    required this.onPlayContext,
    required this.onOpenTrack,
    required this.onSearchTag,
    required this.onLibrary,
    required this.onAllCollections,
  });

  final MusicCatalog catalog;
  final UserState userState;
  final DateTime effectiveTime;
  final DateTime realTime;
  final ValueChanged<MusicCollection> onOpenCollection;
  final ValueChanged<MusicCollection> onPlayContext;
  final ValueChanged<Track> onOpenTrack;
  final ValueChanged<String> onSearchTag;
  final VoidCallback onLibrary;
  final VoidCallback onAllCollections;

  @override
  Widget build(BuildContext context) {
    final period = userState.periods.periodAt(effectiveTime);
    final suggestions = recommendedContexts(userState, period);
    final greeting = switch (period) {
      DayPeriod.morning => 'Bom dia',
      DayPeriod.afternoon => 'Boa tarde',
      DayPeriod.night => 'Boa noite',
    };
    final firstName = userState.profile.name.split(RegExp(r'\s+')).first;
    const weekdays = [
      'SEGUNDA-FEIRA',
      'TERÇA-FEIRA',
      'QUARTA-FEIRA',
      'QUINTA-FEIRA',
      'SEXTA-FEIRA',
      'SÁBADO',
      'DOMINGO',
    ];
    final recentIds = userState.history
        .map((item) => item.trackId)
        .toSet()
        .take(4);
    final recentTracks = recentIds
        .map(catalog.trackById)
        .whereType<Track>()
        .toList();
    final jukebox = catalog.collections
        .where(
          (item) =>
              item.type == CollectionType.playlist ||
              item.type == CollectionType.album,
        )
        .toList();

    return ScrollingPage(
      key: const PageStorageKey('home-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              '$greeting, $firstName',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              weekdays[realTime.weekday - 1],
              style: const TextStyle(
                color: SoundWaveColors.secondary,
                fontSize: 11,
                letterSpacing: .7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const SectionHeading(
          title: 'O QUE VAMOS FAZER AGORA?',
          action: 'Sugeridos',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.3;
            final cards = [
              for (final suggestion in suggestions)
                _ContextCard(
                  contextType: suggestion,
                  collection: catalog.contextCollection(suggestion),
                  duration: catalog.durationOf(
                    catalog.contextCollection(suggestion),
                  ),
                  onTap: () =>
                      onOpenCollection(catalog.contextCollection(suggestion)),
                  onPlay: () =>
                      onPlayContext(catalog.contextCollection(suggestion)),
                ),
            ];
            if (stacked) {
              return Column(
                children: [cards.first, const SizedBox(height: 12), cards.last],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards.first),
                const SizedBox(width: 12),
                Expanded(child: cards.last),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final tag in const ['Café', 'Lo-Fi', 'Foco', 'Calma'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () => onSearchTag(tag),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: SoundWaveColors.surface,
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SoundWaveRadii.control,
                        ),
                      ),
                    ),
                    child: Text(tag),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const SectionHeading(title: 'ÚLTIMAS TOCADAS', action: 'Recentes'),
        if (recentTracks.isEmpty)
          EmptyCatalogState(
            title: 'Sua trilha começa aqui',
            message: 'As músicas que você ouvir aparecerão neste espaço.',
            action: 'Explorar biblioteca',
            onAction: onLibrary,
          )
        else
          SizedBox(
            height: 60 + MediaQuery.textScalerOf(context).scale(32),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recentTracks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final track = recentTracks[index];
                return SizedBox(
                  width: 260,
                  child: SurfaceCard(
                    onTap: () => onOpenTrack(track),
                    child: Row(
                      children: [
                        MusicArtwork(
                          contextType: track.contexts.first,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                track.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: SoundWaveColors.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 28),
        SectionHeading(
          title: 'JUKEBOX DIGITAL',
          action: 'Ver tudo',
          onAction: onAllCollections,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = MediaQuery.textScalerOf(context).scale(1) > 1.3
                ? 1
                : 2;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final collection in jukebox)
                  SizedBox(
                    width: width,
                    child: CollectionCard(
                      collection: collection,
                      duration: catalog.durationOf(collection),
                      onTap: () => onOpenCollection(collection),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const PodcastPreviewSection(),
        const SizedBox(height: 24),
        Text(
          '${catalog.tracks.length} instrumentais locais · SoundWave Demo',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: SoundWaveColors.secondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.contextType,
    required this.collection,
    required this.duration,
    required this.onTap,
    required this.onPlay,
  });
  final ListeningContext contextType;
  final MusicCollection collection;
  final Duration duration;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Ver seleção ${contextType.label}',
    child: SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  contextType.caption,
                  style: const TextStyle(
                    color: SoundWaveColors.secondary,
                    fontSize: 11,
                    letterSpacing: .6,
                  ),
                ),
              ),
              Icon(
                contextType.icon,
                color: SoundWaveColors.secondary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 36),
          Text(
            contextType.label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${collection.trackIds.length} faixas · ${compactDuration(duration)}',
            style: const TextStyle(
              color: SoundWaveColors.secondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ver seleção',
                  style: TextStyle(
                    color: SoundWaveColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton.filled(
                tooltip: 'Tocar ${contextType.label}',
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow_rounded),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.collection,
    required this.duration,
    required this.onTap,
  });
  final MusicCollection collection;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    onTap: onTap,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              collection.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '${collection.trackIds.length} faixas · ${compactDuration(duration)}',
              style: const TextStyle(
                color: SoundWaveColors.secondary,
                fontSize: 12,
              ),
            ),
          ],
        );
        if (constraints.maxWidth < 200) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MusicArtwork(size: 36),
              const SizedBox(height: 14),
              text,
            ],
          );
        }
        return Row(
          children: [
            const MusicArtwork(size: 40),
            const SizedBox(width: 12),
            Expanded(child: text),
          ],
        );
      },
    ),
  );
}
