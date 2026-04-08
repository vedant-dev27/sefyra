import 'package:flutter/material.dart';
import 'package:sefyra/services/file_picker.dart';

class FilePickerPanel extends StatefulWidget {
  final Function(String?) onFilePicked;

  const FilePickerPanel({
    super.key,
    required this.onFilePicked,
  });

  @override
  State<FilePickerPanel> createState() => _FilePickerPanelState();
}

class _FilePickerPanelState extends State<FilePickerPanel> {
  final List<Map<String, String>> _files = [];

  void _addFile(String path) {
    final name = path.split('/').last;

    final isDuplicate = _files.any((f) => f["path"] == path);
    if (isDuplicate) return;

    setState(() {
      _files.add({
        "name": name,
        "path": path, // 🔥 REAL DATA
        "type": _inferType(name),
      });
    });

    widget.onFilePicked(path); // 🔥 send to parent
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
  }

  String _inferType(String name) {
    final ext = name.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext))
      return 'image';
    if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return 'video';
    if (['mp3', 'wav', 'aac', 'flac'].contains(ext)) return 'audio';
    if (ext == 'pdf') return 'pdf';

    return 'other';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'audio':
        return Icons.audiotrack_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasFiles = _files.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hasFiles)
            const Text("No files selected")
          else
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _files.length,
                itemBuilder: (_, index) {
                  final file = _files[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(file["name"]!),
                      avatar: Icon(_iconForType(file["type"]!)),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => _removeFile(index),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: () async {
                final path = await pickFile();

                if (path != null) {
                  _addFile(path); // 🔥 FIXED
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Add File"),
            ),
          ),
        ],
      ),
    );
  }
}
