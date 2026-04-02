import 'dart:io';
import 'dart:convert';
import 'package:sefyra/model/payload.dart';
import 'dart:async';

class UdpFire {
  static const int port = 28167;
  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;

  Future<void> startUdp(Payload payload) async {
    if (_socket != null) {
      return;
    }

    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
    );
    _socket!.broadcastEnabled = true;

    final jsonString = jsonEncode(
      payload.toJson(),
    );
    final bytes = utf8.encode(jsonString);

    _broadcastTimer = Timer.periodic(
      Duration(seconds: 2),
      (timer) {
        _socket?.send(
          bytes,
          InternetAddress('255.255.255.255'),
          port,
        );
      },
    );
  }

  void stopUdp() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;

    _socket?.close();
    _socket = null;
  }
}
