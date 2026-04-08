import 'dart:io';
import 'package:sefyra/services/file_handler.dart';

class TcpServer {
  static ServerSocket? _server;

  static Future<void> startTCP() async {
    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      28170,
    );

    print("TCP Server started on port 28170");

    _server!.listen((client) {
      _handleClient(client);
    }, onError: (error) {
      print("TCP SERVER ERROR: $error");
    });
  }

  static Future<void> _handleClient(Socket client) async {
    print("Client connected: ${client.remoteAddress.address}");

    List<int> buffer = [];
    List<int> headerBuffer = [];
    int? expectedSize;
    String? fileName;
    bool headerDone = false;

    try {
      await for (final data in client) {
        int index = 0;

        while (index < data.length) {
          // 🔹 READ HEADER
          if (!headerDone) {
            if (data[index] == 10) {
              final header = String.fromCharCodes(headerBuffer).trim();

              print("HEADER: $header");

              final parts = header.split('|');

              if (parts.length != 2) {
                print("INVALID HEADER FORMAT");
                await client.close();
                return;
              }

              fileName = parts[0];
              expectedSize = int.tryParse(parts[1]);

              if (expectedSize == null || expectedSize < 0) {
                print("INVALID SIZE");
                await client.close();
                return;
              }

              headerDone = true;
              headerBuffer.clear();
              index++;
              continue;
            }

            headerBuffer.add(data[index]);
            index++;
            continue;
          }

          // 🔹 READ FILE DATA
          final remainingBytes = data.length - index;
          final bytesNeeded = expectedSize! - buffer.length;

          final bytesToTake =
              remainingBytes < bytesNeeded ? remainingBytes : bytesNeeded;

          buffer.addAll(data.sublist(index, index + bytesToTake));
          index += bytesToTake;

          // 🔹 FILE COMPLETE
          if (buffer.length == expectedSize) {
            try {
              await FileHandler().saveToDownloads(buffer, fileName!);
              print("File received: $fileName");
            } catch (e) {
              print("SAVE ERROR: $e");
            }

            // reset for next file
            buffer.clear();
            expectedSize = null;
            fileName = null;
            headerDone = false;
          }
        }
      }
    } catch (e) {
      print("CLIENT STREAM ERROR: $e");
    } finally {
      await client.close(); // ✅ graceful close
      print("Client disconnected");
    }
  }

  static Future<void> stopTCP() async {
    await _server?.close();
    _server = null;
  }
}
