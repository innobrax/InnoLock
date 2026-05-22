# Protocolo BLE — Inno Lock Teste

## Serviço usado

Foi utilizado o padrão **Nordic UART Service (NUS)** para simplificar o teste e facilitar a compatibilidade com ferramentas BLE.

```text
Service UUID: 6e400001-b5a3-f393-e0a9-e50e24dcca9e
RX UUID:      6e400002-b5a3-f393-e0a9-e50e24dcca9e  App -> ESP32
TX UUID:      6e400003-b5a3-f393-e0a9-e50e24dcca9e  ESP32 -> App
```

## Nome BLE

```text
InnoLock_<MAC_SEM_DOIS_PONTOS>
```

Exemplo:

```text
InnoLock_A1B2C3D4E5F6
```

## Device ID

O identificador do controlador é o MAC do ESP32-C3 sem separadores.

```text
A1B2C3D4E5F6
```

## Comandos aceitos

### ID?

Retorna o identificador do ESP32-C3.

Resposta:

```text
ID:A1B2C3D4E5F6
```

Também envia um JSON de status.

### STATUS

Retorna um JSON com o estado atual.

Exemplo:

```json
{
  "id":"A1B2C3D4E5F6",
  "name":"InnoLock_A1B2C3D4E5F6",
  "event":"status",
  "gpio_acionamento":4,
  "saida_ativa":false,
  "gpio_status":5,
  "embolo_recolhido":false,
  "pulse_active":false,
  "millis":123456
}
```

### PULSE:1200

Aciona a saída por 1200 ms.

Limites aplicados no firmware:

```text
mínimo: 100 ms
máximo: 5000 ms
```

### ON

Mantém a saída de acionamento ligada.

### OFF

Desliga a saída de acionamento.

## Eventos enviados pelo ESP32

O ESP32 pode enviar eventos pelo TX notify:

```text
id
status
pulse_start
pulse_end
on
off
heartbeat
```

O `heartbeat` é enviado a cada 5 segundos enquanto houver conexão BLE.
