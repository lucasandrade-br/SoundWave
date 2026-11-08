// Ferramenta de desenvolvimento, fora do ponto de entrada do produto.
// Servir em porta própria (8081), nunca na origem da apresentação (8080).
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;
import 'package:soundwave/app/app_bootstrap.dart';
import 'package:soundwave/core/models/user_settings.dart';
import 'package:soundwave/core/services/local_state_storage.dart';

void main() => runApp(const MaterialApp(home: _CheckPage()));

class _CheckPage extends StatefulWidget {
  const _CheckPage();

  @override
  State<_CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<_CheckPage> {
  static const _phaseKey = 'soundwave.e01.check.phase';
  static const _sentinelKey = 'soundwave.e01.check.sentinel';
  String _message = 'Preparando verificação...';
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final phase = await SharedPreferencesAsync().getString(_phaseKey);
      if (phase == 'reload') {
        await _verifyAfterReload();
      } else {
        setState(() {
          _message =
              'Verificação E01 em origem isolada.\n'
              'O botão salva perfil e favoritos de teste. Depois recarregue esta página.';
          _ready = true;
        });
      }
    } catch (error) {
      _showError(error);
    }
  }

  void _require(bool condition, String message) {
    if (!condition) throw StateError(message);
  }

  Future<void> _seed() async {
    setState(() => _ready = false);
    AppBootstrap? app;
    try {
      final preferences = SharedPreferencesAsync();
      _require(
        await preferences.getString(PreferencesStateStorage.key) == null,
        'A origem já contém dados. Use uma porta de diagnóstico nova.',
      );
      await preferences.setString(_sentinelKey, 'preservar');
      app = await AppBootstrap.load();
      _require(
        await app.userStore.updateProfile(
          UserProfile(name: 'Teste de Recarga E01'),
        ),
        'Perfil não salvo',
      );
      _require(
        await app.userStore.setTrackFavorite('aurora_lofi', true),
        'Favorito não salvo',
      );
      _require(
        await app.userStore.updateDemoClock(
          DemoClockSettings(enabled: true, minuteOfDay: 500),
        ),
        'Relógio não salvo',
      );
      await preferences.setString(_phaseKey, 'reload');
      setState(
        () => _message =
            'Dados de teste salvos. Recarregue esta página para conferir a persistência.',
      );
    } catch (error) {
      _showError(error);
    } finally {
      app?.dispose();
    }
  }

  Future<void> _verifyAfterReload() async {
    AppBootstrap? app;
    web.AudioContext? audio;
    try {
      app = await AppBootstrap.load();
      _require(
        app.userStore.state.profile.name == 'Teste de Recarga E01',
        'Perfil perdido após recarga',
      );
      _require(
        app.userStore.state.favoriteTrackIds.contains('aurora_lofi'),
        'Favorito perdido após recarga',
      );
      _require(
        app.userStore.state.demoClock.minuteOfDay == 500,
        'Relógio perdido após recarga',
      );
      _require(
        !app.userStore.state.playback.isPlaying,
        'Recuperação não pausada',
      );
      final count = app.catalog.tracks.length;
      _require(count == 12, 'Catálogo duplicado/incompleto');

      audio = web.AudioContext();
      for (final track in app.catalog.tracks) {
        final asset = await rootBundle.load(track.assetPath);
        final bytes = Uint8List.fromList(
          asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes),
        );
        final decoded = await audio.decodeAudioData(bytes.buffer.toJS).toDart;
        _require(
          (decoded.duration * 1000 - track.duration.inMilliseconds).abs() <= 1,
          'Duração incorreta: ${track.id}',
        );
        final samples = decoded.getChannelData(0).toDart;
        _require(
          samples.any((v) => v.abs() > 0.1) &&
              samples.every((v) => v.abs() < 0.99),
          'Sinal inválido: ${track.id}',
        );
      }
      _require(await app.userStore.restoreDefaults(), 'Falha na restauração');
      final prefs = SharedPreferencesAsync();
      _require(
        await prefs.getString(_sentinelKey) == 'preservar',
        'Chave alheia foi alterada',
      );
      _require(
        await prefs.getString(PreferencesStateStorage.key) == null,
        'Chave do app não removida',
      );
      await prefs.remove(_sentinelKey);
      await prefs.remove(_phaseKey);
      setState(
        () => _message =
            'Persistência após recarga: OK\n'
            'Perfil, favoritos e relógio recuperados: OK\n'
            'Catálogo único de 12 faixas: OK\n'
            '12 áudios decodificados com duração e sinal válidos: OK\n'
            'Limpeza restrita aos dados SoundWave: OK\n'
            'Dados de diagnóstico removidos.',
      );
    } catch (error) {
      _showError(error);
    } finally {
      await audio?.close().toDart;
      app?.dispose();
    }
  }

  void _showError(Object error) {
    if (mounted) setState(() => _message = 'Falha na verificação: $error');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verificação E01 — SoundWave')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_message, style: const TextStyle(fontSize: 18)),
          if (_ready) ...[
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _seed,
              child: const Text('Validar base E01'),
            ),
          ],
        ],
      ),
    ),
  );
}
