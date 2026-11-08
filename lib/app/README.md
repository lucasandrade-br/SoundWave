# App — composição e navegação

Status: E00–E05 implementadas e aceitas pelo usuário; ajustes da apresentação integrados para avaliação final. `app_bootstrap.dart` compõe catálogo, UserStore e DemoClock; `lib/main.dart` inicializa os serviços antes de runApp. `soundwave_app.dart` aplica o tema e observa UserStore. `app_shell.dart` mantém as quatro abas em IndexedStack, rascunho da busca, contexto de navegação e atualização do relógio. E03 integra PlaybackController e AssetAudioEngine no bootstrap; app_frame.dart compartilha cabeçalho, miniplayer e navegação entre abas e coleções.

E04 conecta busca derivada do catálogo e biblioteca completa. O shell mantém filtro contextual da busca e filtro da biblioteca, além do texto/rolagem. Etiqueta da Home limpa contexto anterior; Ver tudo da Jukebox seleciona o filtro de coleções prontas. Todos os comandos continuam no PlaybackController existente; nenhum motor novo foi criado.

E05 conecta ProfilePage aos serviços existentes. AppBootstrap aceita relógio injetável nos testes. AppShell observa resetVersion para limpar busca/filtros após restauração. AppFrame reserva miniplayer/navegação em bottomNavigationBar; avisos de salvamento aparecem acima dos controles. PresentationBanner compartilha o indicador de simulação com o player. Cabeçalho/status usam uma linha em espaço estreito, preservando descrição completa para acessibilidade.

Rodada de apresentação: PhonePresentation envolve o Navigator pelo builder do MaterialApp e mantém 390 × 844 em qualquer rota, com escala ajustada ao monitor. ScrollingPage usa PageChrome para colocar cabeçalho, apresentação/avisos e conteúdo na mesma rolagem. Gradiente só nos primeiros 360 pontos e preso a esse conteúdo; AppFrame não tem gradiente nas laterais. Cabeçalho usa ícone de usuário. Rodapé/miniplayer continuam fixos. Sem alteração dos serviços de áudio/estado.

## Responsabilidade

Criar MaterialApp, tema, serviços compartilhados e shell de quatro abas. Preservar reprodução e dados enquanto as vistas são abertas/fechadas.

## Implementado

- Bootstrap com carga do estado local e fallback em memória.
- Uma instância de catálogo, relógio, estado do usuário e controlador de áudio.
- Abas Início/Buscar/Biblioteca/Perfil com estado preservado.
- Abertura de coleção com origem e Voltar coerentes.
- Player/fila como detalhe, sem recriar AudioPlayer.
- Layout centralizado, miniplayer e rodapé com espaço reservado.

Existentes: soundwave_app.dart, app_bootstrap.dart, app_frame.dart e app_shell.dart. O widget raiz encerra PlaybackController/motor e UserStore no dispose; não recriar serviços durante navegação. O shell encerra seu timer e controlador de texto no dispose. Não contém outro catálogo nem chama escrita de preferências ao trocar de aba.

Na E03, Navigator abre CollectionPage e PlayerPage sem reinicializar serviços. Coleção usa AppFrame com indicação Início/Biblioteca conforme origem; Voltar retorna à aba anterior, inclusive Buscar. Fechar player/fila mantém a reprodução. CatalogPreviewSheet é um componente legado da E02 sem uso no fluxo atual. Validação técnica passou; usuário testou e aprovou E03 em 04/11/2026.

## Dependências e limites

Compor core e features, sem colocar regra de busca ou recomendação dentro do shell. Controller de áudio é encerrado somente no descarte do app.

## Aceitação e referências

Navegar e voltar sem perder faixa, fila, pausa ou termo pesquisado. Origens de coleção seguem o contrato.
Consultar [fluxos](../../Idealiza%C3%A7%C3%A3o/02-fluxos-e-comportamentos.md), [arquitetura](../../Idealiza%C3%A7%C3%A3o/04-arquitetura-e-dados.md) e E02/E03 no [plano](../../Idealiza%C3%A7%C3%A3o/05-etapas-e-aceitacao.md).

