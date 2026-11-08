# Library — biblioteca local

Status E04: implementada, testada e aprovada pelo usuário em 04/11/2026. Reutiliza CollectionPage e o controlador único da E03, já aprovada.

## Implementação

- library_page.dart oferece Tudo/Playlists/Artistas/Álbuns, com filtro preservado ao navegar. O atalho Ver tudo da Jukebox abre somente coleções prontas; um chip permite voltar à biblioteca completa.
- Curtidas é dinâmica, com quantidade real, abertura de coleção vazia e Play desabilitado sem faixas. Alterações em Busca/Coleção/Player refletem na mesma fonte; descurtir não remove a música em reprodução da fila.
- Coleções salvas são IDs do catálogo e aparecem em seção própria; coração salva/remove, sem editar a playlist pronta. Coleções prontas permanecem disponíveis mesmo quando não salvas. Filtros Playlists/Álbuns se aplicam a ambas as seções.
- library_catalog.dart deriva artistas das faixas existentes e recentes distintos em ordem do histórico mais novo. O catálogo atual tem um artista, SoundWave Demo; nenhum artista/número fictício é exibido.
- Artista abre CollectionPage com todas as suas faixas; álbuns usam as coleções do catálogo. Recentes apresenta até quatro faixas, menu de curtida/adição e Ver tudo abre todas as faixas distintas disponíveis no histórico.

## Limites e validação

Sem criação/edição de playlists pessoais, downloads, conta ou sincronização. Estados vazios têm mensagens reais. Catálogo e persistência são compartilhados; grupos de artista/recentes não criam novas faixas nem coleções persistidas.

Testes verificam grupos, ordem dos recentes, curtida cruzando telas, coleções salvas/removidas, filtros, navegação e layout 320x568 com texto 2x. E04 foi aprovada pelo usuário; não confundir testes com navegador real.

Referência visual: Biblioteca - SoundWave.png em Telas Criadas. Contrato em [fluxos](../../../Idealiza%C3%A7%C3%A3o/02-fluxos-e-comportamentos.md); E04 em [plano](../../../Idealiza%C3%A7%C3%A3o/05-etapas-e-aceitacao.md); evidências em [andamento](../../../Idealiza%C3%A7%C3%A3o/08-andamento.md).
