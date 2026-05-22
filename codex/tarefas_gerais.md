# Tarefas Gerais para Codex

## Objetivo

Usar o Codex para evoluir o projeto Inno Lock de forma estruturada, sem apagar arquivos existentes e mantendo histórico no Git.

## Regra geral para todas as tarefas

Antes de alterar arquivos, o Codex deve:

1. analisar a estrutura atual;
2. listar o plano de alteração;
3. indicar arquivos que serão criados ou modificados;
4. aguardar confirmação quando a alteração for grande.

## Tarefa 1 - Revisar estrutura do projeto

Prompt sugerido:

```text
Analise a estrutura atual do projeto InnoLock. Verifique se existem as pastas firmware, app, backend, frontend, database, docs, hardware e codex. Não apague arquivos. Sugira melhorias de organização e liste um plano antes de alterar.
```

## Tarefa 2 - Atualizar README

Prompt sugerido:

```text
Atualize o README.md do projeto InnoLock com visão geral, estrutura de pastas, estado atual, pré-requisitos e próximos passos. Preserve informações existentes relevantes.
```

## Tarefa 3 - Verificar consistência da documentação

Prompt sugerido:

```text
Leia todos os arquivos em docs/ e verifique inconsistências entre arquitetura, protocolo BLE, segurança, fluxos e modelagem de dados. Gere uma lista de ajustes recomendados antes de modificar.
```

## Tarefa 4 - Criar checklist do MVP

Prompt sugerido:

```text
Crie um checklist detalhado do MVP do InnoLock separando firmware, app Android, backend, frontend, banco de dados, segurança e testes de campo.
```
