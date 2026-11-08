# Andamento — registro desta cópia

## 08/11/2026 — README e diagnóstico de versionamento

O histórico original deste arquivo não estava presente nesta cópia. Este registro documenta somente a manutenção atual; não reconstrói contratos, aceitações ou evidências anteriores.

- Inspeção local: o repositório principal está em `main`, com o commit `3294ce1` contendo somente `README.md`. O remoto configurado é `https://github.com/lucasandrade-br/SoundWave.git`. O terminal fornecido pelo usuário confirma o primeiro push bem-sucedido.
- Causa do erro de inclusão: `flutter/` contém um repositório Git independente, com remoto do Flutter e sem HEAD resolvível. Adicionada a regra `/flutter/` ao `.gitignore`, preservando seu conteúdo.
- README central reescrito em UTF-8, removendo o título duplicado com bytes nulos, organizando execução/desenvolvimento/apresentação e retirando afirmações de validação sem evidência disponível nesta cópia.
- Ausências observadas antes da edição: `Idealização/`, `Telas Criadas/` e `test/`. Os contratos e o histórico originais precisam ser recuperados de outra cópia, sem recriação especulativa. As sete referências visuais não foram alteradas, pois não estão disponíveis aqui.
- Escopo desta manutenção: documentação e regra de exclusão do SDK. Sem alteração do aplicativo, commit, push, publicação ou configuração de rede.
- Não foram executados testes Flutter, build ou avaliação no navegador nesta manutenção. O estado de aceitação descrito no README tem como fonte `AGENTS.md`.
- Verificação da manutenção: README sem bytes nulos e sem links locais quebrados; `git check-ignore` confirmou a exclusão de `flutter/`, `build/` e `.dart_tool/`. A simulação de `git add .` passou usando um índice temporário separado (o ambiente restringe escrita em `.git`), sem preparar arquivos no índice real.
