import 'package:flutter/material.dart';
import 'package:sefyra/services/file_picker.dart';

class FilePickerPanel extends StatelessWidget {
  final String? selectedFile;
  final Function(String?) onFilePicked;

  const FilePickerPanel({
    super.key,
    required this.selectedFile,
    required this.onFilePicked,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasFile = selectedFile != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hasFile ? selectedFile!.split('/').last : "Nothing selected",
            style: text.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color:
                  hasFile ? colors.onSurface : colors.onSurface.withAlpha(80),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 20,
          ),
          FilledButton.icon(
            onPressed: () async {
              final path = await pickFile();
              onFilePicked(path);
            },
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text(
              "Choose File",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            style: FilledButton.styleFrom(
              iconSize: 24,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
