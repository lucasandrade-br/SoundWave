import 'package:flutter/material.dart';
import '../../core/models/playback_snapshot.dart';
import '../../core/services/user_store.dart';
import '../../core/theme/soundwave_theme.dart';
import '../../core/widgets/catalog_widgets.dart';
import 'playback_controller.dart';

extension PlaybackLabel on PlaybackStatus {
  String get label => switch (this) {
    PlaybackStatus.idle => 'Sem seleção',
    PlaybackStatus.loading => 'Carregando',
    PlaybackStatus.playing => 'Reproduzindo',
    PlaybackStatus.paused => 'Pausado',
    PlaybackStatus.completed => 'Concluído',
    PlaybackStatus.error => 'Erro na reprodução',
  };
}

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, required this.player, this.large = false});
  final PlaybackController player;
  final bool large;
  @override
  Widget build(BuildContext context) => IconButton.filled(
    tooltip: player.isPlaying ? 'Pausar' : 'Reproduzir',
    onPressed: player.busy || player.currentTrack == null
        ? null
        : player.togglePlay,
    style: IconButton.styleFrom(
      minimumSize: Size.square(large ? 72 : 48),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(SoundWaveRadii.control)),
      ),
    ),
    icon: player.busy
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: large ? 36 : 26,
          ),
  );
}

class TrackFavoriteButton extends StatelessWidget {
  const TrackFavoriteButton({
    super.key,
    required this.store,
    required this.trackId,
  });
  final UserStore store;
  final String trackId;
  @override
  Widget build(BuildContext context) {
    final favorite = store.state.favoriteTrackIds.contains(trackId);
    return IconButton(
      tooltip: favorite ? 'Descurtir música' : 'Curtir música',
      onPressed: () => store.setTrackFavorite(trackId, !favorite),
      icon: Icon(
        favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: favorite ? SoundWaveColors.purple : SoundWaveColors.secondary,
      ),
    );
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.player,
    required this.store,
    required this.onOpen,
  });
  final PlaybackController player;
  final UserStore store;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([player, store]),
    builder: (context, _) {
      final track = player.currentTrack;
      if (track == null) return const SizedBox.shrink();
      final fraction = player.duration.inMilliseconds == 0
          ? 0.0
          : (player.position.inMilliseconds / player.duration.inMilliseconds)
                .clamp(0.0, 1.0);
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: SurfaceCard(
          padding: const EdgeInsets.all(12),
          onTap: onOpen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  MusicArtwork(contextType: track.contexts.first, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          player.status.label,
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
                  TrackFavoriteButton(store: store, trackId: track.id),
                  PlayPauseButton(player: player),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: fraction,
                minHeight: 3,
                color: SoundWaveColors.cyan,
                backgroundColor: SoundWaveColors.border,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class PlaybackModeButtons extends StatelessWidget {
  const PlaybackModeButtons({super.key, required this.player});
  final PlaybackController player;
  @override
  Widget build(BuildContext context) {
    final repeatLabel = switch (player.repeatMode) {
      PlaybackRepeatMode.off => 'Desligada',
      PlaybackRepeatMode.all => 'Toda a fila',
      PlaybackRepeatMode.one => 'Uma faixa',
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: player.shuffleEnabled
              ? 'Desativar aleatório'
              : 'Ativar aleatório',
          onPressed: player.toggleShuffle,
          icon: Icon(
            Icons.shuffle_rounded,
            color: player.shuffleEnabled
                ? SoundWaveColors.cyan
                : SoundWaveColors.secondary,
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          tooltip: 'Repetição: $repeatLabel',
          onPressed: player.cycleRepeat,
          icon: Icon(
            player.repeatMode == PlaybackRepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: player.repeatMode == PlaybackRepeatMode.off
                ? SoundWaveColors.secondary
                : SoundWaveColors.cyan,
          ),
        ),
      ],
    );
  }
}

class PlaybackError extends StatelessWidget {
  const PlaybackError({super.key, required this.player});
  final PlaybackController player;
  @override
  Widget build(BuildContext context) => player.error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                player.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: SoundWaveColors.error),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: player.togglePlay,
                    child: const Text('Tentar novamente'),
                  ),
                  if (player.canNext)
                    TextButton(
                      onPressed: player.next,
                      child: const Text('Próxima faixa'),
                    ),
                ],
              ),
            ],
          ),
        );
}
