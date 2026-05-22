# 07 - Modelagem de Dados

## 1. Padrão de nomes

O banco será MySQL.

Todas as tabelas terão campos com prefixo de 5 letras.

Exemplos:

```text
economic_groups      -> ecogr_
tenants              -> tenan_
tenant_units         -> tenun_
users                -> users_
roles                -> roles_
user_tenant_access   -> ustac_
vehicles             -> vehic_
devices              -> devic_
drivers              -> drive_
authorized_locations -> autlo_
trips                -> trips_
trip_stops           -> trpst_
unlock_tokens        -> unlto_
unlock_events        -> unlev_
audit_logs           -> audlo_
```

## 2. Multiempresa

Toda tabela operacional deve possuir vínculo com tenant.

Exemplos:

```sql
devic_tenan_id
vehic_tenan_id
trips_tenan_id
unlev_tenan_id
```

## 3. Grupo econômico

Empresas podem pertencer a um grupo econômico.

```text
economic_groups
  └── tenants
```

## 4. Local autorizado x local real

O sistema deve armazenar:

1. local autorizado;
2. local real da solicitação;
3. local real da execução;
4. distância entre local autorizado e local real.

Tabela de locais autorizados:

```text
authorized_locations
```

Campos principais:

```text
autlo_latitude
autlo_longitude
autlo_geofence_radius_meters
```

Tabela de eventos:

```text
unlock_events
```

Campos principais:

```text
unlev_requested_latitude
unlev_requested_longitude
unlev_executed_latitude
unlev_executed_longitude
unlev_gps_accuracy_meters
unlev_distance_from_authorized_meters
```

## 5. Tokens

Tokens não devem ser armazenados puros no banco.

Armazenar:

```text
hash do token
nonce
validade
status
tipo
usuário
dispositivo
viagem
local
```

## 6. Eventos

Eventos devem registrar tentativas e resultados.

Resultados previstos:

```text
SUCCESS
AUTH_INVALID
EXPIRED_TOKEN
REPLAY_DETECTED
FEEDBACK_TIMEOUT
DENIED_BY_GEOFENCE
DENIED_BY_CENTRAL
DEVICE_ERROR
UNKNOWN_ERROR
```

## 7. Auditoria

Alterações administrativas devem ir para `audit_logs`.

Exemplos:

- criação de usuário;
- alteração de permissão;
- cadastro de dispositivo;
- bloqueio de dispositivo;
- autorização excepcional;
- alteração de local autorizado.

## 8. Script inicial

O script inicial está em:

```text
database/innolock_schema_inicial.sql
```
