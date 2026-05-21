# Correção NimBLE-Arduino 2.5.0

## Erro encontrado

```text
'class NimBLEAdvertising' has no member named 'setScanResponse'; did you mean 'setScanResponseData'?
```

## Causa

Na NimBLE-Arduino 2.x, o método antigo:

```cpp
advertising->setScanResponse(true);
```

foi substituído por:

```cpp
advertising->enableScanResponse(true);
```

Também foi removida a chamada `service->start();`, pois nas versões novas os serviços são inicializados junto com o servidor BLE.

## Ambiente validado para esta versão

- ESP32 Arduino Core: 3.3.8
- Placa: ESP32-C3 Dev Module
- Biblioteca: NimBLE-Arduino 2.5.0
- Arduino IDE 2.x
