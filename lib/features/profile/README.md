# Profile — perfil e demonstração

Status E05: aceito pelo usuário, após retirar o card detalhado de escolhas. Cabeçalho acompanha a rolagem do Perfil na rodada de apresentação. Sem conta real, assinatura ou estatísticas inventadas.

## Implementação

- profile_page.dart apresenta nome/identificação, iniciais, curtidas, coleções salvas, até cem execuções no histórico e o total de escolhas de contexto. Os números vêm do UserStore. O card detalhado Escolhas por período foi removido a pedido do usuário; contadores e recomendações continuam ativos.
- profile_editors.dart contém formulários de perfil, períodos e modo de apresentação. Cada formulário usa um rascunho local; Cancelar não grava. Nome obrigatório até 50 caracteres e identificação até 30, compatíveis com o modelo.
- Gêneros favoritos são opções derivadas das etiquetas do catálogo; filtram Sugeridas na fila. Sem seleção, todos os estilos ficam disponíveis. Não mudam a contagem/ranking dos contextos.
- Períodos configuram três horas inteiras crescentes entre 0 e 23 e dois contextos distintos por período. A madrugada pertence à noite. Validação inválida mantém o diálogo e não altera preferências.
- Modo de apresentação tem ativação explícita e hora/minuto válidos. A data continua real. PresentationBanner mostra a simulação no shell/player e permite Usar horário real; não recria o motor de áudio.
- Ajuda local explica catálogo, autoria SoundWave Demo, recomendações por contagem e limites da entrega.

## Restauração

O botão pede confirmação. Cancelar preserva preferências e reprodução. Confirmar chama PlaybackController.restoreDemo: invalida carga/eventos antigos, bloqueia novas seleções durante a operação, aguarda parada do áudio, limpa estado em memória/fila e chama UserStore.restoreDefaults. O repositório remove apenas soundwave.state.v1; catálogo permanece.

Falha ao parar não apaga os dados. Falha na remoção não retorna sucesso nem mostra confirmação de restauração concluída. Escritas pendentes ficam antes da remoção serializada. resetVersion notifica o shell para limpar rascunho/filtros; fila vazia não é gravada novamente após a limpeza.

## Evidências e limites

Testes verificam salvar/cancelar/validar perfil, persistência, períodos, simulação/retorno ao real, contagem única, confirmação/cancelamento de reset e layout 320x568 com texto 2x. Testes usam armazenamento/motor isolados; nenhum dado real do navegador foi alterado pelo agente.

Referência visual: Perfil & Configurações - SoundWave.png em Telas Criadas, simplificada conforme escopo. Contrato em [fluxos](../../../Idealiza%C3%A7%C3%A3o/02-fluxos-e-comportamentos.md), E05 em [plano](../../../Idealiza%C3%A7%C3%A3o/05-etapas-e-aceitacao.md), evidências em [andamento](../../../Idealiza%C3%A7%C3%A3o/08-andamento.md).
