import 'dart:io';
import 'package:sefyra/services/device_config.dart';

class TcpClient {
  static Future<void> tcpConnect(String ipAddress, String filePath) async {
    Socket? socket;

    try {
      socket = await Socket.connect(ipAddress, 28170);

      final file = File(filePath);
      final fileName = file.uri.pathSegments.last;
      final fileSize = await file.length();

      final deviceName = await getDeviceName();

      socket.write('$fileName|$fileSize|$deviceName\n');
      await socket.flush();

      await socket.addStream(file.openRead());

      await socket.flush();
    } finally {
      await socket?.close();
      await socket?.done;
    }
  }
}
