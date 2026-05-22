# Tarefas Codex - Firmware ESP32-C3

## Contexto

O firmware roda em ESP32-C3 usando Arduino IDE e NimBLE-Arduino.

Estado validado:

- BLE aparece no scanner quando advertising é simples por nome.
- Nome BLE: `InnoLock_<MAC>`.
- App Android já conseguiu conectar.
- LED no GPIO8 foi usado para simular acionamento.

## Tarefa 1 - Organizar firmware atual

```text
Organize o firmware atual do InnoLock dentro de firmware/esp32-c3/innolock_ble. Preserve o código funcional. Adicione comentários e um README específico do firmware com pinos, comandos BLE e dependências.
```

## Tarefa 2 - Separar lógica em funções

```text
Refatore o firmware ESP32-C3 separando: inicialização BLE, processamento de comandos, controle de saída, leitura de status, logs e utilitários de MAC. Não altere o comportamento funcional.
```

## Tarefa 3 - Adicionar GPIO real

```text
Evolua o firmware para usar GPIO4 como saída real da trava, GPIO5 como entrada de status e GPIO8 como LED de debug. Mantenha comandos de teste ON, OFF, PULSE e STATUS somente em modo DEBUG.
```

## Tarefa 4 - Protocolo seguro

```text
Implemente a base do comando UNLOCK_TOKEN:<payload>. Por enquanto, apenas parseie o payload, valide device_id e validade simulada. Não implemente criptografia completa ainda. Retorne erros padronizados.
```

## Tarefa 5 - Anti-replay inicial

```text
Adicione estrutura para armazenar os últimos nonces usados em RAM e rejeitar nonce repetido durante o ciclo ligado do dispositivo.
```
