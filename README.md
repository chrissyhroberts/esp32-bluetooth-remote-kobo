# Kobo BLE Page Turner

A simple Bluetooth page-turning remote for Kobo e-readers built using an ESP32, two mechanical keyboard switches, and a rechargeable LiPo battery.

The device acts as a Bluetooth HID keyboard and sends left and right arrow key presses to a Kobo reader. It is designed as a compact handheld remote that can be comfortably operated using the index and middle fingers while reading.

Also works as a slide-clicker for presenting in powerpoint etc. on a laptop or phone. 

<img width="450" height="350" alt="WhatsApp Image 2026-06-16 at 10 27 49" src="https://github.com/user-attachments/assets/34cedbea-a9f3-423e-a88d-ee5cf950873f" />
<img width="300" height="350" alt="WhatsApp Image 2026-06-16 at 10 27 48 (1)" src="https://github.com/user-attachments/assets/54478aaa-7568-4d6e-9358-b1c2744bea74" />


## Demo









## Features

* Bluetooth Low Energy (BLE) HID keyboard
* Compatible with Kobo e-readers that support Bluetooth keyboards
* Two-button interface:

  * Next page
  * Previous page
* Rechargeable LiPo battery support
* USB charging via Adafruit HUZZAH32 Feather
* Mechanical keyboard switches for improved tactile feedback
* Open-source hardware and software
* Fully self-contained handheld design

## Hardware

### Current Build

| Component       | Description                                    |
| --------------- | ---------------------------------------------- |
| Microcontroller | Adafruit HUZZAH32 Feather ESP32                |
| Battery         | 3.7V LiPo (150–500 mAh recommended)            |
| Buttons         | 2 × MX-compatible mechanical keyboard switches |
| Keycaps         | Standard MX-compatible keycaps                 |
| Enclosure       | Custom 3D printed enclosure                    |
| Charging        | Integrated Feather LiPo charger                |

### Wiring

| GPIO   | Function      |
| ------ | ------------- |
| GPIO14 | Next page     |
| GPIO27 | Previous page |

Connect each switch between the GPIO pin and GND.

```text
GPIO14 ---- Switch ---- GND

GPIO27 ---- Switch ---- GND
```

No external resistors are required because the firmware uses the ESP32's internal pull-up resistors.

### Battery

The current design uses a single-cell 3.7V LiPo battery connected directly to the Feather JST connector.

Recommended capacities:

| Capacity | Notes                              |
| -------- | ---------------------------------- |
| 150 mAh  | Compact, preferred for final build |
| 300 mAh  | Good compromise                    |
| 500 mAh  | Longer runtime                     |
| 1200 mAh | Works but physically large         |

## Enclosure

The enclosure is designed around:

* Adafruit HUZZAH32 Feather
* Two MX switches mounted in a side wall
* Small LiPo battery
* USB access for charging and firmware updates

The intended grip places one long side of the enclosure against the index and middle fingers, allowing page turns without changing grip.

```text
      SW1     SW2
       ↓       ↓

 ┌──────────────────┐
 │                  │
 │  Feather + LiPo  │
 │                  │
 └──────────────────┘
```

Current design goals:

* Approximately 80 × 32 × 20 mm
* Lightweight
* Rechargeable
* One-handed operation
* Easily printable without support

## Firmware

The firmware is written using Arduino and PlatformIO.

The device advertises as:

```text
KoboPageTurner
```

and appears to the Kobo as a Bluetooth keyboard.

### Building

```bash
python3 -m platformio run -e huzzah32
```

### Uploading

```bash
python3 -m platformio run -e huzzah32 -t upload
```

### Serial Monitor

```bash
python3 -m platformio device monitor -b 115200
```

## Pairing

1. Power on the device.
2. Open Bluetooth settings on the Kobo.
3. Search for:

```text
KoboPageTurner
```

4. Pair and connect.
5. Open a book and test page turns.

## Power Management

The current firmware remains continuously connected.

Planned behaviour:

```text
Button press
    ↓
Wake ESP32
    ↓
Start BLE
    ↓
Connect to Kobo
    ↓
Remain active
    ↓
5 minutes inactivity
    ↓
Deep sleep
```

This should allow excellent battery life even with a small 150 mAh LiPo cell.

## Development History

The project was initially prototyped using an ESP32-C3 SuperMini before being migrated to an Adafruit HUZZAH32 Feather to take advantage of:

* Integrated LiPo charging
* JST battery connector
* Simplified hardware
* Easier prototyping

## Acknowledgements

### Firmware

This project builds upon and adapts the work of:

* https://github.com/tkanov/esp32-bluetooth-remote-kobo

The original project targets the Lilka ESP32 platform and demonstrates BLE page turning for Kobo devices. This project adapts the concept for the Adafruit HUZZAH32 Feather and a custom handheld enclosure.

### Enclosure

The enclosure design was inspired by:

* https://www.thingiverse.com/thing:3824089

which provided the basis for Cherry MX switch mounting and plate geometry used during enclosure development.

## License

MIT License.

This repository contains original work together with adaptations of MIT-licensed open-source software and design concepts. Attribution to upstream projects is provided in the acknowledgements section.

## Future Work

* Deep sleep support
* Wake on button press
* Battery level monitoring
* Status LED indication
* Improved enclosure ergonomics
* Smaller PCB-based hardware revision
* Optional support for additional e-reader platforms

# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog.

## [0.2.0] - 2026-06-13

### Added

* Migrated project to Adafruit HUZZAH32 Feather ESP32.
* Added support for LiPo battery operation using onboard JST connector.
* Added support for integrated USB charging via Feather hardware.
* Added custom 3D printed handheld enclosure.
* Added support for MX-compatible mechanical keyboard switches.
* Added serial debugging messages for button presses and BLE connection state.
* Added documentation and build instructions.

### Changed

* Replaced ESP32-C3 SuperMini hardware with HUZZAH32 Feather.
* Simplified hardware architecture by eliminating external charger modules.
* Updated button assignments:

  * GPIO14 → Next page
  * GPIO27 → Previous page
* Redesigned enclosure for side-mounted switch operation using index and middle fingers.
* Optimised device layout around Feather form factor and LiPo battery.

### Fixed

* Resolved BLE pairing and connection issues during migration from ESP32-C3.
* Confirmed compatibility with Kobo Bluetooth keyboard input.
* Verified HID arrow key transmission on HUZZAH32 platform.

## [0.1.0] - 2026-06-13

### Added

* Initial proof-of-concept implementation based on:

  * https://github.com/tkanov/esp32-bluetooth-remote-kobo
* BLE HID keyboard functionality.
* Kobo page-turn support using left and right arrow keys.
* ESP32-C3 SuperMini firmware build environment.
* PlatformIO build and upload workflow.
* Basic two-button operation:

  * Next page
  * Previous page
* BLE bonding and security configuration.
* Reboot button support.
* Serial status reporting.

### Hardware

* ESP32-C3 SuperMini.
* Two momentary push-buttons connected directly to GPIO inputs.
* USB-powered operation.

## Planned

### [0.3.0]

* Deep sleep support.
* Wake on button press.
* Automatic sleep after inactivity.
* Battery-life optimisation.
* Battery status indication.
* Improved enclosure ergonomics.
* Finalised printable enclosure design.
