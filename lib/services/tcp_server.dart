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
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 28170);
    _server!.listen((client) {
      if (_busy) {
        client.destroy();
        return;
      }
      _busy = true;
      _handleClient(client);
    });
  }

  Future<void> _handleClient(Socket client) async {
    IOSink? sink;
    try {
      final reader = _Reader(client.timeout(const Duration(seconds: 30)));

      final lenBytes = await reader.read(4);
      final len = ByteData.sublistView(Uint8List.fromList(lenBytes))
          .getUint32(0, Endian.big);

      final headerBytes = await reader.read(len);
      final header = jsonDecode(utf8.decode(headerBytes));

      final fileName = _sanitize(header['fileName']);
      final size = header['size'];
      final sender = header['sender'];

      if (size <= 0) throw Exception();

      currentFileName.value = fileName;
      senderName.value = sender;
      progress.value = 0.0;
      isTransferring.value = true;

      sink = await FileHandler().openSink(fileName);

      int received = 0;

      await for (final chunk in reader.stream()) {
        final remain = size - received;
        final data = chunk.length > remain ? chunk.sublist(0, remain) : chunk;

        sink.add(data);
        received += data.length;

        progress.value = received / size;

        if (received >= size) break;
      }

      if (received != size) throw Exception();

      await sink.flush();
      await sink.close();
      sink = null;

      await FileHandler().finalizeFile(fileName);

      client.write("OK");
    } catch (_) {
      await sink?.close();
      await FileHandler().cleanupTemp();
      try {
        client.write("FAILED");
      } catch (_) {}
    } finally {
      await client.close();
      _reset();
      _busy = false;
    }
  }

  String _sanitize(String n) => n.split('/').last.split('\\').last;

  void _reset() {
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

class _Reader {
  final Stream<List<int>> _stream;
  final List<int> _buffer = [];

  _Reader(this._stream);

  Future<List<int>> read(int n) async {
    while (_buffer.length < n) {
      final chunk = await _stream.first;
      _buffer.addAll(chunk);
    }
    final out = _buffer.sublist(0, n);
    _buffer.removeRange(0, n);
    return out;
  }

  Stream<List<int>> stream() async* {
    if (_buffer.isNotEmpty) {
      yield List<int>.from(_buffer);
      _buffer.clear();
    }
    await for (final c in _stream) {
      yield c;
    }
  }
}
