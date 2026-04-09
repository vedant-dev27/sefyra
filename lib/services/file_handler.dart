import 'dart:io';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  Future<Directory> _dir() async => getTemporaryDirectory();

  Future<IOSink> openSink(String fileName) async {
    final d = await _dir();
    final name = _sanitize(fileName);
    final f = File('${d.path}/$name.part');
    if (await f.exists()) await f.delete();
    return f.openWrite();
  }

  Future<void> finalizeFile(String fileName) async {
    final d = await _dir();
    final name = _sanitize(fileName);
    final f = File('${d.path}/$name.part');
    if (!await f.exists()) throw Exception();
    await MediaStore().saveFile(
      tempFilePath: f.path,
      dirType: DirType.download,
      dirName: DirName.download,
    );
    await f.delete();
  }

  Future<void> cleanupTemp() async {
    final d = await _dir();
    final files = d.listSync();
    for (final f in files) {
      if (f.path.endsWith('.part')) {
        try {
          await File(f.path).delete();
        } catch (_) {}
      }
    }
  }

  String _sanitize(String n) => n.split('/').last.split('\\').last;
}
