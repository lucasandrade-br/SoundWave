import '../../app/scrolling_page.dart';
import 'package:flutter/material.dart';
import '../../core/data/music_catalog.dart';
import '../../core/models/catalog_models.dart';
import '../../core/models/listening_context.dart';
import '../../core/services/search_text.dart';
import '../../core/services/user_store.dart';
import '../../core/theme/soundwave_theme.dart';
import '../../core/widgets/catalog_widgets.dart';
import '../../core/widgets/catalog_tiles.dart';
import 'catalog_search.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
    required this.controller,
    required this.catalog,
    required this.store,
    required this.contextFilter,
    required this.onContextChanged,
    required this.onOpenCollection,
    required this.onPlayTracks,
    required this.onAddTrack,
  });
  final TextEditingController controller;
  final MusicCatalog catalog;
  final UserStore store;
  final ListeningContext? contextFilter;
  final ValueChanged<ListeningContext?> onContextChanged;
  final ValueChanged<MusicCollection> onOpenCollection;
  final void Function(List<Track>, int) onPlayTracks;
  final ValueChanged<Track> onAddTrack;

  void _record() {
    store.recordSearch(controller.text);
  }

  void _clear() {
    controller.clear();
    onContextChanged(null);
  }

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<TextEditingValue>(
    valueListenable: controller,
    builder: (context, value, _) {
      final searching =
          normalizeSearchText(value.text).isNotEmpty || contextFilter != null;
      final results = searchCatalog(
        catalog,
        value.text,
        context: contextFilter,
      );
      final tags = catalog.tracks.expand((t) => t.tags).toSet().toList();
      return ScrollingPage(
        key: const PageStorageKey('search-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text('Explorar', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 20),
          TextField(
            key: const ValueKey('search-field'),
            controller: controller,
            maxLength: 200,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              _record();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              counterText: '',
              labelText: 'O que deseja pesquisar?',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar texto da busca',
                      onPressed: controller.clear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          if (contextFilter != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text('Contexto: ${contextFilter!.label}'),
                  onDeleted: () => onContextChanged(null),
                  deleteButtonTooltipMessage: 'Remover filtro de contexto',
                ),
              ),
            ),
          const SizedBox(height: 24),
          if (searching) ...[
            if (results.isEmpty)
              EmptyCatalogState(
                title: 'Nenhum resultado',
                message:
                    'Não encontramos músicas ou coleções para "${cleanSearchTerm(value.text)}" com os filtros atuais.',
                action: 'Limpar busca e filtros',
                onAction: _clear,
              )
            else ...[
              SectionHeading(title: 'MÚSICAS · ${results.tracks.length}'),
              if (results.tracks.isEmpty)
                const Text('Nenhuma música nesta busca.'),
              for (final (index, track) in results.tracks.indexed)
                TrackCatalogTile(
                  key: ValueKey('search-track-${track.id}'),
                  track: track,
                  onTap: () {
                    _record();
                    onPlayTracks(results.tracks, index);
                  },
                  favorite: store.state.favoriteTrackIds.contains(track.id),
                  onFavorite: () => store.setTrackFavorite(
                    track.id,
                    !store.state.favoriteTrackIds.contains(track.id),
                  ),
                  onAdd: () => onAddTrack(track),
                ),
              const SizedBox(height: 24),
              SectionHeading(title: 'COLEÇÕES · ${results.collections.length}'),
              if (results.collections.isEmpty)
                const Text('Nenhuma coleção nesta busca.'),
              for (final collection in results.collections)
                CollectionCatalogTile(
                  key: ValueKey('search-collection-${collection.id}'),
                  collection: collection,
                  duration: catalog.durationOf(collection),
                  onTap: () {
                    _record();
                    onOpenCollection(collection);
                  },
                  saved: store.state.savedCollectionIds.contains(collection.id),
                  onSave: () => store.setCollectionSaved(
                    collection.id,
                    !store.state.savedCollectionIds.contains(collection.id),
                  ),
                ),
            ],
          ] else ...[
            SectionHeading(
              title: 'BUSCAS RECENTES',
              action: store.state.recentSearches.isEmpty ? null : 'Limpar',
              onAction: store.state.recentSearches.isEmpty
                  ? null
                  : store.clearSearches,
            ),
            if (store.state.recentSearches.isEmpty)
              const Text(
                'Suas pesquisas aparecerão aqui.',
                style: TextStyle(color: SoundWaveColors.secondary),
              ),
            for (final term in store.state.recentSearches)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_rounded),
                title: Text(term),
                onTap: () => controller.text = term,
                trailing: IconButton(
                  tooltip: 'Remover busca $term',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => store.removeSearch(term),
                ),
              ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final tag in tags)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text('#$tag'),
                        onPressed: () => controller.text = tag,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionHeading(title: 'EXPLORE POR CONTEXTO'),
            LayoutBuilder(
              builder: (context, constraints) {
                final single =
                    constraints.maxWidth < 340 ||
                    MediaQuery.textScalerOf(context).scale(1) > 1.3;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final item in ListeningContext.values)
                      SizedBox(
                        width: single
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 12) / 2,
                        child: SurfaceCard(
                          onTap: () => onContextChanged(item),
                          child: Row(
                            children: [
                              MusicArtwork(contextType: item, size: 36),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
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
        ],
      );
    },
  );
}
