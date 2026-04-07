import 'dart:io';

Future<void> main() async {
  const host = "172.16.146.36"; // 🔁 your laptop IP
  const port = 28168;
  final socket = await Socket.connect(host, port);

  // print("Connected to server");

  for (int i = 0; i < 5; i++) {
    String message = "Hello $i";
    // print("Sending: $message");
    socket.write(message);
    await Future.delayed(Duration(seconds: 1));
  }
}
