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
    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      28170,
    );

    _server!.listen((client) {
      _handleClient(client);
    });
  }

  Future<void> _handleClient(Socket client) async {
    final List<int> buffer = [];
    final List<int> headerBuffer = [];

    int? expectedSize;
    String? fileName;
    String? sender;
    bool headerDone = false;

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
          final needed = expectedSize! - buffer.length;

          final take = remaining < needed ? remaining : needed;

          buffer.addAll(data.sublist(index, index + take));
          index += take;

          progress.value = (buffer.length / expectedSize).clamp(0.0, 1.0);

          if (buffer.length == expectedSize) {
            await FileHandler().saveToDownloads(buffer, fileName!);

            _resetState(buffer);

            expectedSize = null;
            fileName = null;
            sender = null;
            headerDone = false;
          }
        }
      }
    } finally {
      await client.close();
      _resetAll();
    }
  }

  void _resetState(List<int> buffer) {
    buffer.clear();

    isTransferring.value = false;
    progress.value = 0.0;
    currentFileName.value = null;
    senderName.value = null;
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
