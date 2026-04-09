import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sefyra/services/file_handler.dart';

class TcpServer {
  final ValueNotifier<bool> isTransferring = ValueNotifier(false);
  final ValueNotifier<double> progress = ValueNotifier(0.0);
  final ValueNotifier<String?> currentFileName = ValueNotifier(null);
  final ValueNotifier<String?> senderName = ValueNotifier(null);

  ServerSocket? _server;

  Future<void> startTCP() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 28170);
    _server!.listen(_handleClient);
  }

  Future<void> _handleClient(Socket client) async {
    final headerBuffer = <int>[];

    int? expectedSize;
    int received = 0;
    String? fileName;
    String? sender;
    bool headerDone = false;
    IOSink? sink;

    try {
      await for (final data in client) {
        int index = 0;

        while (index < data.length) {
          if (!headerDone) {
            if (data[index] == 10) {
              final header = String.fromCharCodes(headerBuffer).trim();
              final parts = header.split('|');

              if (parts.length != 3) {
                await client.close();
                return;
              }

              fileName = parts[0];
              expectedSize = int.tryParse(parts[1]);
              sender = parts[2];

              if (expectedSize == null || expectedSize <= 0) {
                await client.close();
                return;
              }

              sink = await FileHandler().openSink(fileName);

              headerDone = true;
              headerBuffer.clear();

              currentFileName.value = fileName;
              senderName.value = sender;
              progress.value = 0.0;
              isTransferring.value = true;

              index++;
              continue;
            }

            headerBuffer.add(data[index]);
            index++;
            continue;
          }

          final remaining = data.length - index;
          final needed = expectedSize! - received;
          final take = remaining < needed ? remaining : needed;

          sink!.add(data.sublist(index, index + take));
          received += take;
          index += take;

          progress.value = (received / expectedSize).clamp(0.0, 1.0);

          if (received == expectedSize) {
            await sink.flush();
            await sink.close();
            await FileHandler().commitFromSink(fileName!);

            sink = null;
            expectedSize = null;
            received = 0;
            fileName = null;
            sender = null;
            headerDone = false;

            _resetAll();
          }
        }
      }
    } finally {
      await sink?.close();
      await client.close();
      _resetAll();
    }
  }

  void _resetAll() {
    isTransferring.value = false;
    progress.value = 0.0;
    currentFileName.value = null;
    senderName.value = null;
  }

  Future<void> stopTCP() async {
    await _server?.close();
    _server = null;
  }
}
