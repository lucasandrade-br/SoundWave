# Core — base compartilhada

Status: fundação E01 e tema/widgets E02 implementados e verificados. Reprodução foi integrada na feature player (E03); E05 integra contagem contextual e sugestões por gêneros.

## Arquivos existentes

- data/demo_catalog.dart e music_catalog.dart: 12 faixas, seis coleções contextuais, três álbuns e três playlists prontas; índices, validação e durações derivadas.
- models/: catálogo, contextos/períodos, perfil/configurações, snapshot de fila e UserState imutável.
- services/local_state_storage.dart: adaptador SharedPreferencesAsync limitado à chave soundwave.state.v1; interface pequena permite simular falhas nos testes.
- services/user_state_codec.dart: JSON versionado, saneamento de IDs/tipos e snapshot sempre pausado.
- services/user_state_repository.dart: carga com recuperação e gravações/remoção serializadas.
- services/user_store.dart: estado compartilhado, edição de perfil/configuração, favoritos, histórico confirmado (recordPlayback) e snapshot; falha mantém memória e retorna false com aviso.
- services/search_text.dart: normalização compartilhada entre busca e termos recentes; UserStore registra/remove/limpa pesquisas, e o codec saneia termos equivalentes na leitura.
- widgets/catalog_tiles.dart: linhas de faixas e coleções usadas pela Busca/Biblioteca, com callbacks para a fonte compartilhada.
- services/catalog_recommendations.dart: sugestões de faixas por contexto/gêneros, sem incluir músicas já na fila.
- widgets/presentation_banner.dart: aviso de hora simulada e retorno ao relógio real.
- services/demo_clock.dart: relógio injetável com hora simulada e data real.
- theme/soundwave_theme.dart: cores opacas, tipografia, estilos e SoundWaveRadii compartilhados; cartões/controles levemente quadráticos, capas com raio fixo e botões sem formato de pílula.
- widgets/: SoundWaveHeader com ícone de usuário e ação Abrir perfil (sem iniciais no topo), SurfaceCard, MusicArtwork por ícone/gradiente, SectionHeading, EmptyCatalogState e CatalogPreviewSheet. CatalogPreviewSheet é legado da E02, sem uso no fluxo E03; coleção funcional pertence à feature collection.

Player único está integrado e registra histórico no UserStore. E05 grava histórico e incremento de contexto juntos em recordPlayback quando autorizado pela sessão do player. Contadores usam o JSON existente. resetVersion sinaliza limpeza de rascunhos; remoção continua restrita à chave do app. Imagens de capa permanecem nulas para placeholders visuais da E02.

## Responsabilidade

Fornecer modelos, catálogo único, persistência, relógio efetivo, tema e componentes comuns. Evitar dados copiados entre telas.

## Responsabilidades por pasta

- models/: Track, Collection, QueueEntry, perfil, configurações e snapshot.
- data/: catálogo tipado com IDs estáveis e agrupamentos derivados.
- services/: armazenamento versionado, gravações serializadas e relógio real/simulado.
- theme/: paleta, espaçamentos, tipografia e ThemeData.
- widgets/: linha de faixa, capa com fallback, cabeçalho, cartões e mensagens de estado.

Não introduzir classes vazias ou camada genérica de repositório remoto. Controlador de reprodução pertence a player; widgets não instanciam seu próprio áudio.

## Dados e recuperação

Validar IDs, tratar JSON inválido, limitar histórico e manter reset restrito à chave SoundWave. Não retornar sucesso silencioso se armazenamento falhar. Favoritos e histórico têm uma fonte compartilhada.

## Aceitação e referências

Catálogo íntegro; leitura/escrita preserva dados válidos; dado inválido não impede abrir o app; relógio simulado é determinístico.
Consultar [modelos e persistência](../../Idealiza%C3%A7%C3%A3o/04-arquitetura-e-dados.md) e [visual](../../Idealiza%C3%A7%C3%A3o/03-identidade-visual.md). Etapa principal E01.

