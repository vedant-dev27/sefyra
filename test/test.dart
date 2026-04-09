import 'dart:io';

class TcpClient {
  static Future<void> tcpConnect(String ipAddress) async {
    Socket socket = await Socket.connect(ipAddress, 28170);
    final bytes = await File('test.png').readAsBytes();

    socket.add(
      bytes,
    );
    socket.add(bytes);

    await socket.flush(); // send everything
    await socket.close(); // 🔥 signals completion
  }
}

void main() {
  TcpClient.tcpConnect('192.168.0.169');
}
