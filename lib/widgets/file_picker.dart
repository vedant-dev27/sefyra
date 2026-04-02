import 'package:flutter/material.dart';

class FilePickerPanel extends StatefulWidget {
  const FilePickerPanel({super.key});

  @override
  State<FilePickerPanel> createState() => _FilePickerPanelState();
}

class _FilePickerPanelState extends State<FilePickerPanel> {
  final List<Map<String, String>> _files = [];

  void _addDummyFile() {
    setState(() {
      _files.add({
        "name": "file_${_files.length + 1}.jpg",
        "type": "image",
      });
    });
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.onSurface.withOpacity(0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // File chips / empty state
          if (_files.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.folder_open_rounded,
                      size: 18, color: colors.onSurface.withOpacity(0.35)),
                  const SizedBox(width: 8),
                  Text('No files selected',
                      style: textTheme.bodySmall
                          ?.copyWith(color: colors.onSurface.withOpacity(0.4))),
                ],
              ),
            )
          else
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _files.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(_iconForType(file["type"]!),
                                size: 20, color: colors.primary),
                            const SizedBox(height: 6),
                            Text(file["name"]!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colors.onSurface)),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -6,
                        top: -6,
                        child: GestureDetector(
                          onTap: () => _removeFile(index),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: colors.onSurface.withOpacity(0.15),
                            child: Icon(Icons.close_rounded,
                                size: 14,
                                color: colors.onSurface.withOpacity(0.6)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          // Add file button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _addDummyFile,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Files'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
