import 'dart:io';

class TcpReceiver {
  static const int _port = 61234;

  ServerSocket? _server;

  Future<void> start({
    required String tempDirectory,
    required Future<String> Function(String tempPath, String fileName)
        saveToDownloads,
    void Function(String fileName)? onReceiveStart,
    void Function(double progress)? onProgress,
    void Function(String filePath)? onReceiveComplete,
    void Function(Object error)? onError,
  }) async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, _port);

    _server!.listen((Socket client) async {
      List<int> headerBuffer = [];
      String? fileName;
      int? fileSize;
      IOSink? fileSink;
      int bytesReceived = 0;
      int headerLines = 0;
      String? tempPath;

      try {
        await for (final chunk in client) {
          int index = 0;

          while (headerLines < 2 && index < chunk.length) {
            final byte = chunk[index++];
            if (byte == 10) {
              final line = String.fromCharCodes(headerBuffer);
              headerBuffer.clear();
              headerLines++;

              if (headerLines == 1) {
                fileName = line;
                onReceiveStart?.call(fileName);
              } else {
                fileSize = int.parse(line);
                tempPath = '$tempDirectory/$fileName';
                fileSink = File(tempPath).openWrite();
              }
            } else {
              headerBuffer.add(byte);
            }
          }

          if (headerLines == 2 && index < chunk.length) {
            final data = chunk.sublist(index);
            fileSink!.add(data);
            bytesReceived += data.length;

            if (fileSize != null && fileSize > 0) {
              onProgress?.call(bytesReceived / fileSize);
            }
          }
        }

        await fileSink?.flush();
        await fileSink?.close();

        if (tempPath != null && fileName != null) {
          final finalPath = await saveToDownloads(tempPath, fileName);
          onReceiveComplete?.call(finalPath);
        }
      } catch (e) {
        onError?.call(e);
      } finally {
        await client.close();
      }
    });
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
  }
}
