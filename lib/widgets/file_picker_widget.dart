import 'package:flutter/material.dart';
import 'package:sefyra/services/file_picker.dart';

class FilePickerPanel extends StatefulWidget {
  const FilePickerPanel({super.key});

  @override
  State<FilePickerPanel> createState() => _FilePickerPanelState();
}

class _FilePickerPanelState extends State<FilePickerPanel> {
  final List<Map<String, String>> _files = [];

  void _addFile(String name) {
    final isDuplicate = _files.any((f) => f["name"] == name);
    if (isDuplicate) return;
    setState(() {
      _files.add({"name": name, "type": _inferType(name)});
    });
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
  }

  String _inferType(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext)) {
      return 'image';
    }
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

  ({Color bg, Color fg, Color border}) _paletteForType(
      String type, ColorScheme colors) {
    switch (type) {
      case 'image':
        return (
          bg: const Color(0xFFE8F5E9),
          fg: const Color(0xFF2E7D32),
          border: const Color(0xFFA5D6A7),
        );
      case 'video':
        return (
          bg: const Color(0xFFFCE4EC),
          fg: const Color(0xFFC62828),
          border: const Color(0xFFF48FB1),
        );
      case 'audio':
        return (
          bg: const Color(0xFFE8EAF6),
          fg: const Color(0xFF283593),
          border: const Color(0xFF9FA8DA),
        );
      case 'pdf':
        return (
          bg: const Color(0xFFFFF3E0),
          fg: const Color(0xFFE65100),
          border: const Color(0xFFFFCC80),
        );
      default:
        return (
          bg: const Color(0xFFF3E5F5),
          fg: const Color(0xFF6A1B9A),
          border: const Color(0xFFCE93D8),
        );
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'image':
        return 'IMG';
      case 'video':
        return 'VID';
      case 'audio':
        return 'AUD';
      case 'pdf':
        return 'PDF';
      default:
        return 'FILE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasFiles = _files.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ──────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_copy_rounded,
                        size: 16, color: colors.onPrimaryContainer),
                    const SizedBox(width: 6),
                    Text(
                      'Files',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onPrimaryContainer,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (hasFiles) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_files.length}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              if (hasFiles)
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _files.clear()),
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    size: 16,
                    color: colors.error,
                  ),
                  label: Text(
                    'Clear',
                    style: TextStyle(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Color.fromARGB(
                        20,
                        (colors.error.r * 255).round(),
                        (colors.error.g * 255).round(),
                        (colors.error.b * 255).round()),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ── File list or empty state ─────────────────────────
          if (!hasFiles)
            _EmptyState(
              colors: colors,
              textTheme: textTheme,
            )
          else
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.only(
                  right: 4,
                ),
                itemCount: _files.length,
                separatorBuilder: (_, __) => const SizedBox(
                  width: 10,
                ),
                itemBuilder: (context, index) {
                  final file = _files[index];
                  final palette = _paletteForType(
                    file["type"]!,
                    colors,
                  );
                  return _FileChip(
                    name: file["name"]!,
                    icon: _iconForType(file["type"]!),
                    label: _labelForType(file["type"]!),
                    palette: palette,
                    onRemove: () => _removeFile(index),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

          // ── Primary CTA ──────────────────────────────────────
          SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: () async {
                final name = await pickFile();
                if (name != null) _addFile(name);
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 22,
              ),
              label: const Text(
                'Add Files',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ColorScheme colors;
  final TextTheme textTheme;
  const _EmptyState({required this.colors, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withAlpha(80),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_upload_outlined,
                size: 20, color: colors.onSecondaryContainer),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No files yet',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              Text(
                'Tap "Add Files" to pick something',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── File chip ────────────────────────────────────────────────────────────────

class _FileChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final String label;
  final ({Color bg, Color fg, Color border}) palette;
  final VoidCallback onRemove;

  const _FileChip({
    required this.name,
    required this.icon,
    required this.label,
    required this.palette,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 120,
          padding: const EdgeInsets.fromLTRB(
            10,
            10,
            10,
            10,
          ),
          decoration: BoxDecoration(
            color: palette.bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: palette.border,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon + type badge row
              Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: palette.fg,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: palette.fg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: palette.bg,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              // File name
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.fg,
                  height: 1.3,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // Remove button
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.errorContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 13,
                color: colors.onErrorContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
