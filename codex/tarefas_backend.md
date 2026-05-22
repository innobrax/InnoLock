# Tarefas Codex - Backend API

## Objetivo

Criar backend inicial para o Inno Lock como SaaS multiempresa.

## Stack sugerida

A definir. Opções:

- PHP 8.2 + Slim/Laravel;
- Node.js + NestJS/Express;
- Python + FastAPI.

Para integração com o histórico da Innobrax, PHP pode ser uma escolha prática. Para arquitetura moderna, FastAPI ou NestJS também são boas opções.

## Tarefa 1 - Escolher stack

```text
Analise o projeto InnoLock e sugira uma stack para o backend considerando MySQL, autenticação, API REST, multiempresa, facilidade de deploy em Ubuntu e manutenção pela equipe. Não crie código ainda.
```

## Tarefa 2 - Estrutura inicial

```text
Crie uma estrutura inicial de backend em backend/api com rotas para auth, tenants, users, vehicles, devices, trips, authorized_locations, unlock_tokens e unlock_events. Usar arquitetura organizada e documentação de endpoints.
```

## Tarefa 3 - Autenticação

```text
Implemente autenticação inicial com login por e-mail e senha, hash seguro de senha, geração de token de sessão/JWT e middleware de autenticação.
```

## Tarefa 4 - Multiempresa

```text
Implemente middleware de tenant para garantir que consultas operacionais filtrem por tenant_id conforme acesso do usuário.
```

## Tarefa 5 - Geração de token de abertura

```text
Crie endpoint POST /unlock-tokens/request que recebe device_id, trip_id, localização GPS e tipo de abertura. O backend deve validar permissões e gerar registro em unlock_tokens.
```

## Tarefa 6 - Eventos de abertura

```text
Crie endpoint POST /unlock-events para registrar resultado da tentativa de abertura, incluindo coordenadas, retorno da trava, tipo de evento e resultado.
```
