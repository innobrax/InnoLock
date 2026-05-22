# 03 - Protocolo BLE v1

## 1. Objetivo

Definir a comunicação inicial entre o app Android e o dispositivo Inno Lock baseado em ESP32-C3.

## 2. Identificação BLE

O dispositivo deve anunciar com nome:

```text
InnoLock_<MAC>
```

Onde `<MAC>` é o MAC do ESP32-C3 sem dois pontos, em letras maiúsculas.

Exemplo:

```text
InnoLock_64E833AFB026
```

## 3. Estratégia de scan

O app Android deve escanear dispositivos BLE sem filtro por Service UUID no advertising.

Motivo: nos testes iniciais, o advertising simples por nome funcionou melhor no ESP32-C3 com NimBLE-Arduino.

Filtro no app:

```text
deviceName startsWith "InnoLock_"
```

## 4. UUIDs BLE

Para a versão inicial, será usado um serviço no padrão UART-like.

```text
SERVICE_UUID = 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
RX_UUID      = 6E400002-B5A3-F393-E0A9-E50E24DCCA9E
TX_UUID      = 6E400003-B5A3-F393-E0A9-E50E24DCCA9E
```

### RX

Característica de escrita app → ESP32.

Propriedades:

```text
WRITE
WRITE_NO_RESPONSE
```

### TX

Característica de resposta ESP32 → app.

Propriedades:

```text
READ
NOTIFY
```

## 5. Comandos de protótipo

Comandos usados nos testes iniciais:

```text
ON
OFF
PULSE:1200
STATUS
```

Esses comandos são úteis apenas para protótipo. Em produção, comandos críticos não devem ser aceitos sem token assinado.

## 6. Comandos de produção v1

### 6.1 Status

Solicitação:

```text
STATUS
```

Resposta:

```text
STATUS:DEVICE_ID=64E833AFB026;LOCK=LOCKED;OUTPUT=OFF;FW=0.1.0;UPTIME=123456
```

### 6.2 Destrava com token

Solicitação:

```text
UNLOCK_TOKEN:<payload>
```

Onde `<payload>` deve conter um token assinado gerado pelo backend.

Resposta de sucesso:

```text
OK:UNLOCKED;FEEDBACK=UNLOCKED
```

Respostas de erro:

```text
ERR:AUTH_INVALID
ERR:TOKEN_EXPIRED
ERR:REPLAY_DETECTED
ERR:DEVICE_MISMATCH
ERR:FEEDBACK_TIMEOUT
ERR:LOCK_BLOCKED
```

### 6.3 Modo manutenção

Solicitação:

```text
MAINT_TOKEN:<payload>
```

Resposta:

```text
OK:MAINTENANCE_MODE
```

## 7. Payload sugerido do token

O token pode ser transmitido como JSON compacto ou como formato binário/Base64.

Para a primeira versão, usar JSON compacto em Base64URL facilita debug.

Conteúdo lógico:

```json
{
  "typ": "DELIVERY_UNLOCK",
  "dev": "64E833AFB026",
  "ten": 10,
  "usr": 25,
  "trp": 101,
  "loc": 55,
  "iat": 1779450000,
  "exp": 1779450300,
  "nonce": "abc123",
  "cmd": "UNLOCK"
}
```

## 8. Regras do firmware

O firmware deve validar:

1. Token está bem formado.
2. Assinatura é válida.
3. `dev` corresponde ao MAC do ESP32.
4. Token não expirou.
5. `nonce` não foi usado antes.
6. `cmd` é permitido.
7. Trava não está bloqueada por estado interno.

## 9. Logs no firmware

O ESP32 deve retornar ao app:

- comando recebido;
- resultado;
- status da saída;
- status do retorno da trava;
- erro, se houver.

## 10. Observação sobre segurança

BLE é apenas o meio de transporte. A segurança operacional deve estar no token, na autorização central e na validação no firmware.
