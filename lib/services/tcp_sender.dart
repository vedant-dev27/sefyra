import 'dart:io';
import 'dart:convert';

class TcpSender {
  static const int _port = 61234;
  static const Duration _timeout = Duration(seconds: 5);

  Future<void> send({
    required String ip,
    required File file,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final socket = await Socket.connect(ip, _port).timeout(_timeout);

    try {
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception("Cannot send empty file");
      }

      // ---------- HEADER ----------
      final header = utf8.encode('$fileName\n$fileSize\n');
      socket.add(header);
      await socket.flush();

      // ---------- FILE DATA ----------
      final stream = file.openRead();
      int bytesSent = 0;

      await for (final chunk in stream) {
        socket.add(chunk);
        bytesSent += chunk.length;

        if (onProgress != null) {
          onProgress(bytesSent / fileSize);
        }
      }

      await socket.flush();
    } finally {
      await socket.close();
    }
  }
}
