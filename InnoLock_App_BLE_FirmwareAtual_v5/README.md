# Inno Lock - App Android BLE v5

Versão ajustada para o firmware atual do ESP32-C3.

## Mudança principal

O app **não filtra mais o scan pelo Service UUID**.

O firmware atual anuncia apenas o nome BLE:

```text
InnoLock_<MAC>
```

Por isso o app faz:

1. scan BLE aberto, sem filtro de UUID;
2. filtra na aplicação apenas nomes que começam com `InnoLock_`;
3. conecta no dispositivo selecionado;
4. executa `discoverServices()`;
5. procura o Nordic UART Service internamente após a conexão;
6. envia comandos para a characteristic RX.

## UUIDs usados

```text
SERVICE_UUID = 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
RX_UUID      = 6E400002-B5A3-F393-E0A9-E50E24DCCA9E
TX_UUID      = 6E400003-B5A3-F393-E0A9-E50E24DCCA9E
```

## Comandos

```text
PULSE:1200
ON
OFF
STATUS
```

## Como compilar

Abra a pasta:

```text
android-app
```

No Android Studio, use:

```text
Build > Build Bundle(s) / APK(s) > Build APK(s)
```

## Compatibilidade

Projeto mantido no formato Gradle legado:

```text
Android Gradle Plugin 4.1.3
Gradle 6.5
compileSdkVersion 33
```

## Observação

Ao conectar, o app envia automaticamente `STATUS` para validar a comunicação.
