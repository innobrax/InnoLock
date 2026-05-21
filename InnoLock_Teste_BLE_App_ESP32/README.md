# Inno Lock - Teste BLE App Android + ESP32-C3

Este pacote é um teste simples para validar a comunicação:

**Celular Android → Bluetooth BLE → ESP32-C3 → acionamento da trava motorizada**

O identificador do ESP32-C3 é o **MAC address**, sem dois-pontos.

Exemplo:

```text
Device ID: A1B2C3D4E5F6
Nome BLE: InnoLock_A1B2C3D4E5F6
```

## Conteúdo

```text
android-app/                 Projeto Android nativo Java
esp32/InnoLock_Teste_BLE/    Firmware Arduino para ESP32-C3 com NimBLE
docs/PROTOCOLO_BLE.md        Protocolo simples de comandos
docs/CORRECAO_GRADLE.md      Detalhes da correção do Gradle
```

## Correção aplicada nesta versão

Esta versão foi ajustada para evitar o erro:

```text
Could not find method dependencyResolutionManagement()
```

O projeto Android agora usa um formato Gradle mais compatível com instalações antigas do Android Studio.

## Firmware ESP32-C3

Biblioteca necessária na Arduino IDE:

```text
NimBLE-Arduino 2.3.7 ou superior
```

Placa sugerida:

```text
ESP32C3 Dev Module
```

Pinos usados no teste:

```text
GPIO4 = saída de acionamento para o BC547
GPIO5 = entrada de retorno/status da trava
```

Lógica:

```text
GPIO4 HIGH = BC547 conduz = fio de comando da trava aterrado
GPIO4 LOW  = comando desligado
GPIO5 LOW  = trava/êmbolo recolhido/destravado
```

## App Android

Abra no Android Studio a pasta:

```text
android-app
```

Depois execute:

```text
Build > Build Bundle(s) / APK(s) > Build APK(s)
```

O APK será gerado em:

```text
android-app/app/build/outputs/apk/debug/app-debug.apk
```

## Fluxo de teste

1. Grave o firmware no ESP32-C3.
2. Abra o Monitor Serial em 115200 bps.
3. Verifique o nome BLE anunciado, por exemplo:

```text
InnoLock_A1B2C3D4E5F6
```

4. Instale o APK no celular.
5. Conceda permissões BLE.
6. Toque em **Escanear**.
7. Selecione o dispositivo `InnoLock_...`.
8. Toque em **Conectar**.
9. Envie o comando **ACIONAR TRAVA - PULSO 1,2s**.

## Comandos BLE

O app envia comandos de texto pela característica RX do serviço Nordic UART Service.

```text
ID?
STATUS
PULSE:1200
ON
OFF
```

O ESP32-C3 responde pela característica TX com notificações BLE.


## Atualização v3 - compatibilidade Gradle 6.5

Esta versão foi ajustada para o erro:

```text
Minimum supported Gradle version is 6.7.1. Current version is 6.5.
```

Correções aplicadas:

- Android Gradle Plugin alterado para `4.1.3`.
- Projeto mantido no formato Gradle legado.
- `settings.gradle` sem `dependencyResolutionManagement()`.
- `settings.gradle` sem `pluginManagement`.
- `gradle.properties` simplificado.
- `gradle-wrapper.properties` apontando para Gradle `6.5`.

Abra a pasta `android-app` no Android Studio e gere o APK pelo menu:

```text
Build > Build Bundle(s) / APK(s) > Build APK(s)
```

## Correção v4 - NimBLE-Arduino 2.5.0

Esta versão corrige a compilação do firmware com NimBLE-Arduino 2.5.0.

Alteração principal no sketch ESP32:

```cpp
// antes
advertising->setScanResponse(true);

// agora
advertising->enableScanResponse(true);
```

Também foi removida a chamada `service->start();`, que passou a ser desnecessária nas versões novas da NimBLE-Arduino.
