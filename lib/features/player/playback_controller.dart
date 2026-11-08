import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import '../../core/data/music_catalog.dart';
import '../../core/models/catalog_models.dart';
import '../../core/models/listening_context.dart';
import '../../core/models/playback_snapshot.dart';
import '../../core/models/user_state.dart';
import '../../core/services/demo_clock.dart';
import '../../core/services/user_store.dart';
import 'audio_engine.dart';

enum PlaybackStatus { idle, loading, playing, paused, completed, error }

class PlaybackController extends ChangeNotifier {
  PlaybackController({
    required this.catalog,
    required this.store,
    required this.clock,
    required AudioEngine engine,
    Random? random,
  }) : _engine = engine,
       _random = random ?? Random() {
    final saved = store.state.playback;
    _entries = [...saved.entries];
    _currentId = saved.currentEntryId;
    _position = saved.position;
    _repeat = saved.repeatMode;
    _shuffle = saved.shuffleEnabled;
    _baseUpcoming = [...saved.baseUpcomingEntryIds];
    _duration = currentTrack?.duration ?? Duration.zero;
    _status = currentTrack == null
        ? PlaybackStatus.idle
        : PlaybackStatus.paused;
    _subscription = _engine.events.listen(_onEvent);
  }

  final MusicCatalog catalog;
  final UserStore store;
  final DemoClock clock;
  final AudioEngine _engine;
  final Random _random;
  late final StreamSubscription<AudioEngineEvent> _subscription;
  final String _prefix = DateTime.now().microsecondsSinceEpoch.toString();
  int _sequence = 0;
  int _generation = 0;
  int? _recordedGeneration;
  bool _disposed = false;
  bool _prepared = false;
  bool _wantsPlay = false;
  List<QueueEntry> _entries = [];
  String? _currentId;
  List<String> _baseUpcoming = [];
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _lastPersisted = Duration.zero;
  PlaybackRepeatMode _repeat = PlaybackRepeatMode.off;
  bool _shuffle = false;
  PlaybackStatus _status = PlaybackStatus.idle;
  String? _error;
  ListeningContext? _context;
  bool _contextCounted = false;
  bool _resetting = false;
  Future<void> _commands = Future.value();

  List<QueueEntry> get entries => List.unmodifiable(_entries);
  int get currentIndex => _entries.indexWhere((e) => e.entryId == _currentId);
  QueueEntry? get currentEntry =>
      currentIndex < 0 ? null : _entries[currentIndex];
  Track? get currentTrack =>
      currentEntry == null ? null : catalog.trackById(currentEntry!.trackId);
  List<QueueEntry> get upcoming => currentIndex < 0
      ? const []
      : List.unmodifiable(_entries.skip(currentIndex + 1));
  Duration get position => _position;
  Duration get duration => _duration;
  PlaybackStatus get status => _status;
  String? get error => _error;
  bool get isPlaying => _status == PlaybackStatus.playing;
  bool get busy => _status == PlaybackStatus.loading;
  bool get resetting => _resetting;
  bool get shuffleEnabled => _shuffle;
  PlaybackRepeatMode get repeatMode => _repeat;
  bool get canNext =>
      upcoming.isNotEmpty ||
      (_repeat == PlaybackRepeatMode.all && _entries.isNotEmpty);
  int get generation => _generation;
  Future<void> get settled => _commands;

  String _id(String type) => '${type}_${_prefix}_${_sequence++}';
  bool _valid(int generation) => !_disposed && generation == _generation;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _enqueue(int generation, Future<void> Function() action) {
    final operation = _commands.then((_) async {
      if (!_valid(generation)) return;
      try {
        await action();
      } catch (_) {
        if (_valid(generation)) {
          _wantsPlay = false;
          _status = PlaybackStatus.error;
          _error =
              'Não foi possível reproduzir esta faixa. Tente novamente ou avance.';
          _notify();
          _persist();
        }
      }
    });
    _commands = operation;
    return operation;
  }

  Future<void> playTracks(
    List<Track> tracks, {
    int startIndex = 0,
    ListeningContext? context,
    bool shuffled = false,
  }) {
    if (_resetting) return Future.value();
    if (tracks.isEmpty) return Future.value();
    if (startIndex < 0 ||
        startIndex >= tracks.length ||
        tracks.any((track) => catalog.trackById(track.id) == null)) {
      throw ArgumentError('Seleção de faixas inválida.');
    }
    final ordered = [...tracks];
    if (shuffled) ordered.shuffle(_random);
    _entries = ordered
        .map((track) => QueueEntry(entryId: _id('q'), trackId: track.id))
        .toList();
    _context = context;
    _contextCounted = false;
    if (shuffled) _shuffle = true;
    final selected = shuffled ? 0 : startIndex;
    _currentId = _entries[selected].entryId;
    _baseUpcoming = _entries.skip(selected + 1).map((e) => e.entryId).toList();
    if (_shuffle) _shuffleUpcoming();
    return _activate(_currentId!, autoplay: true);
  }

