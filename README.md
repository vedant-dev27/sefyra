# Sefyra

A peer-to-peer file sharing app for Android. No internet. No accounts. No cloud. Just two devices on the same network.

---

## How it works

Sefyra uses UDP broadcast for device discovery and TCP sockets for file transfer — entirely over local WiFi. Nothing leaves your network.

- Devices announce themselves over UDP
- Sender discovers nearby devices in real time
- File is streamed over a direct TCP connection
- Receiver saves to local storage

---

## Features

- Instant device discovery on local network
- Real-time transfer progress on both sender and receiver
- Random device names (e.g. *Phantom Relay*, *Cobalt Surge*)
- No backend, no accounts, no permissions beyond storage and network
- Material You theming

---

## Stack

- **Flutter** (no BLoC — state managed with `StatefulWidget` and `ValueNotifier`)
- **UDP** for device discovery
- **TCP sockets** for file transfer
- `shared_preferences` for device identity persistence
- `file_picker` for file selection

---

## Project structure

```
lib/
├── main.dart
├── model/
│   └── payload.dart          # Device info model
├── services/
│   ├── tcp_client.dart       # Sender-side TCP logic
│   ├── tcp_server.dart       # Receiver-side TCP logic
│   ├── udp_fire.dart         # UDP broadcaster (receiver)
│   ├── udp_catch.dart        # UDP listener (sender)
│   ├── device_config.dart    # Device name + ID generation
│   └── ip_config.dart        # Local IP resolution
├── pages/
│   ├── send_page.dart        # Sender UI
│   └── receive_page.dart     # Receiver UI
└── widgets/
    ├── device_card.dart
    ├── file_picker_widget.dart
    ├── loading_widget.dart    # Wavy progress indicator
    └── ripple_widget.dart     # Idle animation on receiver
```

---

## Getting started

```bash
git clone https://github.com/yourusername/sefyra.git
cd sefyra
flutter pub get
flutter run
```

Requires Android. Both devices must be on the same WiFi network.

---

## Transfer flow

```
Receiver starts UDP broadcast
Sender listens → discovers device
Sender picks file → taps device
TCP connection established
File streamed in chunks with live progress
Receiver saves file → both sides show completion
```

---

## APK size

~35MB (split APK by ABI)

---

## License

MIT