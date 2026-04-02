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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),

        // ✅ Replace shadow with subtle divider
        border: Border(
          top: BorderSide(
            color: colors.onSurface.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ❌ REMOVE THIS (fake drag handle)
          // Container(...)

          // File list
          if (_files.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No files selected",
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            )
          else
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];

                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // 🔥 reduce heavy blue
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file["type"]!,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              file["name"]!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _removeFile(index),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addDummyFile,
              icon: const Icon(Icons.add),
              label: const Text("Add File"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
