# 04 - Segurança, Tokens e Autorização

## 1. Objetivo

Definir a estratégia de segurança do Inno Lock para impedir que aplicativos não autorizados ou usuários indevidos executem abertura do compartimento de carga.

## 2. Princípio central

O ESP32-C3 não deve aceitar comandos livres como:

```text
UNLOCK
PULSE
ON
```

Esses comandos podem existir em fase de protótipo, mas devem ser removidos ou bloqueados em produção.

Em produção, o comando de abertura deve depender de um token assinado:

```text
UNLOCK_TOKEN:<token>
```

## 3. O que não deve ser usado como segurança principal

Não confiar apenas em:

- nome BLE;
- MAC;
- UUID;
- app instalado;
- senha fixa;
- comando oculto;
- pareamento Bluetooth simples.

Esses elementos podem ajudar na operação, mas não são suficientes para carga valiosa.

## 4. Modelo recomendado

### 4.1 Chave do dispositivo

Cada dispositivo deve ter uma chave exclusiva.

```text
device_id = MAC do ESP32-C3
device_secret = chave aleatória individual
```

O backend deve conhecer a chave do dispositivo ou uma chave derivada. O firmware deve ter condição de validar tokens.

### 4.2 Token assinado

O backend gera um token contendo:

- device_id;
- tenant_id;
- usuário;
- viagem;
- local autorizado;
- tipo de abertura;
- validade curta;
- nonce;
- comando;
- assinatura.

### 4.3 Validade curta

Exemplo:

```text
2 a 5 minutos
```

Para fiscalização ou emergência, a validade deve ser curta e o uso único.

### 4.4 Uso único

Cada token deve conter um `nonce`.

O ESP32 deve manter uma pequena lista dos últimos nonces usados, para impedir replay.

### 4.5 Auditoria

Toda tentativa deve ser registrada:

- sucesso;
- falha;
- token inválido;
- token expirado;
- replay detectado;
- feedback timeout;
- negação por localização;
- negação pela central.

## 5. Tipos de token

```text
DELIVERY_UNLOCK
CD_UNLOCK
REMOTE_EXCEPTION
MAINTENANCE_UNLOCK
EMERGENCY_UNLOCK
```

## 6. Fluxo de abertura com token

```text
App solicita abertura
  ↓
Backend valida usuário, empresa, veículo, viagem e local
  ↓
Backend gera token assinado
  ↓
App envia token via BLE
  ↓
ESP32 valida token
  ↓
ESP32 aciona trava
  ↓
ESP32 retorna resultado
  ↓
App envia log ao backend
```

## 7. Abertura excepcional

Para fiscalização policial ou situação operacional fora do local autorizado:

1. Motorista solicita abertura excepcional pelo app.
2. Central recebe a solicitação.
3. Operador da central analisa.
4. Operador aprova ou nega.
5. Backend gera token `REMOTE_EXCEPTION`.
6. App envia token ao ESP32.
7. Evento fica marcado como exceção.

## 8. Proteções adicionais

### 8.1 Bloqueio por tentativas inválidas

Se houver muitas tentativas inválidas:

```text
bloquear abertura por X minutos
registrar alerta
exigir nova autorização da central
```

### 8.2 Revogação de usuário

Usuários desligados ou bloqueados não podem obter novos tokens.

### 8.3 Revogação de dispositivo

Dispositivo perdido, substituído ou comprometido deve ser marcado como:

```text
BLOCKED
REVOKED
```

### 8.4 OTA assinado

Atualizações futuras do firmware devem ser assinadas.

## 9. Decisão para MVP

Para o MVP, implementar:

1. login no app;
2. token de abertura gerado pelo backend;
3. validade curta;
4. nonce;
5. hash do token no banco;
6. log de evento;
7. validação básica no firmware.

Para a versão comercial, evoluir para assinatura robusta, rotação de chave e proteção contra replay no firmware.
