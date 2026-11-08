import 'dart:async';
import 'package:flutter/material.dart';
import '../core/models/catalog_models.dart';
import '../core/models/listening_context.dart';
import '../features/collection/collection_page.dart';
import '../features/home/home_page.dart';
import '../features/library/library_page.dart';
import '../features/library/library_catalog.dart';
import '../features/player/player_page.dart';
import '../features/profile/profile_page.dart';
import '../features/search/search_page.dart';
import 'app_bootstrap.dart';
import 'app_frame.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.services});
  final AppBootstrap services;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _searchController = TextEditingController();
  late final Timer _clockTick;
  int _tab = 0;
  ListeningContext? _searchContext;
  LibraryFilter _libraryFilter = LibraryFilter.all;
  late int _resetVersion;
  @override
  void initState() {
    super.initState();
    _resetVersion = widget.services.userStore.resetVersion;
    widget.services.userStore.addListener(_onStoreChanged);
    _clockTick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    widget.services.userStore.removeListener(_onStoreChanged);
    _clockTick.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    final nextVersion = widget.services.userStore.resetVersion;
    if (nextVersion == _resetVersion) return;
    _resetVersion = nextVersion;
    _searchController.clear();
    setState(() {
      _searchContext = null;
      _libraryFilter = LibraryFilter.all;
    });
  }

  void _selectTab(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _tab = value);
  }

  void _openCollection(MusicCollection collection) {
    FocusManager.instance.primaryFocus?.unfocus();
    final indicator = _tab == 0 ? 0 : 2;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => AppFrame(
          services: widget.services,
          selectedTab: indicator,
          onTab: (value) {
            Navigator.of(routeContext).pop();
            _selectTab(value);
          },
          body: CollectionPage(
            services: widget.services,
            collection: collection,
            onBack: () => Navigator.of(routeContext).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.services;
    final user = services.userStore.state;
    return AppFrame(
      services: services,
      selectedTab: _tab,
      onTab: _selectTab,
      body: IndexedStack(
        index: _tab,
        children: [
          HomePage(
            catalog: services.catalog,
            userState: user,
            effectiveTime: services.clock.effectiveTime,
            realTime: services.clock.realTime,
            onOpenCollection: _openCollection,
            onPlayContext: (collection) => services.playback.playTracks(
              services.catalog.tracksFor(collection),
              context: collection.context,
            ),
            onOpenTrack: (track) {
              services.playback.playTracks([track]);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PlayerPage(services: services),
                ),
              );
            },
            onSearchTag: (tag) {
              _searchContext = null;
              _searchController.text = tag;
              _selectTab(1);
            },
            onLibrary: () {
              _libraryFilter = LibraryFilter.all;
              _selectTab(2);
            },
            onAllCollections: () {
              _libraryFilter = LibraryFilter.collections;
              _selectTab(2);
            },
          ),
          SearchPage(
            controller: _searchController,
            catalog: services.catalog,
            store: services.userStore,
            contextFilter: _searchContext,
            onContextChanged: (value) => setState(() => _searchContext = value),
            onOpenCollection: _openCollection,
            onPlayTracks: (tracks, index) =>
                services.playback.playTracks(tracks, startIndex: index),
            onAddTrack: (track) => services.playback.addTracks([track]),
          ),
          LibraryPage(
            catalog: services.catalog,
            store: services.userStore,
            filter: _libraryFilter,
            onFilterChanged: (value) => setState(() => _libraryFilter = value),
            onOpenCollection: _openCollection,
            onPlayTracks: (tracks, index) =>
                services.playback.playTracks(tracks, startIndex: index),
            onAddTrack: (track) => services.playback.addTracks([track]),
            onOpenFavorites: () => _openCollection(
              MusicCollection(
                id: 'liked_tracks',
                title: 'Músicas curtidas',
                description: 'Suas faixas favoritas em uma seleção.',
                type: CollectionType.group,
                trackIds: user.favoriteTrackIds,
              ),
            ),
          ),
          ProfilePage(services: services),
        ],
      ),
    );
  }
}
