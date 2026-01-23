#include <Arduino.h>
#include <lilka.h>
#include <BleKeyboard.h>
#include <esp_ota_ops.h>
#include <BLEDevice.h>
#include <BLESecurity.h>


static void setupBleSecurityNoMitm() {
  auto *sec = new BLESecurity();

  sec->setAuthenticationMode(ESP_LE_AUTH_BOND);  // most compatible

  sec->setCapability(ESP_IO_CAP_NONE);  // no input/output -> just works
  sec->setKeySize(16);

  sec->setInitEncryptionKey(ESP_BLE_ENC_KEY_MASK | ESP_BLE_ID_KEY_MASK);
  sec->setRespEncryptionKey(ESP_BLE_ENC_KEY_MASK | ESP_BLE_ID_KEY_MASK);
}


static void markOtaValidIfNeeded() {
  const esp_partition_t* running = esp_ota_get_running_partition();
  esp_ota_img_states_t state;
  if (esp_ota_get_state_partition(running, &state) == ESP_OK &&
      state == ESP_OTA_IMG_PENDING_VERIFY) {
    Serial.println("OTA: pending verify -> marking valid");
    esp_ota_mark_app_valid_cancel_rollback();
  }
}

BleKeyboard bleKeyboard("LilPageTurner");

static void draw(bool connected) {
  lilka::display.fillScreen(lilka::colors::Black);
  lilka::display.setCursor(0, 0);
  lilka::display.setTextColor(lilka::colors::White);
  lilka::display.print("PageTurner\n\n");

  lilka::display.setTextColor(connected ? lilka::colors::Green : lilka::colors::Yellow);
  lilka::display.print(connected ? "BLE: Connected\n" : "BLE: Advertising\n");

  lilka::display.setTextColor(lilka::colors::White);
  lilka::display.print("\nA/Right: Next\nB/Left: Prev\nHold SELECT: Reboot\n");

}

void setup() {
  Serial.begin(115200);
  delay(200);

  lilka::begin();

  // If your backlight is off or screen blinks, try this:
  lilka::board.disablePowerSavingMode();

  Serial.println("BLE: about to begin()");
  bleKeyboard.begin();

  setupBleSecurityNoMitm();

  markOtaValidIfNeeded();

  draw(bleKeyboard.isConnected());
}

void loop() {
  lilka::State s = lilka::controller.getState();

  // Page turns
  if (s.a.justPressed || s.right.justPressed) {
    if (bleKeyboard.isConnected()) bleKeyboard.write(KEY_RIGHT_ARROW);
  }
  if (s.b.justPressed || s.left.justPressed) {
    if (bleKeyboard.isConnected()) bleKeyboard.write(KEY_LEFT_ARROW);
  }

  // safe "exit": long-press SELECT for 1.5s, after a 2s grace period
  static uint32_t bootMs = millis();
  static uint32_t selectDownMs = 0;

  if (millis() - bootMs > 2000) {
    if (s.select.pressed) {
      if (selectDownMs == 0) selectDownMs = millis();
      if (millis() - selectDownMs > 1500) {
        ESP.restart();
      }
    } else {
      selectDownMs = 0;
    }
  }

  // UI refresh only when connection state changes
  static bool lastConnected = bleKeyboard.isConnected();
  bool currentConnected = bleKeyboard.isConnected();
  if (currentConnected != lastConnected) {
    lastConnected = currentConnected;
    draw(currentConnected);
  }

  delay(10);
}
