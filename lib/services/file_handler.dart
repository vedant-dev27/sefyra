import 'dart:io';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  Future<IOSink> openSink(String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    return file.openWrite();
  }

  Future<void> commitFromSink(String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');

    await MediaStore().saveFile(
      tempFilePath: file.path,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    if (await file.exists()) {
      await file.delete();
    }
  }
}
