//Fire Broadcast
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:sefyra/model/broadcast_model.dart';

class SendBroadcast {
  static const int _port = 41234;
  static const Duration _interval = Duration(seconds: 2);

  RawDatagramSocket? _socket;
  Timer? _timer;

  Future<void> start(BroadcastModel self) async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port);
    _socket!.broadcastEnabled = true;

    final payload = utf8.encode(jsonEncode(self.toJson()));
    final target = InternetAddress('255.255.255.255');

    _timer = Timer.periodic(_interval, (_) {
      _socket?.send(payload, target, _port);
    });
  }

  void stop() {
    _timer?.cancel();
    _socket?.close();
    _socket = null;
  }
}
