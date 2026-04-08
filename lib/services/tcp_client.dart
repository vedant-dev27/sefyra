import 'dart:io';

class TcpClient {
  static Future<void> tcpConnect(String ipAddress, String filePath) async {
    Socket? socket;

    try {
      socket = await Socket.connect(ipAddress, 28170);

      final file = File(filePath);
      final fileName = file.uri.pathSegments.last;
      final size = await file.length();

      print("Connecting to $ipAddress");
      print("Sending: $fileName ($size bytes)");

      // 🔹 Send header
      socket.write('$fileName|$size\n');
      await socket.flush();

      // 🔹 Send file stream
      await socket.addStream(file.openRead());

      // 🔹 Final flush
      await socket.flush();

      print("File sent successfully");
    } catch (e) {
      print("TCP CLIENT ERROR: $e");
    } finally {
      await socket?.close();
      await socket?.done;
    }
  }
}
