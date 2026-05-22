# 08 - Roadmap do Projeto

## Fase 0 - Protótipo BLE

Status: em andamento/concluído parcialmente.

Entregas:

- ESP32-C3 anunciando via BLE;
- app Android conectando;
- comando de teste;
- LED simulando trava;
- identificação por MAC.

## Fase 1 - Organização do projeto

Entregas:

- estrutura de repositório;
- documentação inicial;
- script SQL inicial;
- tarefas para Codex;
- organização do firmware;
- organização do app.

## Fase 2 - Backend MVP

Entregas:

- autenticação;
- cadastro de tenants;
- cadastro de usuários;
- perfis;
- veículos;
- dispositivos;
- locais autorizados;
- viagens;
- geração de token;
- logs de abertura.

## Fase 3 - App Android MVP

Entregas:

- login;
- scan BLE;
- conexão ao ESP32;
- leitura de GPS;
- solicitação de token;
- envio de token;
- registro offline de eventos;
- sincronização.

## Fase 4 - Firmware seguro

Entregas:

- protocolo BLE v1;
- validação de token;
- acionamento GPIO4;
- leitura de feedback GPIO5;
- LED GPIO8 para debug;
- proteção contra replay;
- logs no serial;
- modo pareamento.

## Fase 5 - Frontend Web

Entregas:

- painel administrativo;
- painel de monitoramento;
- cadastro de viagens;
- autorização de fiscalização;
- histórico de eventos;
- relatórios.

## Fase 6 - Piloto operacional

Entregas:

- instalação em bancada;
- instalação em veículo;
- teste com motorista;
- teste em CD;
- teste de fiscalização simulada;
- validação elétrica;
- validação de segurança.

## Fase 7 - Produto comercial

Entregas:

- OTA assinado;
- hardening do firmware;
- rotação de chaves;
- monitoramento avançado;
- alertas;
- integrações externas;
- relatórios executivos;
- cobrança SaaS.
