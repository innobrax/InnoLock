#include <Arduino.h>
#include <NimBLEDevice.h>
#include "esp_mac.h"

/*
  Inno Lock - Teste BLE App Android -> ESP32-C3 -> Acionamento

  Objetivo:
  - Quebrar o paradigma de conexão celular -> ESP32-C3 via Bluetooth BLE.
  - O ESP32-C3 anuncia o próprio MAC como identificador do controlador.
  - O app Android conecta via BLE e envia comandos simples.

  Biblioteca necessária na Arduino IDE:
  - NimBLE-Arduino 2.5.0 ou superior.

  Serviço BLE usado:
  - Nordic UART Service (NUS)
  - Service: 6e400001-b5a3-f393-e0a9-e50e24dcca9e
  - RX:      6e400002-b5a3-f393-e0a9-e50e24dcca9e  App -> ESP32
  - TX:      6e400003-b5a3-f393-e0a9-e50e24dcca9e  ESP32 -> App

  Comandos aceitos:
  - ID?           retorna ID:<MAC>
  - STATUS        retorna JSON com estado atual
  - PULSE:1200    aciona a trava por 1200 ms
  - ON            mantém saída acionada
  - OFF           desliga saída

  Pinos do teste atual:
  - GPIO4 = saída para base do BC547 através de resistor.
            HIGH = BC547 conduz = fio de comando da trava é aterrado.
  - GPIO5 = entrada de retorno/status da trava.
            INPUT_PULLUP, LOW = trava/êmbolo recolhido/destravado.
*/

static const char* SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
static const char* RX_UUID      = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
static const char* TX_UUID      = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

const int PIN_ACIONAMENTO = 4;
const int PIN_STATUS_TRAVA = 5;

const int CMD_ACTIVE_LEVEL = HIGH;
const int CMD_INACTIVE_LEVEL = LOW;

String deviceIdMac;
String bleDeviceName;

NimBLECharacteristic* txCharacteristic = nullptr;
NimBLEServer* bleServer = nullptr;

bool deviceConnected = false;
bool pulseActive = false;
unsigned long pulseEndMillis = 0;
unsigned long lastStatusMillis = 0;

