import 'package:file_picker/file_picker.dart';

Future<String?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    PlatformFile file = result.files.first;
    return file.name;
  }
  return null;
}
