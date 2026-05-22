# Tarefas Codex - App Android

## Contexto

O app Android deve conectar via BLE ao ESP32-C3.

Estado validado:

- App conecta ao ESP32-C3.
- Firmware anuncia como `InnoLock_<MAC>`.
- O scan deve filtrar por nome, não por Service UUID no advertising.

## Tarefa 1 - Organizar projeto Android

```text
Organize o app Android atual dentro de app/android/innolock_driver_app. Preserve o código funcional. Adicione README com instruções de build, versão do Gradle, permissões BLE e fluxo de teste.
```

## Tarefa 2 - Melhorar scan BLE

```text
Revise o código de scan BLE para listar apenas dispositivos cujo nome comece com InnoLock_. Não usar filtro por Service UUID durante o scan. Após conectar, descobrir serviços e localizar RX_UUID/TX_UUID.
```

## Tarefa 3 - Tela de status

```text
Adicione tela ou área de status mostrando dispositivo conectado, MAC, nome BLE, estado da conexão, último comando enviado e última resposta recebida.
```

## Tarefa 4 - Preparar login

```text
Crie estrutura inicial para login no app, sem implementar backend real ainda. Separar telas/classes para autenticação, sessão do usuário e armazenamento local seguro.
```

## Tarefa 5 - Preparar solicitação de token

```text
Crie uma interface/classe responsável por solicitar token de abertura ao backend. Por enquanto, usar endpoint placeholder configurável. Não quebrar o teste BLE atual.
```

## Tarefa 6 - GPS

```text
Adicione estrutura para coletar latitude, longitude e precisão GPS antes de solicitar abertura. Tratar permissões do Android corretamente.
```