String getMacId() {
  uint8_t mac[6];

  // Usamos o MAC base Wi-Fi STA como identificador estável do controlador.
  // Para a regra de negócio do Inno Lock, este é o device_id do ESP32.
  esp_read_mac(mac, ESP_MAC_WIFI_STA);

  char buffer[13];
  snprintf(buffer, sizeof(buffer), "%02X%02X%02X%02X%02X%02X",
           mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
  return String(buffer);
}

bool isOutputActive() {
  return digitalRead(PIN_ACIONAMENTO) == CMD_ACTIVE_LEVEL;
}

bool isLockUnlockedByFeedback() {
  return digitalRead(PIN_STATUS_TRAVA) == LOW;
}

String jsonStatus(const String& eventName) {
  String json = "{";
  json += "\"id\":\"" + deviceIdMac + "\",";
  json += "\"name\":\"" + bleDeviceName + "\",";
  json += "\"event\":\"" + eventName + "\",";
  json += "\"gpio_acionamento\":" + String(PIN_ACIONAMENTO) + ",";
  json += "\"saida_ativa\":" + String(isOutputActive() ? "true" : "false") + ",";
  json += "\"gpio_status\":" + String(PIN_STATUS_TRAVA) + ",";
  json += "\"embolo_recolhido\":" + String(isLockUnlockedByFeedback() ? "true" : "false") + ",";
  json += "\"pulse_active\":" + String(pulseActive ? "true" : "false") + ",";
  json += "\"millis\":" + String(millis());
  json += "}";
  return json;
}

void notifyBle(const String& message) {
  Serial.print("BLE TX: ");
  Serial.println(message);

  if (txCharacteristic == nullptr) return;

  txCharacteristic->setValue(message.c_str());
  txCharacteristic->notify();
}

void setOutput(bool active, const String& reason) {
  digitalWrite(PIN_ACIONAMENTO, active ? CMD_ACTIVE_LEVEL : CMD_INACTIVE_LEVEL);
  notifyBle(jsonStatus(reason));
}

void startPulse(unsigned long durationMs) {
  if (durationMs < 100) durationMs = 100;
  if (durationMs > 5000) durationMs = 5000;

  digitalWrite(PIN_ACIONAMENTO, CMD_ACTIVE_LEVEL);
  pulseActive = true;
  pulseEndMillis = millis() + durationMs;

  String msg = jsonStatus("pulse_start");
  msg.remove(msg.length() - 1);
  msg += ",\"pulse_ms\":" + String(durationMs) + "}";
  notifyBle(msg);
}

unsigned long parseDurationMs(const String& command, unsigned long defaultValue) {
  int sep = command.indexOf(':');
  if (sep < 0) sep = command.indexOf('=');
  if (sep < 0) return defaultValue;

  unsigned long value = command.substring(sep + 1).toInt();
  if (value == 0) return defaultValue;
  return value;
}

void processCommand(String command) {
  command.trim();
  if (command.length() == 0) return;

  Serial.print("BLE RX: ");
  Serial.println(command);

  String normalized = command;
  normalized.trim();
  normalized.toUpperCase();

  if (normalized == "ID?" || normalized == "ID" || normalized == "GET_ID") {
    notifyBle("ID:" + deviceIdMac);
    notifyBle(jsonStatus("id"));
    return;
  }

  if (normalized == "STATUS" || normalized == "GET_STATUS") {
    notifyBle(jsonStatus("status"));
    return;
  }

  if (normalized.startsWith("PULSE") || normalized.startsWith("ACIONAR")) {
    unsigned long durationMs = parseDurationMs(normalized, 1200);
    startPulse(durationMs);
    return;
  }

  if (normalized == "ON" || normalized == "LIGAR") {
    pulseActive = false;
    setOutput(true, "on");
    return;
  }

  if (normalized == "OFF" || normalized == "DESLIGAR") {
    pulseActive = false;
    setOutput(false, "off");
    return;
  }

  notifyBle("ERR:UNKNOWN_COMMAND:" + command);
}

class RxCallbacks : public NimBLECharacteristicCallbacks {
  void onWrite(NimBLECharacteristic* characteristic, NimBLEConnInfo& connInfo) override {
    std::string value = characteristic->getValue();
    processCommand(String(value.c_str()));
  }
};

class ServerCallbacks : public NimBLEServerCallbacks {
  void onConnect(NimBLEServer* server, NimBLEConnInfo& connInfo) override {
    deviceConnected = true;
    Serial.print("BLE conectado: ");
    Serial.println(connInfo.getAddress().toString().c_str());
  }

  void onDisconnect(NimBLEServer* server, NimBLEConnInfo& connInfo, int reason) override {
    deviceConnected = false;
    Serial.print("BLE desconectado. Motivo: ");
    Serial.println(reason);
    NimBLEDevice::startAdvertising();
  }
};

void setupBle() {
  deviceIdMac = getMacId();
  bleDeviceName = "InnoLock_" + deviceIdMac;

  NimBLEDevice::init(bleDeviceName.c_str());
  NimBLEDevice::setPower(ESP_PWR_LVL_P9);

  bleServer = NimBLEDevice::createServer();
  bleServer->setCallbacks(new ServerCallbacks());

  NimBLEService* service = bleServer->createService(SERVICE_UUID);

  txCharacteristic = service->createCharacteristic(
    TX_UUID,
    NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
  );

  NimBLECharacteristic* rxCharacteristic = service->createCharacteristic(
    RX_UUID,
    NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_NR
  );
  rxCharacteristic->setCallbacks(new RxCallbacks());

  // NimBLE-Arduino 2.x inicia os serviços automaticamente junto com o servidor.

  NimBLEAdvertising* advertising = NimBLEDevice::getAdvertising();
  advertising->addServiceUUID(SERVICE_UUID);
  advertising->setName(bleDeviceName.c_str());
  // NimBLE-Arduino 2.x: setScanResponse(true) foi substituído por enableScanResponse(true).
  advertising->enableScanResponse(true);
  advertising->start();

  Serial.println("==== Inno Lock Teste BLE ====");
  Serial.print("Device ID MAC: ");
  Serial.println(deviceIdMac);
  Serial.print("Nome BLE: ");
  Serial.println(bleDeviceName);
  Serial.print("Service UUID: ");
  Serial.println(SERVICE_UUID);
  Serial.print("GPIO acionamento: ");
  Serial.println(PIN_ACIONAMENTO);
  Serial.print("GPIO status trava: ");
  Serial.println(PIN_STATUS_TRAVA);
  Serial.println("Aguardando conexão BLE...");
}

void setup() {
  Serial.begin(115200);
  delay(300);

  pinMode(PIN_ACIONAMENTO, OUTPUT);
  digitalWrite(PIN_ACIONAMENTO, CMD_INACTIVE_LEVEL);

  pinMode(PIN_STATUS_TRAVA, INPUT_PULLUP);

  setupBle();
}

void loop() {
  if (pulseActive && (long)(millis() - pulseEndMillis) >= 0) {
    pulseActive = false;
    digitalWrite(PIN_ACIONAMENTO, CMD_INACTIVE_LEVEL);
    notifyBle(jsonStatus("pulse_end"));
  }

  if (deviceConnected && millis() - lastStatusMillis >= 5000) {
    lastStatusMillis = millis();
    notifyBle(jsonStatus("heartbeat"));
  }

  delay(10);
}
