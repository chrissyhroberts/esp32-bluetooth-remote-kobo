#include <Arduino.h>
#include <BleKeyboard.h>
#include <BLEDevice.h>
#include <BLESecurity.h>
#include "esp_sleep.h"

static const int NEXT_PIN = 14;
static const int PREV_PIN = 27;

static const uint32_t SLEEP_AFTER_MS = 5UL * 60UL * 1000UL;

BleKeyboard bleKeyboard("KoboPageTurner");

static uint32_t lastActivityMs = 0;

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
      lastActivityMs = now;
      return true;
    }
  }

  return false;
}

static void goToSleep() {
  Serial.println("Sleeping after inactivity...");
  delay(100);

  // Wake when either button is pressed.
  // Buttons are INPUT_PULLUP, so press = LOW.
  esp_sleep_enable_ext0_wakeup((gpio_num_t)NEXT_PIN, 0);

  // Note: ESP32 ext0 supports one wake pin only.
  // For now, NEXT wakes the device.
  // We can add both buttons with ext1 if needed.

  esp_deep_sleep_start();
}

void setup() {
  Serial.begin(115200);
  delay(300);

  pinMode(NEXT_PIN, INPUT_PULLUP);
  pinMode(PREV_PIN, INPUT_PULLUP);

  lastActivityMs = millis();

  Serial.println("Starting HUZZAH32 Kobo BLE page turner...");
  Serial.println("First press after sleep wakes only; subsequent presses turn pages.");

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
    lastActivityMs = millis();
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

  if (millis() - lastActivityMs > SLEEP_AFTER_MS) {
    goToSleep();
  }

  delay(10);
}