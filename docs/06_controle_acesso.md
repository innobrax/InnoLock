# 06 - Controle de Acesso

## 1. Objetivo

Definir perfis e escopos de acesso da plataforma Inno Lock.

## 2. Perfis

### SUPER_ADMIN

Acesso total à plataforma SaaS.

Pode:

- cadastrar grupos econômicos;
- cadastrar tenants;
- bloquear empresas;
- visualizar auditoria global;
- realizar suporte avançado.

### GROUP_ADMIN

Administrador de grupo econômico.

Pode:

- visualizar empresas do grupo;
- criar usuários do grupo;
- consultar relatórios consolidados;
- administrar permissões dentro do grupo.

### TENANT_ADMIN

Administrador da empresa cliente.

Pode:

- cadastrar veículos;
- cadastrar dispositivos;
- cadastrar usuários;
- cadastrar locais autorizados;
- criar viagens;
- consultar logs da própria empresa.

### CENTRAL_MONITORAMENTO

Operador da central.

Pode:

- monitorar viagens;
- consultar eventos;
- autorizar abertura excepcional;
- registrar justificativa;
- acompanhar alertas.

### OPERADOR_LOGISTICO

Usuário operacional.

Pode:

- criar viagens;
- associar motoristas;
- associar veículos;
- definir paradas autorizadas;
- consultar status da operação.

### RESPONSAVEL_CD

Usuário de centro de distribuição.

Pode:

- abrir compartimento em CD autorizado;
- consultar veículos presentes;
- registrar eventos do CD.

### MOTORISTA

Usuário do app.

Pode:

- visualizar sua viagem;
- conectar ao dispositivo do veículo;
- solicitar abertura autorizada;
- solicitar abertura excepcional;
- sincronizar eventos.

### TECNICO_MANUTENCAO

Usuário técnico.

Pode:

- executar testes autorizados;
- parear dispositivo;
- realizar manutenção;
- consultar status técnico.

### AUDITOR

Usuário somente leitura.

Pode:

- consultar relatórios;
- consultar auditoria;
- exportar eventos, se autorizado.

## 3. Escopos

```text
PLATFORM
GROUP
TENANT
UNIT
DRIVER
```

## 4. Regras por escopo

### PLATFORM

Acesso global.

### GROUP

Acesso a todas as empresas de um grupo econômico.

### TENANT

Acesso a uma empresa.

### UNIT

Acesso limitado a uma unidade, como CD ou filial.

### DRIVER

Acesso limitado ao próprio motorista e suas viagens.

## 5. Tabela de relacionamento

A tabela `user_tenant_access` deve permitir associar usuário a:

- grupo econômico;
- empresa;
- unidade;
- perfil.

## 6. Regras críticas

1. Motorista não pode gerar autorização sem viagem válida.
2. Responsável de CD não pode abrir fora da unidade autorizada.
3. Operador da central deve justificar abertura excepcional.
4. Técnico deve operar apenas dispositivos autorizados.
5. Auditor não pode alterar registros.

## 7. Auditoria de permissões

Toda alteração de permissão deve gerar registro em `audit_logs`.
