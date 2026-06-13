#include <Arduino.h>
#include <BleKeyboard.h>
#include <BLEDevice.h>
#include <BLESecurity.h>

// Kobo BLE page turner for Adafruit HUZZAH32 / Feather ESP32.
//
// Wiring:
// GPIO14 ---- button ---- GND   Next page
// GPIO27 ---- button ---- GND   Previous page
//
// Optional reboot button:
// GPIO32 ---- button ---- GND   Hold for 2 seconds to reboot

static const int NEXT_PIN = 14;
static const int PREV_PIN = 27;
static const int REBOOT_PIN = 32;

BleKeyboard bleKeyboard("KoboPageTurner");

static void setupBleSecurityNoMitm() {
  auto *sec = new BLESecurity();

  sec->setAuthenticationMode(ESP_LE_AUTH_BOND);
  sec->setCapability(ESP_IO_CAP_NONE);
  sec->setKeySize(16);

  sec->setInitEncryptionKey(ESP_BLE_ENC_KEY_MASK | ESP_BLE_ID_KEY_MASK);
  sec->setRespEncryptionKey(ESP_BLE_ENC_KEY_MASK | ESP_BLE_ID_KEY_MASK);
}

static bool fell(int pin) {
  static uint32_t lastPressMs[40] = {0};

  if (digitalRead(pin) == LOW) {
    uint32_t now = millis();

    if (now - lastPressMs[pin] > 250) {
      lastPressMs[pin] = now;
      return true;
    }
  }

  return false;
}

void setup() {
  Serial.begin(115200);
  delay(300);

  pinMode(NEXT_PIN, INPUT_PULLUP);
  pinMode(PREV_PIN, INPUT_PULLUP);
  pinMode(REBOOT_PIN, INPUT_PULLUP);

  Serial.println("Starting HUZZAH32 Kobo BLE page turner...");

  bleKeyboard.begin();
  setupBleSecurityNoMitm();

  Serial.println("Advertising as KoboPageTurner");
}

void loop() {
  static bool wasConnected = false;
  bool connected = bleKeyboard.isConnected();

  if (connected != wasConnected) {
    wasConnected = connected;
    Serial.println(connected ? "BLE connected" : "BLE advertising");
  }

  if (fell(NEXT_PIN)) {
    bool connectedNow = bleKeyboard.isConnected();

    Serial.print("Next page pressed, connected=");
    Serial.println(connectedNow ? "YES" : "NO");

    if (connectedNow) {
      bleKeyboard.write(KEY_RIGHT_ARROW);
      Serial.println("Sent KEY_RIGHT_ARROW");
    } else {
      Serial.println("Not sent: BLE not connected");
    }
  }

  if (fell(PREV_PIN)) {
    bool connectedNow = bleKeyboard.isConnected();

    Serial.print("Previous page pressed, connected=");
    Serial.println(connectedNow ? "YES" : "NO");

    if (connectedNow) {
      bleKeyboard.write(KEY_LEFT_ARROW);
      Serial.println("Sent KEY_LEFT_ARROW");
    } else {
      Serial.println("Not sent: BLE not connected");
    }
  }

  static uint32_t rebootDownMs = 0;

  if (digitalRead(REBOOT_PIN) == LOW) {
    if (rebootDownMs == 0) {
      rebootDownMs = millis();
    }

    if (millis() - rebootDownMs > 2000) {
      Serial.println("Rebooting...");
      delay(100);
      ESP.restart();
    }
  } else {
    rebootDownMs = 0;
  }

  delay(10);
}