# 01 - Visão Geral do Projeto Inno Lock

## 1. Conceito

O **Inno Lock** é uma solução para controle de abertura de compartimentos de carga em veículos, com foco em segurança operacional, rastreabilidade e controle remoto de exceções.

O sistema combina:

- hardware embarcado no veículo;
- app Android;
- backend SaaS;
- frontend web de gestão e monitoramento;
- controle de acesso;
- tokens de abertura de uso único;
- auditoria de todos os eventos.

## 2. Problema que o projeto resolve

Em operações de transporte com cargas valiosas, é necessário garantir que o compartimento de carga só seja aberto:

- em locais autorizados;
- por pessoas autorizadas;
- dentro de uma viagem autorizada;
- em janelas de tempo previstas;
- em situações excepcionais aprovadas pela central.

A abertura indevida do compartimento pode gerar:

- perda de carga;
- dificuldade de auditoria;
- conflito operacional;
- vulnerabilidade em fiscalização;
- impossibilidade de provar quando, onde e por quem a carga foi acessada.

## 3. Solução proposta

A solução propõe um dispositivo com ESP32-C3 instalado no veículo, conectado eletricamente à trava motorizada do compartimento de carga.

O operador usa um app Android para se conectar localmente ao ESP32-C3 via BLE. O app não deve simplesmente mandar um comando de abertura livre. Ele deve obter ou possuir uma autorização válida, representada por um token assinado, e entregar esse token ao ESP32.

O ESP32 valida o token e somente aciona a trava se o token for aceito.

## 4. Cenários de uso

### 4.1 Abertura em entrega autorizada

O motorista chega a um ponto de entrega. O app verifica:

- usuário logado;
- veículo/dispositivo autorizado;
- viagem em andamento;
- local GPS dentro da geofence autorizada;
- janela de tempo permitida.

Depois solicita token ao backend e envia ao ESP32.

### 4.2 Abertura em Centro de Distribuição

Um responsável do CD usa o app para abrir o compartimento no pátio ou doca. O acesso depende do perfil do usuário, do vínculo com a unidade e do veículo/dispositivo permitido.

### 4.3 Fiscalização policial

Em uma fiscalização, o motorista pode precisar abrir o compartimento fora do local de entrega.

Fluxo recomendado:

1. Motorista solicita abertura excepcional pelo app.
2. Central de monitoramento analisa o pedido.
3. Central autoriza e emite token temporário.
4. App recebe o token pela internet.
5. App envia token ao ESP32 via BLE.
6. ESP32 valida e aciona a trava.
7. Evento fica registrado como abertura excepcional.

### 4.4 Manutenção técnica

Técnico autorizado pode acionar o dispositivo em modo manutenção, com perfil específico, registro de motivo e limite de validade.

## 5. Componentes do sistema

### 5.1 Firmware ESP32-C3

Responsável por:

- anunciar BLE;
- expor serviço BLE;
- identificar o dispositivo pelo MAC;
- receber comandos;
- validar autorização;
- acionar a trava;
- ler retorno/status da trava;
- registrar status básico;
- responder ao app.

### 5.2 App Android

Responsável por:

- autenticar usuário;
- buscar dispositivos BLE `InnoLock_<MAC>`;
- conectar ao ESP32;
- obter localização GPS;
- solicitar token ao backend;
- enviar token ao ESP32;
- registrar eventos offline;
- sincronizar logs.

### 5.3 Backend SaaS

Responsável por:

- autenticação;
- controle multiempresa;
- gestão de usuários;
- gestão de veículos;
- gestão de dispositivos;
- gestão de viagens;
- gestão de locais autorizados;
- emissão de tokens;
- auditoria.

### 5.4 Frontend Web

Responsável por:

- painel administrativo;
- cadastros;
- programação de viagens;
- monitoramento;
- autorização de exceções;
- relatórios de abertura.

## 6. Princípios do projeto

1. Segurança antes de conveniência.
2. Nenhum comando crítico deve ser aceito sem autenticação.
3. O MAC é identificador, não segredo.
4. O app não deve conter uma chave universal.
5. Tokens devem ter validade curta.
6. Tokens de abertura devem ser de uso único.
7. Logs devem ser obrigatórios.
8. O modelo deve suportar múltiplas empresas e grupos econômicos.
