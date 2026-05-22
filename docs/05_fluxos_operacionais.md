# 05 - Fluxos Operacionais

## 1. Abertura em entrega autorizada

### Atores

- Motorista
- App Android
- Backend
- ESP32-C3
- Trava

### Fluxo

```text
1. Motorista chega ao local de entrega.
2. Motorista abre o app.
3. App identifica usuário logado.
4. App coleta GPS.
5. App escaneia BLE e encontra InnoLock_<MAC>.
6. App consulta backend solicitando abertura.
7. Backend valida:
   - empresa;
   - usuário;
   - motorista;
   - veículo;
   - dispositivo;
   - viagem;
   - local autorizado;
   - janela de horário;
   - geofence.
8. Backend gera token DELIVERY_UNLOCK.
9. App envia token ao ESP32 via BLE.
10. ESP32 valida token.
11. ESP32 aciona trava.
12. ESP32 lê retorno físico.
13. App recebe resultado.
14. App envia evento ao backend.
```

### Resultado esperado

```text
SUCCESS
```

### Possíveis falhas

```text
DENIED_BY_GEOFENCE
EXPIRED_TOKEN
DEVICE_MISMATCH
FEEDBACK_TIMEOUT
AUTH_INVALID
```

## 2. Abertura em Centro de Distribuição

### Atores

- Responsável do CD
- App Android
- Backend
- ESP32-C3

### Regras

O usuário deve ter perfil:

```text
RESPONSAVEL_CD
OPERADOR_LOGISTICO
TENANT_ADMIN
```

O local deve ser unidade do tipo:

```text
CD
BASE
FILIAL
```

### Fluxo

```text
1. Responsável do CD abre o app.
2. App coleta GPS.
3. App identifica dispositivo BLE.
4. Backend valida se o usuário pode operar naquele CD.
5. Backend valida se o veículo/dispositivo pertence à operação permitida.
6. Backend gera token CD_UNLOCK.
7. App envia token ao ESP32.
8. ESP32 destrava e retorna status.
9. Evento é registrado.
```

## 3. Fiscalização policial

### Atores

- Motorista
- Central de monitoramento
- Operador da central
- Backend
- App
- ESP32-C3

### Fluxo

```text
1. Polícia solicita abertura do compartimento.
2. Motorista abre o app e seleciona "Fiscalização".
3. App coleta GPS e identifica veículo/dispositivo.
4. App envia solicitação à central.
5. Operador da central analisa o pedido.
6. Operador aprova a abertura.
7. Backend gera token REMOTE_EXCEPTION.
8. App recebe token.
9. App envia token ao ESP32 via BLE.
10. ESP32 valida token e destrava.
11. Evento fica registrado como abertura excepcional.
```

### Informações obrigatórias

- motivo;
- GPS;
- usuário;
- veículo;
- dispositivo;
- horário;
- operador que autorizou;
- resultado da abertura.

## 4. Manutenção técnica

### Fluxo

```text
1. Técnico faz login.
2. App identifica dispositivo.
3. Backend verifica perfil TECNICO_MANUTENCAO.
4. Backend gera token MAINTENANCE_UNLOCK.
5. App envia ao ESP32.
6. Evento fica registrado como manutenção.
```

## 5. Sincronização offline

O app pode ficar sem internet depois de receber uma autorização.

Regras:

- se não houver internet, não solicitar nova autorização;
- eventos pendentes devem ficar armazenados localmente;
- ao voltar internet, sincronizar com o backend;
- evento offline deve informar horário do app e horário do servidor.

## 6. Auditoria

Todo fluxo deve gerar eventos em:

- `unlock_tokens`;
- `unlock_events`;
- `audit_logs`.

