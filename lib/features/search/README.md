# Search — pesquisa local

Status E04: implementada, testada e aprovada pelo usuário em 04/11/2026. A E05 preserva a busca e limpa rascunho/filtro ao restaurar a demonstração.

## Implementação

- catalog_search.dart pesquisa o catálogo único por título, artista, etiquetas, contextos e nomes das coleções associadas às faixas. Coleções são pesquisadas por título, autoria, descrição e etiquetas dos membros.
- Normalização compartilhada em core/services/search_text.dart: caixa, acentos portugueses, marcas combinantes e espaços. Todos os termos precisam ocorrer, em qualquer ordem. Sem pacote adicional, serviço remoto ou microfone.
- search_page.dart reage ao TextEditingController preservado no shell. Resultados são agrupados em músicas/coleções; categorias combinam filtro de contexto e texto. O filtro pode ser removido e etiquetas preenchem o campo; estado vazio oferece limpar busca/filtros.
- Selecionar música substitui a fila pelas faixas filtradas e seleciona o índice correto. Menus permitem curtir/descurtir ou adicionar sem substituir a atual. Coleção abre com Biblioteca ativa e Voltar retorna à Busca preservada.
- UserStore registra termo ao confirmar pelo teclado ou abrir resultado; digitar não registra. Máximo de dez termos distintos pela forma normalizada, mais recente primeiro. Remoção individual/limpeza persistem sem alterar favoritos/fila. Campo limitado a 200 caracteres, compatível com o codec existente.

## Estado e limites

Texto e filtro de contexto são mantidos pelo AppShell entre abas; resultados são derivados, sem catálogo duplicado. Ao abrir etiqueta pela Home, o filtro contextual anterior é removido. Favoritos/coleções salvas usam o mesmo UserStore de Player/Biblioteca. Não há criação de playlists pessoais.

## Evidências e referências

Testes de regra e de fluxo estão em test/search, test/core/search_history_test.dart e test/widgets/search_library_flow_test.dart. Cobrem normalização, composição de filtro, seleção intermediária/ordem da fila, adição, histórico persistido e volta da coleção. Motor fake não valida som real.

Referência visual: Pesquisa - SoundWave.png em Telas Criadas. Contrato em [fluxos](../../../Idealiza%C3%A7%C3%A3o/02-fluxos-e-comportamentos.md), etapa e aceitação em [plano](../../../Idealiza%C3%A7%C3%A3o/05-etapas-e-aceitacao.md), execução em [andamento](../../../Idealiza%C3%A7%C3%A3o/08-andamento.md).
