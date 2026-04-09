import 'dart:io';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  Future<Directory> _getTempDir() async {
    return await getTemporaryDirectory();
  }

  Future<IOSink> openSink(String fileName) async {
    final dir = await _getTempDir();

    final safeName = _sanitize(fileName);
    final tempFile = File('${dir.path}/$safeName.part');

    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    return tempFile.openWrite();
  }

  Future<void> finalizeFile(String tempName, String finalName) async {
    final dir = await getTemporaryDirectory();

    final tempFile = File('${dir.path}/$tempName');

    if (!await tempFile.exists()) {
      throw Exception("Temp file missing");
    }

    await MediaStore().saveFile(
      tempFilePath: tempFile.path,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    await tempFile.delete();
  }

  Future<void> cleanupTemp() async {
    final dir = await _getTempDir();

    final files = dir.listSync();

    for (final f in files) {
      if (f.path.endsWith('.part')) {
        try {
          await File(f.path).delete();
        } catch (_) {}
      }
    }
  }

  String _sanitize(String name) {
    return name.split('/').last.split('\\').last;
  }
}
