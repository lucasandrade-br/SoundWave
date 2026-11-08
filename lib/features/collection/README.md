# Collection — álbum e playlist

Status E03: CollectionPage implementada e integrada ao shell e ao controlador único. Validação técnica passou; o usuário testou e aprovou a E03 em 04/11/2026.

## Responsabilidade

Exibir uma coleção de faixas reutilizável para playlist pronta, álbum, contexto, curtidas e grupo de artista.

Referência: Álbum & Playlist - SoundWave.png em Telas Criadas.

## Implementado

- CollectionPage com metadados, capa/fallback, contagem, duração e faixas.
- Tocar tudo, faixa individual e início embaralhado.
- Curtir faixa, salvar coleção e adicionar à fila.
- Ordenação por ordem original/título.
- Origem de navegação Início/Biblioteca e destino de Voltar preservados.

Curtidas usa seleção dinâmica do UserStore; salvar coleção usa o ID do catálogo. Tocar faixa usa a ordem visível e seu índice; ordenar a tela não altera a fila em andamento. Metadados/tempos são derivados do catálogo. E04 conecta grupos derivados de artistas e todos os recentes pela Biblioteca; a mesma página apresenta/reproduz suas faixas sem nova entidade de catálogo.

## Dependências e limites

Enviar comandos ao player único. Não editar faixas de playlists prontas nem oferecer criação/edição de playlists pessoais. Filtros/ordenação visual não alteram fila já iniciada automaticamente.

## Aceitação e referências

Tocar substitui fila; adicionar preserva atual. Quantidades/duração correspondem ao catálogo. Grupo vazio não permite Play e possui mensagem.
Consultar [Coleção](../../../Idealiza%C3%A7%C3%A3o/02-fluxos-e-comportamentos.md) e E03/E04 no [plano](../../../Idealiza%C3%A7%C3%A3o/05-etapas-e-aceitacao.md).

