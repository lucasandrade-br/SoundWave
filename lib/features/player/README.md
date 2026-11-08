# Player — áudio, miniplayer e fila

Status E03: implementado e integrado, com 11 testes de controlador e fluxos de widgets aprovados. O usuário testou a versão integrada e confirmou funcionamento perfeito em 04/11/2026, concluindo E03. Essa aceitação é separada da evidência de fake/build.

## Responsabilidade

Ser a única fonte do estado de reprodução e da fila. Uma instância de AudioPlayer vive no ciclo de vida do app, acima das páginas.

Referências: Player - SoundWave.png e Fila de Reprodução - SoundWave.png em Telas Criadas.

## Implementado

- PlaybackController com seleção, fila por entryId, posição, duração, carga/erro e comandos.
- Adaptador fino para audioplayers, substituível por fake nos testes.
- PlayerPage, MiniPlayer e QueuePanel/QueuePage.
- Play/pause, anterior/próxima, seek, conclusão, repeat e shuffle.
- Próximas reordenáveis/removíveis, atual destacada e histórico/sugestões.
- Snapshot restaurado pausado; histórico registrado após resume confirmado pelo motor. E05 adiciona contagem por sessão contextual: flag em memória é reiniciada apenas por playTracks com nova intenção; a primeira reprodução confirmada incrementa contador junto com histórico, em uma gravação. Avanço/repeat/retry da mesma sessão não duplicam a escolha.
- Proteção a seleções rápidas e eventos atrasados; cancelar assinaturas no dispose final.

Arquivos: audio_engine.dart (adaptador audioplayers), playback_controller.dart (estado/comandos serializados e geração por seleção), playback_widgets.dart (controles/miniplayer), player_page.dart e queue_panel.dart. Posição vem do motor; snapshot é salvo a cada cinco segundos de progresso e nas transições. Fila distingue ocorrências por entryId, oferece arraste e menus de reordenação/remoção; painel inteiro rola com texto ampliado. Falha permite tentar novamente ou avançar. O motor só cria AudioPlayer ao preparar a primeira faixa.

E05 adiciona restoreDemo com invalidação/parada/limpeza coordenada e bloqueio de novas seleções durante reset. Falha ao parar preserva dados; falha ao limpar retorna false. Gêneros do Perfil filtram Sugeridas por etiqueta normalizada, além de afinidade contextual e exclusão das músicas já na fila. PresentationBanner aparece no player; cabeçalho/status do miniplayer mantêm uma linha com descrição acessível para caber com texto ampliado.

## Dependências e limites

Usar catálogo e armazenamento do core. Não criar um player por widget. Não extrair áudio do YouTube nem simular progresso. Fechar página não encerra reprodução. Não implementar equalizador/crossfade nesta entrega.

## Aceitação e referências

Ouvir áudio real, navegar e verificar estado igual nas vistas. Entradas duplicadas são distinguíveis; atual não muda ao reorganizar próximas; erro permite recuperação.
Contrato completo em [Player e Fila](../../../Idealiza%C3%A7%C3%A3o/02-fluxos-e-comportamentos.md), modelos em [arquitetura](../../../Idealiza%C3%A7%C3%A3o/04-arquitetura-e-dados.md); etapa E03.


Refinamento visual de 04/11/2026: cantos discretos nos cards, capas e controles, seguindo as referências. Valores centralizados em SoundWaveRadii no tema; comportamento preservado.
