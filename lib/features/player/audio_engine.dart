import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import '../../core/models/catalog_models.dart';

enum AudioEventType { position, duration, completed, paused, error }

class AudioEngineEvent {
  const AudioEngineEvent(this.generation, this.type, {this.time, this.error});
  final int generation;
  final AudioEventType type;
  final Duration? time;
  final Object? error;
}

abstract interface class AudioEngine {
  Stream<AudioEngineEvent> get events;
  Future<Duration?> load(Track track, int generation);
  Future<void> resume();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> stop();
  Future<void> dispose();
}

/// Uma única instância nativa; nenhuma página cria AudioPlayer.
class AssetAudioEngine implements AudioEngine {
  AudioPlayer? _instance;
  AudioPlayer get _player => _instance ??= AudioPlayer();
  final _events = StreamController<AudioEngineEvent>.broadcast(sync: true);
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _disposed = false;

  @override
  Stream<AudioEngineEvent> get events => _events.stream;

  @override
  Future<Duration?> load(Track track, int generation) async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setSource(
      AssetSource(track.assetPath.substring('assets/'.length)),
    );
    if (_disposed) return null;
    void emit(AudioEventType type, {Duration? time, Object? error}) {
      if (!_disposed) {
        _events.add(
          AudioEngineEvent(generation, type, time: time, error: error),
        );
      }
    }

    void onError(Object error) => emit(AudioEventType.error, error: error);
    _subscriptions.addAll([
      _player.onPositionChanged.listen(
        (p) => emit(AudioEventType.position, time: p),
        onError: onError,
      ),
      _player.onDurationChanged.listen(
        (d) => emit(AudioEventType.duration, time: d),
        onError: onError,
      ),
      _player.onPlayerComplete.listen(
        (_) => emit(AudioEventType.completed),
        onError: onError,
      ),
      _player.onPlayerStateChanged.listen((s) {
        if (s == PlayerState.paused) emit(AudioEventType.paused);
      }, onError: onError),
    ]);
    return _player.getDuration();
  }

  @override
  Future<void> resume() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> stop() => _instance?.stop() ?? Future.value();
  @override
  Future<void> dispose() async {
    _disposed = true;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _instance?.dispose();
    await _events.close();
  }
}
