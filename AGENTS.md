# Orientações do SoundWave

Aplicam-se a todo este projeto. Instruções explícitas do usuário na conversa prevalecem.

## Contexto e leitura

- Produto acadêmico em Flutter/Dart; entrega inicial Flutter Web no Windows.
- Comece pelo README geral e por `Idealização/08-andamento.md`.
- Antes de alterar um módulo, leia seu README e os contratos correspondentes em `Idealização/`.
- Escopo: `01-escopo-e-decisoes.md`; comportamento: `02-fluxos-e-comportamentos.md`.
- Etapas e critérios: `05-etapas-e-aceitacao.md`; registre evidências em `08-andamento.md`.

## Fase e autonomia

- E00–E05 aceitas pelo usuário. E06 tem apresentação mobile/ajustes visuais integrados para avaliação final; E07/rede descartada.
- Quando a implementação for solicitada, execute a etapa pedida e suas dependências necessárias.
- Resolva detalhes rotineiros dentro do escopo sem pedir novamente decisões já aprovadas.
- Pergunte somente sobre ambiguidade que altere produto, escopo ou entrega.
- Não transforme propostas, comandos documentados ou placeholders em evidência de funcionamento.

## Contratos essenciais

- Navegação inferior fixa: Início, Buscar, Biblioteca, Perfil. Cabeçalho e gradiente superior rolam com o conteúdo.
- Coleção mantém Início ou Biblioteca ativo conforme origem; busca resolve para Biblioteca.
- Um único controlador de áudio e fila vive acima das páginas; navegar não o recria.
- Catálogo único; títulos, duração, favoritos e reprodução concordam entre telas.
- Sem criação/edição de playlists pessoais nesta entrega; favoritos e fila são funcionais.
- Sem backend, conta real, YouTube Music, assinatura ou efeitos de áudio avançados.
- Entrega apenas neste Windows; sem acesso pela rede. Podcasts são prévia visual autorizada, sem episódios/áudio.
- Persistência por navegador/origem; restauração elimina somente dados do SoundWave.

## Implementação e documentação

- Preserve as sete imagens em `Telas Criadas/`; reconstrua a interface com widgets Flutter.
- Prefira ChangeNotifier/ListenableBuilder, Navigator e serviços simples às camadas extras.
- Use inglês em identificadores Dart e português na interface/documentação.
- Não introduza API, banco, geração de código ou dependência sem necessidade concreta.
- Mantenha fontes e mídia locais; registre procedência e permissão de uso em assets.
- Trate acessibilidade, estados vazios e falhas de áudio como parte da funcionalidade.
- Teste regras e transições relevantes; não escreva testes que só repitam widgets estáticos.
- Atualize andamento e docs afetadas junto com mudanças; evite duplicar contratos.
- Diferencie análise, testes automatizados, build, navegador real e rede real.
- Não marque etapa concluída sem seus critérios; não declare apresentação homologada por build.
- Prepare ferramentas necessárias à etapa autorizada; não altere firewall nem publique na internet.
