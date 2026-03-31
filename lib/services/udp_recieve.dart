// receive_broadcast.dart
import 'dart:io';
import 'dart:convert';
import 'package:sefyra/model/broadcast_model.dart';

class ReceiveBroadcast {
  static const int _port = 41234;

  RawDatagramSocket? _socket;

  Future<void> start({
    required void Function(BroadcastModel peer) onPeerFound,
  }) async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port);
    _socket!.broadcastEnabled = true;

    _socket!.listen((RawSocketEvent event) {
      if (event != RawSocketEvent.read) return;

      final datagram = _socket?.receive();
      if (datagram == null) return;

      try {
        final raw = utf8.decode(datagram.data);
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final peer = BroadcastModel(
          deviceId: json['deviceId'],
          deviceName: json['deviceName'],
          ipAddress: json['ipAddress'],
        );
        onPeerFound(peer);
      } catch (e) {
        // malformed packet, ignore
      }
    });
  }

  void stop() {
    _socket?.close();
    _socket = null;
  }
}
