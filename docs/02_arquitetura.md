# 02 - Arquitetura SaaS Multiempresa

## 1. Visão geral

O Inno Lock será uma plataforma SaaS multiempresa. A mesma instalação do sistema deve atender várias empresas de forma isolada, permitindo também a organização por grupos econômicos.

Hierarquia principal:

```text
Grupo Econômico
  └── Empresa / Tenant
        └── Unidade / CD / Filial / Cliente
              └── Veículo
                    └── Dispositivo Inno Lock
                          └── Viagem / Entrega / Evento de abertura
```

## 2. Conceitos principais

### 2.1 Grupo econômico

Representa um conjunto de empresas relacionadas.

Exemplos:

- Grupo ABC Logística;
- Grupo Distribuidora XPTO;
- Holding com várias transportadoras.

Um usuário com perfil de grupo pode ter acesso a várias empresas do mesmo grupo.

### 2.2 Tenant / Empresa

Cada empresa cliente da plataforma é um tenant. A maior parte dos dados operacionais deve possuir `tenant_id`.

Regra geral:

```text
Toda consulta operacional deve filtrar por tenant_id.
```

### 2.3 Unidade

Unidades representam locais físicos ou operacionais, como:

- Centro de Distribuição;
- filial;
- base operacional;
- cliente;
- ponto autorizado;
- posto fiscal;
- manutenção.

### 2.4 Dispositivo

Cada dispositivo Inno Lock é identificado pelo MAC do ESP32-C3.

Formato recomendado:

```text
device_id = MAC sem dois pontos
ble_name = InnoLock_<MAC>
```

Exemplo:

```text
device_id = 64E833AFB026
ble_name = InnoLock_64E833AFB026
```

## 3. Camadas da solução

### 3.1 Firmware

Executa no ESP32-C3 e faz a interface com a trava.

Responsabilidades:

- BLE;
- acionamento físico;
- leitura de retorno/status;
- validação de token;
- proteção contra replay;
- resposta ao app.

### 3.2 App Android

Executa no smartphone do operador.

Responsabilidades:

- login;
- GPS;
- BLE;
- autorização operacional;
- solicitação de token;
- envio do token ao dispositivo;
- log offline.

### 3.3 Backend

API central do SaaS.

Responsabilidades:

- autenticação;
- RBAC;
- multiempresa;
- validação de viagem/local;
- emissão de token;
- logs;
- auditoria;
- integrações futuras.

### 3.4 Frontend

Interface web administrativa e operacional.

Responsabilidades:

- cadastros;
- monitoramento;
- autorização remota;
- auditoria;
- relatórios.

## 4. Fluxo resumido de abertura

```text
Usuário abre app
  ↓
App autentica usuário no backend
  ↓
App escaneia dispositivo BLE InnoLock_<MAC>
  ↓
App identifica veículo/dispositivo
  ↓
App coleta localização GPS
  ↓
Backend valida permissão, viagem e local
  ↓
Backend gera token assinado
  ↓
App envia token ao ESP32 via BLE
  ↓
ESP32 valida token
  ↓
ESP32 aciona trava
  ↓
ESP32 retorna status
  ↓
App envia evento ao backend
```

## 5. Isolamento de dados

Toda tabela operacional deve possuir um prefixo de campo de 5 letras e, quando aplicável, referência ao tenant.

Exemplo:

```sql
vehic_tenan_id
devic_tenan_id
trips_tenan_id
unlev_tenan_id
```

## 6. Escopos de acesso

Perfis previstos:

- `SUPER_ADMIN`
- `GROUP_ADMIN`
- `TENANT_ADMIN`
- `CENTRAL_MONITORAMENTO`
- `OPERADOR_LOGISTICO`
- `RESPONSAVEL_CD`
- `MOTORISTA`
- `TECNICO_MANUTENCAO`
- `AUDITOR`

## 7. Comunicação entre camadas

### App ↔ Backend

- HTTPS;
- autenticação com JWT ou sessão segura;
- envio de GPS;
- solicitação de token;
- sincronização de eventos.

### App ↔ ESP32

- BLE GATT;
- serviço UART-like;
- comandos estruturados;
- token assinado;
- respostas padronizadas.

### Firmware ↔ Backend

Na primeira fase, o ESP32 não precisa falar diretamente com o backend. O app atua como ponte. Em versões futuras, pode haver comunicação direta por rede celular, Wi-Fi ou gateway.

## 8. Decisão importante

O ESP32-C3 deve ser tratado como dispositivo de borda com baixa exposição. Ele não deve depender de internet para abrir quando o app já possui autorização válida, mas também não deve aceitar comando livre sem token.