  Future<void> _activate(
    String entryId, {
    required bool autoplay,
    Duration position = Duration.zero,
  }) {
    if (_resetting) return Future.value();
    if (!_entries.any((e) => e.entryId == entryId)) return Future.value();
    final token = ++_generation;
    _currentId = entryId;
    _position = position;
    _lastPersisted = position;
    _duration = currentTrack!.duration;
    _prepared = false;
    _wantsPlay = autoplay;
    _recordedGeneration = null;
    _error = null;
    _status = PlaybackStatus.loading;
    _syncBase();
    _notify();
    _persist();
    final track = currentTrack!;
    return _enqueue(token, () async {
      final measured = await _engine.load(track, token);
      if (!_valid(token)) return;
      if (measured != null && measured > Duration.zero) _duration = measured;
      final safePosition = Duration(
        milliseconds: position.inMilliseconds.clamp(
          0,
          _duration.inMilliseconds,
        ),
      );
      await _engine.seek(safePosition);
      if (!_valid(token)) return;
      _position = safePosition;
      _prepared = true;
      if (_wantsPlay) {
        await _engine.resume();
        if (!_valid(token)) return;
        _status = PlaybackStatus.playing;
        _recordStart(token);
      } else {
        _status = PlaybackStatus.paused;
      }
      _notify();
      _persist();
    });
  }

  void _recordStart(int token) {
    if (_recordedGeneration == token || !_valid(token)) return;
    _recordedGeneration = token;
    final effective = clock.effectiveTime;
    final countContext = _context != null && !_contextCounted;
    if (countContext) _contextCounted = true;
    unawaited(
      store.recordPlayback(
        PlaybackHistoryEntry(
          id: _id('h'),
          trackId: currentTrack!.id,
          realTime: clock.realTime,
          effectiveTime: effective,
          period: store.state.periods.periodAt(effective),
          context: _context,
        ),
        countContext: countContext,
      ),
    );
  }

  Future<void> togglePlay() async {
    if (_resetting) return;
    if (currentTrack == null || busy) return;
    if (isPlaying) {
      await pause();
      return;
    }
    if (!_prepared ||
        _status == PlaybackStatus.error ||
        _status == PlaybackStatus.completed) {
      await _activate(
        _currentId!,
        autoplay: true,
        position: _status == PlaybackStatus.completed
            ? Duration.zero
            : _position,
      );
      return;
    }
    final token = _generation;
    _wantsPlay = true;
    await _enqueue(token, () async {
      await _engine.resume();
      if (!_valid(token)) return;
      _status = PlaybackStatus.playing;
      _recordStart(token);
      _notify();
      _persist();
    });
  }

  Future<void> pause() {
    if (_resetting) return Future.value();
    _wantsPlay = false;
    final token = _generation;
    return _enqueue(token, () async {
      if (_prepared) await _engine.pause();
      if (!_valid(token)) return;
      _status = currentTrack == null
          ? PlaybackStatus.idle
          : PlaybackStatus.paused;
      _notify();
      _persist();
    });
  }

  Future<void> seek(Duration value) {
    if (_resetting) return Future.value();
    if (!_prepared || busy) return Future.value();
    final token = _generation;
    final target = Duration(
      milliseconds: value.inMilliseconds.clamp(0, _duration.inMilliseconds),
    );
    return _enqueue(token, () async {
      await _engine.seek(target);
      if (!_valid(token)) return;
      _position = target;
      if (_status == PlaybackStatus.completed) _status = PlaybackStatus.paused;
      _notify();
      _persist();
    });
  }

  Future<void> next() {
    if (!canNext) return Future.value();
    final index = currentIndex + 1 < _entries.length ? currentIndex + 1 : 0;
    return _activate(_entries[index].entryId, autoplay: true);
  }

  Future<void> previous() {
    if (currentTrack == null) return Future.value();
    if (_position >= const Duration(seconds: 3) || currentIndex == 0) {
      if (!_prepared) return _activate(_currentId!, autoplay: false);
      return seek(Duration.zero);
    }
    return _activate(_entries[currentIndex - 1].entryId, autoplay: true);
  }

  Future<void> playEntry(String entryId) => _activate(entryId, autoplay: true);

  void addTracks(Iterable<Track> tracks) {
    if (_resetting) return;
    final additions = tracks.map((track) {
      if (catalog.trackById(track.id) == null) {
        throw ArgumentError.value(track.id);
      }
      return QueueEntry(entryId: _id('q'), trackId: track.id);
    }).toList();
    if (additions.isEmpty) return;
    _entries.addAll(additions);
    if (_currentId == null) {
      _currentId = _entries.first.entryId;
      _duration = currentTrack!.duration;
      _status = PlaybackStatus.paused;
      _context = null;
    }
    _syncBase();
    _notify();
    _persist();
  }

  void removeUpcoming(String entryId) {
    if (_resetting) return;
    if (!upcoming.any((e) => e.entryId == entryId)) return;
    _entries.removeWhere((e) => e.entryId == entryId);
    _baseUpcoming.remove(entryId);
    _notify();
    _persist();
  }

