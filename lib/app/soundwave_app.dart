import 'package:flutter/material.dart';

import '../core/theme/soundwave_theme.dart';
import 'app_bootstrap.dart';
import 'app_shell.dart';
import 'phone_presentation.dart';

/// Composição de longa duração; as páginas compartilham os mesmos serviços.
class SoundWaveApp extends StatefulWidget {
  const SoundWaveApp({
    super.key,
    required this.services,
    this.phonePresentation = false,
  });

  final AppBootstrap services;
  final bool phonePresentation;

  @override
  State<SoundWaveApp> createState() => _SoundWaveAppState();
}

class _SoundWaveAppState extends State<SoundWaveApp> {
  @override
  void dispose() {
    widget.services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundWave',
      debugShowCheckedModeBanner: false,
      theme: buildSoundWaveTheme(),
      builder: (context, child) => widget.phonePresentation
          ? PhonePresentation(child: child ?? const SizedBox.shrink())
          : child ?? const SizedBox.shrink(),
      home: ListenableBuilder(
        listenable: widget.services.userStore,
        builder: (context, child) => AppShell(services: widget.services),
      ),
    );
  }
}
