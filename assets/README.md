# Assets — mídia da demonstração

Status: E01 concluída para mídia inicial. Incluídos 12 instrumentais WAV, total 228 segundos e 10.055.328 bytes. Duração, caminhos e hashes estão em [audio_manifest.json](audio_manifest.json); procedência e uso em [CREDITOS.md](CREDITOS.md).

## Catálogo entregue e manutenção

- 12 faixas originais sintetizadas por [tools/generate_demo_audio.py](../tools/generate_demo_audio.py), com associação aos seis contextos.
- Capas não incluídas: usar placeholders de ícone/gradiente na E02.
- Não há podcast nesta mídia. Episódios demonstrativos somente se houver arquivo correspondente.
- Áudio local, servido junto do app; não usar URLs temporárias ou dependência de YouTube Music.
- Diretório audio/ e manifesto registrados no pubspec; manter nomes de arquivo simples.

Se usar áudio sintetizado originalmente para o projeto, identificar claramente como demonstração autoral e usar títulos/autoria coerentes. Se usar material de terceiro, guardar a fonte, a licença e atribuição exigida. Não chamar áudio genérico de uma música comercial mostrada no PNG.

## Crédito obrigatório para cada arquivo entregue

Manter CREDITOS.md ao alterar mídia, com:
- caminho do arquivo;
- título e autor;
- origem/URL ou método de criação;
- licença/permissão e data de consulta;
- alterações realizadas;
- duração medida e contexto(s);
- atribuição a exibir, quando aplicável.

Não marcar licença de mídia ainda não obtida como validada.

## Verificações

Todos os assets referenciados existem; áudio decodifica no navegador-alvo; duração exibida corresponde ao arquivo; falha de capa tem fallback. Incluir recursos locais necessários e testar carregamento sem internet externa.

Evidência E01: arquivos/cabeçalhos/hashes conferidos; os 12 WAVs foram carregados e decodificados no Chrome com duração e sinal válidos. Não houve reprodução audível via player nem teste sem internet externa, previstos depois.

Consultar [catálogo](../Idealiza%C3%A7%C3%A3o/04-arquitetura-e-dados.md) e E01 no [plano](../Idealiza%C3%A7%C3%A3o/05-etapas-e-aceitacao.md).

