#include <Arduino.h>
#include <NimBLEDevice.h>

#define SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define RX_UUID      "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define TX_UUID      "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

#define LED_TRAVA 8
#define LED_ATIVO_LOW false

NimBLECharacteristic* txCharacteristic = nullptr;

bool ledLigado = false;
bool pulseAtivo = false;
unsigned long pulseInicio = 0;
unsigned long pulseDuracao = 0;

void logMsg(const String& msg) {
  Serial.print("[");
  Serial.print(millis());
  Serial.print(" ms] ");
  Serial.println(msg);
  Serial.flush();
}

void writeLed(bool ligar) {
  ledLigado = ligar;

  if (LED_ATIVO_LOW) {
    digitalWrite(LED_TRAVA, ligar ? LOW : HIGH);
  } else {
    digitalWrite(LED_TRAVA, ligar ? HIGH : LOW);
  }

  logMsg(String("LED GPIO8 = ") + (ligar ? "ON" : "OFF"));
}

void sendBle(const String& msg) {
  logMsg("TX BLE: " + msg);

  if (txCharacteristic != nullptr) {
    txCharacteristic->setValue(msg.c_str());
    txCharacteristic->notify();
  }
}

void processCommand(String cmd) {
  logMsg("RX bruto: [" + cmd + "]");

  cmd.trim();
  cmd.replace("\r", "");
  cmd.replace("\n", "");
  cmd.toUpperCase();

  logMsg("RX tratado: [" + cmd + "]");

  if (cmd.startsWith("PULSE:")) {
    int tempoMs = cmd.substring(6).toInt();

    if (tempoMs <= 0) {
      tempoMs = 1200;
    }

    pulseAtivo = true;
    pulseInicio = millis();
    pulseDuracao = tempoMs;

    writeLed(true);
    sendBle("OK:PULSE:" + String(tempoMs));
    return;
  }

  if (cmd == "ON") {
    pulseAtivo = false;
    writeLed(true);
    sendBle("OK:ON");
    return;
  }

  if (cmd == "OFF") {
    pulseAtivo = false;
    writeLed(false);
    sendBle("OK:OFF");
    return;
  }

  if (cmd == "STATUS") {
    sendBle(String("STATUS:LED=") + (ledLigado ? "ON" : "OFF") +
            ";PULSE=" + (pulseAtivo ? "ON" : "OFF"));
    return;
  }

  sendBle("ERRO:COMANDO_INVALIDO:" + cmd);
}

class RxCallbacks : public NimBLECharacteristicCallbacks {
  void onWrite(NimBLECharacteristic* characteristic, NimBLEConnInfo& connInfo) override {
    std::string value = characteristic->getValue();

    logMsg("onWrite chamado. Bytes recebidos: " + String(value.length()));

    if (value.length() > 0) {
      processCommand(String(value.c_str()));
    }
  }
};

void setup() {
  Serial.begin(115200);
  delay(3000);

  logMsg("BOOT Inno Lock - BLE LED GPIO8");

  pinMode(LED_TRAVA, OUTPUT);
  writeLed(false);

  NimBLEDevice::init("");

  String mac = NimBLEDevice::getAddress().toString().c_str();
  mac.replace(":", "");
  mac.toUpperCase();

  String nomeBle = "InnoLock_" + mac;

  NimBLEDevice::deinit();
  delay(500);

  logMsg("Nome BLE: " + nomeBle);

  NimBLEDevice::init(nomeBle.c_str());
  NimBLEDevice::setPower(ESP_PWR_LVL_P9);

  NimBLEServer* server = NimBLEDevice::createServer();
  NimBLEService* service = server->createService(SERVICE_UUID);

  NimBLECharacteristic* rxCharacteristic = service->createCharacteristic(
    RX_UUID,
    NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_NR
  );

  rxCharacteristic->setCallbacks(new RxCallbacks());

  txCharacteristic = service->createCharacteristic(
    TX_UUID,
    NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
  );

  txCharacteristic->setValue("InnoLock pronto");

  server->start();

  NimBLEAdvertising* advertising = NimBLEDevice::getAdvertising();

  // Advertising simples, pois foi o que funcionou nos seus testes.
  advertising->setName(nomeBle.c_str());

  bool advOk = advertising->start();

  logMsg(String("Advertising: ") + (advOk ? "OK" : "FALHOU"));
  logMsg("Procure por: " + nomeBle);
  logMsg("Comandos BLE: PULSE:1200, ON, OFF, STATUS");
}

void loop() {
  if (pulseAtivo) {
    unsigned long decorrido = millis() - pulseInicio;

    if (decorrido >= pulseDuracao) {
      pulseAtivo = false;
      writeLed(false);
      sendBle("OK:PULSE_END");
    }
  }

  static unsigned long lastLog = 0;

  if (millis() - lastLog >= 3000) {
    lastLog = millis();

    logMsg(String("Loop ativo | LED=") +
           (ledLigado ? "ON" : "OFF") +
           " | pulseAtivo=" +
           (pulseAtivo ? "SIM" : "NAO"));
  }
}