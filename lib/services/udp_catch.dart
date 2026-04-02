import 'dart:io';
import 'dart:convert';
import 'package:sefyra/model/payload.dart';

class UdpCatch {
  static const int _port = 28167;
  RawDatagramSocket? _socket;

  Future<void> startUdp({
    required Function(Payload) onDeviceDiscovered,
    required String ownId,
  }) async {
    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      _port,
    );
    _socket!.listen(
      (event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            final message = utf8.decode(datagram.data);
            final map = jsonDecode(message) as Map<String, dynamic>;
            final device = Payload.fromJson(map);
            if (device.deviceId == ownId) return;
            onDeviceDiscovered(device);
          }
        }
      },
    );
  }

  void stopUdp() {
    _socket?.close();
    _socket = null;
  }
}
