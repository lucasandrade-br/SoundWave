# Home — início e contextos

Status E05: aceita pelo usuário. Rodada de apresentação adiciona podcasts visuais e rolagem fluida para avaliação final.

## Comportamento

- context_recommendations.dart ordena os seis contextos pela contagem do período efetivo; desempata pelo par configurado e depois pela ordem fixa dos contextos. Home mostra os dois primeiros. Sem escolhas, usa o par inicial.
- Corpo do cartão abre CollectionPage sem contar escolha. Play inicia uma sessão contextual; somente o início confirmado pelo motor incrementa a contagem. Pausa/retomada, seek, avanços e repetição da mesma fila não contam novamente.
- Nova ação explícita de iniciar contexto cria nova sessão. Falha ou seleção substituída antes de tocar não conta. Snapshot recuperado pausado não inventa contexto. O período é fixado no primeiro início confirmado, sem reclassificar a escolha quando o relógio cruza um limite.
- Nome e saudação vêm do perfil/horário efetivo; dia da semana usa data real. PresentationBanner compartilhado indica hora simulada e oferece retorno ao real.
- Etiquetas abrem Busca funcional sem filtro contextual antigo; recentes vêm do histórico real. Jukebox usa coleções prontas, e Ver tudo abre seu filtro na Biblioteca.
- Layout empilha contextos em largura estreita/texto ampliado. PodcastPreviewSection apresenta dois cards visuais com Em breve, sem Play ou episódios no catálogo. Não altera a reprodução/histórico. Cabeçalho e gradiente superior rolam com a Home. Miniplayer usa a reprodução compartilhada.

## Estado e validação

Contadores persistem no UserStore como periodo:contexto, separados do limite do histórico. Não existe IA remota; a recomendação é uma regra local. Gêneros filtram sugestões da fila, sem alterar esse ranking.

Regras/transições estão testadas em test/home/context_recommendations_test.dart e test/player/context_session_test.dart; fluxo de horário/Home em test/widgets/profile_flow_test.dart. E03/E04 foram aprovadas pelo usuário; testes/build não substituem aceitação visual dos ajustes de apresentação.

Referência: Home - SoundWave (Dynamic Beats & Glow).png em Telas Criadas. Ver [fluxos](../../../Idealiza%C3%A7%C3%A3o/02-fluxos-e-comportamentos.md), [visual](../../../Idealiza%C3%A7%C3%A3o/03-identidade-visual.md), [etapas](../../../Idealiza%C3%A7%C3%A3o/05-etapas-e-aceitacao.md) e [andamento](../../../Idealiza%C3%A7%C3%A3o/08-andamento.md).

Refinamento visual de 04/11/2026: cantos discretos nos cards, capas e controles, seguindo as referências. Valores centralizados em SoundWaveRadii no tema; comportamento preservado.
