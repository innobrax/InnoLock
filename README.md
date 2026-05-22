# Inno Lock

O **Inno Lock** é uma plataforma SaaS para controle seguro de abertura de compartimentos de carga em veículos, usando:

- dispositivo embarcado com **ESP32-C3**;
- comunicação local via **Bluetooth Low Energy (BLE)**;
- app Android para motorista, responsável de CD, técnico ou operador autorizado;
- backend para controle de empresas, usuários, veículos, viagens, locais autorizados, tokens e auditoria;
- frontend web para administração, programação de entregas, monitoramento e autorização remota de exceções.

## Objetivo do projeto

Controlar a abertura de compartimentos de carga de forma segura, auditável e vinculada a regras operacionais, como:

- abertura em local de entrega autorizado;
- abertura dentro de Centro de Distribuição;
- abertura por motorista autorizado;
- abertura excepcional com aprovação remota da central de monitoramento, por exemplo em fiscalização policial;
- manutenção técnica autorizada;
- rastreabilidade completa dos eventos.

## Premissas principais

1. O ESP32-C3 não decide sozinho se pode abrir a trava.
2. O app Android atua como ponte local entre o operador e o dispositivo via BLE.
3. A central/backend emite tokens de abertura assinados.
4. O ESP32-C3 valida o token antes de acionar a trava.
5. Toda abertura deve gerar log local no app e log no backend.
6. O sistema deve ser SaaS multiempresa, com isolamento por empresa e suporte a grupos econômicos.

## Estrutura do repositório

```text
InnoLock/
├─ firmware/
│  └─ esp32-c3/
│     └─ innolock_ble/
├─ app/
│  └─ android/
│     └─ innolock_driver_app/
├─ backend/
│  └─ api/
├─ frontend/
│  └─ web-monitoring/
├─ database/
│  ├─ innolock_schema_inicial.sql
│  └─ migrations/
├─ docs/
├─ hardware/
├─ codex/
├─ README.md
└─ .gitignore
```

## Estado atual do projeto

Validações já realizadas:

- ESP32-C3 anunciando via BLE com nome no formato `InnoLock_<MAC>`.
- App Android conectando ao ESP32-C3 via BLE.
- Envio de comandos BLE para o firmware.
- Simulação de acionamento da trava usando LED no GPIO8.
- Definição inicial de arquitetura SaaS multiempresa.
- Definição inicial do modelo de segurança por token assinado.

## Próximas etapas

1. Organizar o firmware BLE atual dentro de `firmware/esp32-c3/innolock_ble`.
2. Organizar o app Android atual dentro de `app/android/innolock_driver_app`.
3. Criar backend com autenticação, multiempresa e geração de tokens.
4. Criar frontend web administrativo e de monitoramento.
5. Evoluir o firmware para validar tokens de abertura.
6. Evoluir o app Android para login, GPS, solicitação de token e envio seguro ao ESP32.
7. Implementar logs e auditoria.