  void reorderUpcoming(int oldIndex, int newIndex) {
    if (_resetting) return;
    final future = [...upcoming];
    if (oldIndex < 0 ||
        oldIndex >= future.length ||
        newIndex < 0 ||
        newIndex > future.length) {
      return;
    }
    if (newIndex > oldIndex) newIndex--;
    future.insert(newIndex, future.removeAt(oldIndex));
    _entries = [..._entries.take(currentIndex + 1), ...future];
    _baseUpcoming = future.map((e) => e.entryId).toList();
    _notify();
    _persist();
  }

  void toggleShuffle() {
    if (_resetting) return;
    _shuffle = !_shuffle;
    if (_shuffle) {
      _baseUpcoming = upcoming.map((e) => e.entryId).toList();
      _shuffleUpcoming();
    } else {
      final future = {for (final e in upcoming) e.entryId: e};
      _entries = [
        ..._entries.take(currentIndex + 1),
        ..._baseUpcoming.where(future.containsKey).map((id) => future[id]!),
      ];
    }
    _notify();
    _persist();
  }

  void _shuffleUpcoming() {
    final future = [...upcoming]..shuffle(_random);
    _entries = [..._entries.take(currentIndex + 1), ...future];
  }

  void _syncBase() {
    final future = upcoming.map((e) => e.entryId).toSet();
    _baseUpcoming.removeWhere((id) => !future.contains(id));
    _baseUpcoming.addAll(future.where((id) => !_baseUpcoming.contains(id)));
  }

  void cycleRepeat() {
    if (_resetting) return;
    _repeat = PlaybackRepeatMode
        .values[(_repeat.index + 1) % PlaybackRepeatMode.values.length];
    _notify();
    _persist();
  }

  Future<void> stop() {
    if (_resetting) return Future.value();
    final token = ++_generation;
    _wantsPlay = false;
    _prepared = false;
    _position = Duration.zero;
    _status = currentTrack == null
        ? PlaybackStatus.idle
        : PlaybackStatus.paused;
    _notify();
    _persist();
    return _enqueue(token, _engine.stop);
  }

  /// A interface pede confirmação antes de chamar. Não persiste a fila vazia
  /// após clear, para que restaurar remova somente a chave do SoundWave.
  Future<bool> restoreDemo() async {
    if (_resetting) return false;
    _resetting = true;
    final token = ++_generation;
    _wantsPlay = false;
    _prepared = false;
    _status = PlaybackStatus.loading;
    _notify();
    var stopped = false;
    try {
      await _enqueue(token, () async {
        await _engine.stop();
        if (!_valid(token)) return;
        _entries = [];
        _currentId = null;
        _baseUpcoming = [];
        _position = Duration.zero;
        _lastPersisted = Duration.zero;
        _duration = Duration.zero;
        _repeat = PlaybackRepeatMode.off;
        _shuffle = false;
        _context = null;
        _contextCounted = false;
        _recordedGeneration = null;
        _error = null;
        _status = PlaybackStatus.idle;
        stopped = true;
        _notify();
      });
      if (!stopped) return false;
      return await store.restoreDefaults();
    } finally {
      _resetting = false;
      _notify();
    }
  }

  void _onEvent(AudioEngineEvent event) {
    if (!_valid(event.generation) || !_prepared || busy) return;
    switch (event.type) {
      case AudioEventType.position:
        if (_status != PlaybackStatus.playing) return;
        _position = Duration(
          milliseconds: event.time!.inMilliseconds.clamp(
            0,
            _duration.inMilliseconds,
          ),
        );
        _notify();
        if ((_position - _lastPersisted).abs() >= const Duration(seconds: 5)) {
          _persist();
        }
      case AudioEventType.duration:
        if (event.time! > Duration.zero) _duration = event.time!;
        _notify();
      case AudioEventType.paused:
        if (_status == PlaybackStatus.playing) {
          _status = PlaybackStatus.paused;
          _notify();
          _persist();
        }
      case AudioEventType.error:
        _wantsPlay = false;
        _status = PlaybackStatus.error;
        _error = 'O áudio foi interrompido. Tente novamente ou avance.';
        _notify();
        _persist();
      case AudioEventType.completed:
        if (_status != PlaybackStatus.playing) return;
        _position = _duration;
        _status = PlaybackStatus.completed;
        _notify();
        _persist();
        if (_repeat == PlaybackRepeatMode.one) {
          unawaited(_activate(_currentId!, autoplay: true));
        } else if (canNext) {
          unawaited(next());
        }
    }
  }

  void _persist() {
    if (_disposed) return;
    _lastPersisted = _position;
    unawaited(flush());
  }

  Future<bool> flush() => store.updatePlaybackSnapshot(
    PlaybackSnapshot(
      entries: _entries,
      currentEntryId: _currentId,
      position: _position,
      repeatMode: _repeat,
      shuffleEnabled: _shuffle,
      baseUpcomingEntryIds: _baseUpcoming,
    ),
  );

  @override
  void dispose() {
    if (currentTrack != null) _persist();
    _disposed = true;
    _generation++;
    unawaited(_subscription.cancel());
    unawaited(_commands.then((_) => _engine.dispose()));
    super.dispose();
  }
}
