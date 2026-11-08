import 'package:flutter/foundation.dart';

import '../data/music_catalog.dart';
import '../models/playback_snapshot.dart';
import '../models/user_settings.dart';
import '../models/user_state.dart';
import 'user_state_repository.dart';
import 'search_text.dart';

class UserStore extends ChangeNotifier {
  UserStore._(this._repository, this.catalog, LoadedUserState loaded)
    : _state = loaded.state,
      _warning = loaded.warning;

  static Future<UserStore> load({
    required UserStateRepository repository,
    required MusicCatalog catalog,
  }) async => UserStore._(repository, catalog, await repository.load());

  final UserStateRepository _repository;
  final MusicCatalog catalog;
  UserState _state;
  String? _warning;
  bool _disposed = false;
  int _resetVersion = 0;

  UserState get state => _state;
  String? get warning => _warning;
  int get resetVersion => _resetVersion;

  Future<bool> updateProfile(UserProfile profile) =>
      _commit(_state.copyWith(profile: profile));

  Future<bool> updatePeriods(PeriodSettings periods) =>
      _commit(_state.copyWith(periods: periods));

  Future<bool> updateDemoClock(DemoClockSettings settings) =>
      _commit(_state.copyWith(demoClock: settings));

  Future<bool> setTrackFavorite(String trackId, bool favorite) {
    if (catalog.trackById(trackId) == null) throw ArgumentError.value(trackId);
    final ids = {..._state.favoriteTrackIds};
    favorite ? ids.add(trackId) : ids.remove(trackId);
    return _commit(_state.copyWith(favoriteTrackIds: ids));
  }

  Future<bool> setCollectionSaved(String collectionId, bool saved) {
    if (catalog.collectionById(collectionId) == null) {
      throw ArgumentError.value(collectionId);
    }
    final ids = {..._state.savedCollectionIds};
    saved ? ids.add(collectionId) : ids.remove(collectionId);
    return _commit(_state.copyWith(savedCollectionIds: ids));
  }

  Future<bool> updatePlaybackSnapshot(PlaybackSnapshot snapshot) =>
      _commit(_state.copyWith(playback: snapshot));

  Future<bool> recordSearch(String value) {
    final cleaned = cleanSearchTerm(value);
    final term = cleaned.length > 200 ? cleaned.substring(0, 200) : cleaned;
    if (term.isEmpty) return Future.value(true);
    final key = normalizeSearchText(term);
    return _commit(
      _state.copyWith(
        recentSearches: [
          term,
          ..._state.recentSearches.where(
            (old) => normalizeSearchText(old) != key,
          ),
        ],
      ),
    );
  }

  Future<bool> removeSearch(String value) => _commit(
    _state.copyWith(
      recentSearches: _state.recentSearches.where(
        (term) => normalizeSearchText(term) != normalizeSearchText(value),
      ),
    ),
  );

  Future<bool> clearSearches() =>
      _commit(_state.copyWith(recentSearches: const []));

  Future<bool> recordPlayback(
    PlaybackHistoryEntry entry, {
    bool countContext = false,
  }) {
    if (catalog.trackById(entry.trackId) == null) {
      throw ArgumentError.value(entry.trackId);
    }
    if (_state.history.any((item) => item.id == entry.id)) {
      return Future.value(true);
    }
    final counts = {..._state.contextCounts};
    if (countContext) {
      if (entry.context == null) throw ArgumentError('Contexto ausente.');
      final key = '${entry.period.id}:${entry.context!.id}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return _commit(
      _state.copyWith(
        history: [entry, ..._state.history],
        contextCounts: counts,
      ),
    );
  }

  Future<bool> _commit(UserState next) async {
    if (_disposed) throw StateError('UserStore já foi encerrado.');
    _state = next;
    notifyListeners();
    return _reportPersistence(() => _repository.save(next));
  }

  /// Chamar após confirmação e parada do player em PlaybackController.restoreDemo.
  Future<bool> restoreDefaults() async {
    if (_disposed) throw StateError('UserStore já foi encerrado.');
    _state = UserState();
    _resetVersion++;
    notifyListeners();
    return _reportPersistence(_repository.clear);
  }

  Future<bool> _reportPersistence(Future<void> Function() operation) async {
    try {
      await operation();
      _warning = null;
      if (!_disposed) notifyListeners();
      return true;
    } catch (_) {
      _warning =
          'Não foi possível salvar. Suas mudanças continuam apenas nesta sessão.';
      if (!_disposed) notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
