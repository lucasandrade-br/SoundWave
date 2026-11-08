import '../models/catalog_models.dart';
import '../models/listening_context.dart';
import 'music_catalog.dart';

final MusicCatalog demoCatalog = _createDemoCatalog();

MusicCatalog _createDemoCatalog() {
  final tracks = [
    _track(
      'aurora_lofi',
      'Aurora Lo-Fi',
      18,
      'album_foco',
      [ListeningContext.study, ListeningContext.work],
      ['Lo-Fi', 'Foco'],
    ),
    _track(
      'orbita_piano',
      'Órbita de Piano',
      20,
      'album_foco',
      [ListeningContext.study, ListeningContext.reading],
      ['Piano', 'Instrumental'],
    ),
    _track(
      'pulso_neon',
      'Pulso Neon',
      18,
      'album_movimento',
      [ListeningContext.workout],
      ['Eletrônico', 'Treino'],
    ),
    _track(
      'corrida_solar',
      'Corrida Solar',
      20,
      'album_movimento',
      [ListeningContext.workout, ListeningContext.travel],
      ['Eletrônico', 'Energia'],
    ),
    _track(
      'fluxo_criativo',
      'Fluxo Criativo',
      18,
      'album_foco',
      [ListeningContext.work, ListeningContext.study],
      ['Lo-Fi', 'Instrumental'],
    ),
    _track(
      'mesa_cafe',
      'Mesa de Café',
      20,
      'album_foco',
      [ListeningContext.work, ListeningContext.reading],
      ['Piano', 'Café'],
    ),
    _track(
      'estrada_azul',
      'Estrada Azul',
      18,
      'album_movimento',
      [ListeningContext.travel],
      ['Synthwave', 'Viagem'],
    ),
    _track(
      'horizonte_synth',
      'Horizonte Synth',
      20,
      'album_movimento',
      [ListeningContext.travel, ListeningContext.workout],
      ['Synthwave', 'Energia'],
    ),
    _track(
      'paginas_calmas',
      'Páginas Calmas',
      18,
      'album_calma',
      [ListeningContext.reading, ListeningContext.study],
      ['Piano', 'Calma'],
    ),
    _track(
      'jardim_acustico',
      'Jardim Acústico',
      20,
      'album_calma',
      [ListeningContext.reading, ListeningContext.sleep],
      ['Instrumental', 'Calma'],
    ),
    _track(
      'lua_serena',
      'Lua Serena',
      18,
      'album_calma',
      [ListeningContext.sleep],
      ['Ambient', 'Relaxamento'],
    ),
    _track(
      'mar_estrelas',
      'Mar de Estrelas',
      20,
      'album_calma',
      [ListeningContext.sleep, ListeningContext.reading],
      ['Ambient', 'Relaxamento'],
    ),
  ];

  return MusicCatalog(
    tracks: tracks,
    collections: [
      for (final context in ListeningContext.values)
        MusicCollection(
          id: 'context_${context.id}',
          title: context.label,
          description:
              'Instrumentais de demonstração para ${context.label.toLowerCase()}.',
          type: CollectionType.context,
          context: context,
          trackIds: tracks
              .where((t) => t.contexts.contains(context))
              .map((t) => t.id),
        ),
      for (final album in const [
        (
          'album_foco',
          'Caderno Sonoro',
          'Piano e batidas leves para acompanhar o foco.',
        ),
        (
          'album_movimento',
          'Em Movimento',
          'Batidas eletrônicas e melodias de estrada.',
        ),
        (
          'album_calma',
          'Tempo de Pausa',
          'Instrumentais suaves de leitura e descanso.',
        ),
      ])
        MusicCollection(
          id: album.$1,
          title: album.$2,
          description: album.$3,
          type: CollectionType.album,
          trackIds: tracks.where((t) => t.albumId == album.$1).map((t) => t.id),
        ),
      MusicCollection(
        id: 'playlist_cafe',
        title: 'Café & Foco',
        description: 'Uma pausa leve entre ideias.',
        trackIds: [
          'aurora_lofi',
          'mesa_cafe',
          'fluxo_criativo',
          'orbita_piano',
        ],
      ),
      MusicCollection(
        id: 'playlist_energia',
        title: 'Energia em Movimento',
        description: 'Instrumentais para dar ritmo ao dia.',
        trackIds: [
          'pulso_neon',
          'corrida_solar',
          'horizonte_synth',
          'estrada_azul',
        ],
      ),
      MusicCollection(
        id: 'playlist_noite',
        title: 'Depois do Entardecer',
        description: 'Melodias calmas para desacelerar.',
        trackIds: [
          'paginas_calmas',
          'jardim_acustico',
          'lua_serena',
          'mar_estrelas',
        ],
      ),
    ],
  );
}

Track _track(
  String id,
  String title,
  int seconds,
  String albumId,
  List<ListeningContext> contexts,
  List<String> tags,
) => Track(
  id: id,
  title: title,
  artist: 'SoundWave Demo',
  assetPath: 'assets/audio/$id.wav',
  duration: Duration(seconds: seconds),
  albumId: albumId,
  contexts: contexts,
  tags: tags,
);
