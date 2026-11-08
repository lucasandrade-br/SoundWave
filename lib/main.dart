import 'package:flutter/widgets.dart';

import 'app/soundwave_app.dart';
import 'app/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppBootstrap.load();
  runApp(
    SoundWaveApp(
      services: services,
      phonePresentation: Uri.base.queryParameters['celular'] == '1',
    ),
  );
}
