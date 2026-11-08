import '../core/data/demo_catalog.dart';
import '../core/data/music_catalog.dart';
import '../core/services/demo_clock.dart';
import '../core/services/local_state_storage.dart';
import '../core/services/user_state_codec.dart';
import '../core/services/user_state_repository.dart';
import '../core/services/user_store.dart';
import '../features/player/audio_engine.dart';
import '../features/player/playback_controller.dart';

class AppBootstrap {
  AppBootstrap._(
    this.catalog,
    this.userStore,
    AudioEngine engine,
    DateTime Function()? now,
  ) : clock = DemoClock(settings: () => userStore.state.demoClock, now: now) {
    playback = PlaybackController(
      catalog: catalog,
      store: userStore,
      clock: clock,
      engine: engine,
    );
  }

  final MusicCatalog catalog;
  final UserStore userStore;
  final DemoClock clock;
  late final PlaybackController playback;

  static Future<AppBootstrap> load({
    MusicCatalog? catalog,
    LocalStateStorage? storage,
    AudioEngine? engine,
    DateTime Function()? now,
  }) async {
    final source = catalog ?? demoCatalog;
    final repository = UserStateRepository(
      storage: storage ?? PreferencesStateStorage(),
      codec: UserStateCodec(source),
    );
    final store = await UserStore.load(repository: repository, catalog: source);
    return AppBootstrap._(source, store, engine ?? AssetAudioEngine(), now);
  }

  void dispose() {
    playback.dispose();
    userStore.dispose();
  }
}
