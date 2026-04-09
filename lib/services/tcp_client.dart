import 'dart:io';
import 'package:sefyra/services/device_config.dart';

class TcpClient {
  static Future<void> tcpConnect(
    String ipAddress,
    String filePath, {
    void Function(int sent, int total)? onProgress,
  }) async {
    Socket? socket;
    try {
      socket = await Socket.connect(ipAddress, 28170);
      final file = File(filePath);
      final fileName = file.uri.pathSegments.last;
      final fileSize = await file.length();
      final deviceName = await getDeviceName();

      socket.write('$fileName|$fileSize|$deviceName\n');
      await socket.flush();

      int bytesSent = 0;

      await socket.addStream(
        file.openRead().map((chunk) {
          bytesSent += chunk.length;
          onProgress?.call(bytesSent, fileSize);
          return chunk;
        }),
      );

      await socket.flush();
    } finally {
      await socket?.close();
      await socket?.done;
    }
  }
}
