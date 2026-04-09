import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sefyra/services/file_handler.dart';

class TcpServer {
  final ValueNotifier<bool> isTransferring = ValueNotifier(false);
  final ValueNotifier<double> progress = ValueNotifier(0.0);
  final ValueNotifier<String?> currentFileName = ValueNotifier(null);
  final ValueNotifier<String?> senderName = ValueNotifier(null);

  ServerSocket? _server;
  bool _busy = false;

  Future<void> startTCP() async {
    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      28170,
    );

    _server!.listen((client) {
      if (_busy) {
        client.destroy();
        return;
      }
      _busy = true;
      _handleClient(client);
    });

    debugPrint("TCP Server started on port 28170");
  }

  Future<void> _handleClient(Socket client) async {
    IOSink? fileSink;

    try {
      final stream = client.timeout(const Duration(seconds: 30));

      final headerLengthBytes = await _readExact(stream, 4);
      final headerLength = ByteData.sublistView(
        Uint8List.fromList(headerLengthBytes),
      ).getUint32(0, Endian.big);

      final headerBytes = await _readExact(stream, headerLength);
      final headerJson = jsonDecode(utf8.decode(headerBytes));

      String fileName = _sanitizeFileName(headerJson['fileName']);
      final int fileSize = headerJson['size'];
      final String sender = headerJson['sender'];

      if (fileSize <= 0) {
        throw Exception("Invalid file size");
      }

      currentFileName.value = fileName;
      senderName.value = sender;
      progress.value = 0.0;
      isTransferring.value = true;

      final tempName = "$fileName.part";
      fileSink = await FileHandler().openSink(tempName);

      int received = 0;

      await for (final chunk in stream) {
        final remaining = fileSize - received;
        final toWrite =
            chunk.length > remaining ? chunk.sublist(0, remaining) : chunk;

        fileSink.add(toWrite);
        received += toWrite.length;

        progress.value = received / fileSize;

        if (received >= fileSize) break;
      }

      if (received != fileSize) {
        throw Exception("Transfer incomplete");
      }

      await fileSink.flush();
      await fileSink.close();
      fileSink = null;

      await FileHandler().finalizeFile(tempName, fileName);

      debugPrint("File received: $fileName");

      client.write("OK");
    } catch (e) {
      debugPrint("Transfer error: $e");

      await fileSink?.close();

      await FileHandler().cleanupTemp();

      try {
        client.write("FAILED");
      } catch (_) {}
    } finally {
      await client.close();
      _resetState();
      _busy = false;
    }
  }

  Future<List<int>> _readExact(
    Stream<List<int>> stream,
    int length,
  ) async {
    final buffer = <int>[];

    await for (final chunk in stream) {
      buffer.addAll(chunk);

      if (buffer.length >= length) {
        final result = buffer.sublist(0, length);

        return result;
      }
    }

    throw Exception("Stream ended early");
  }

  String _sanitizeFileName(String name) {
    return name.split('/').last.split('\\').last;
  }

  void _resetState() {
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
