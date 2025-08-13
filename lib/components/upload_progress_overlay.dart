import 'package:flutter/material.dart';
import 'package:stolity_desktop_application/components/app_nav.dart';
import 'package:stolity_desktop_application/autotextsize.dart';

class UploadProgressItem {
  final String id;
  final String label;
  int progress; // 0..100
  UploadProgressItem({required this.id, required this.label, required this.progress});
}

class UploadProgressOverlay {
  static final UploadProgressOverlay _instance = UploadProgressOverlay._internal();
  factory UploadProgressOverlay() => _instance;
  UploadProgressOverlay._internal();

  OverlayEntry? _entry;
  final List<UploadProgressItem> _items = [];
  bool _dismissScheduled = false;

  void show() {
    if (_entry != null) return;
    _entry = OverlayEntry(builder: (context) {
      return Positioned(
        right: 12,
        bottom: 12,
        child: _UploadPanel(
          items: _items,
          onDismiss: () {
            dismiss();
          },
        ),
      );
    });
    final overlay = appNavigatorKey.currentState?.overlay;
    overlay?.insert(_entry!);
  }

  void dismiss() {
    _entry?.remove();
    _entry = null;
    _dismissScheduled = false;
    _items.clear();
  }

  void _maybeAutoDismiss() {
    if (_items.isNotEmpty && _items.every((e) => e.progress >= 100)) {
      if (_dismissScheduled) return;
      _dismissScheduled = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (_items.every((e) => e.progress >= 100)) {
          dismiss();
        } else {
          _dismissScheduled = false;
        }
      });
    }
  }

  void addOrUpdate(UploadProgressItem item) {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _items[index].progress = item.progress;
    } else {
      _items.add(item);
    }
    show();
    _entry?.markNeedsBuild();
    _maybeAutoDismiss();
  }
}

class _UploadPanel extends StatefulWidget {
  final List<UploadProgressItem> items;
  final VoidCallback onDismiss;
  const _UploadPanel({required this.items, required this.onDismiss});

  @override
  State<_UploadPanel> createState() => _UploadPanelState();
}

class _UploadPanelState extends State<_UploadPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0.04, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final int count = items.length;
    final int avg = count == 0 ? 0 : (items.map((e) => e.progress).reduce((a, b) => a + b) / count).round();
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 260,
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.black87),
                    const SizedBox(width: 6),
                    MusaffaAutoSizeText.titleSmall('Uploads', fontWeight: FontWeight.w600, color: Colors.black87),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count', style: const TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 6),
                    MusaffaAutoSizeText.labelMedium('$avg%', color: Colors.black54),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      onPressed: widget.onDismiss,
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: (avg.clamp(0, 100)) / 100,
                    backgroundColor: const Color(0xFFF3F3F3),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFAB49)),
                  ),
                ),
                const SizedBox(height: 6),
                // Single overall progress only; per-file bars removed intentionally
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final UploadProgressItem item;
  const _ProgressTile({required this.item});
  @override
  Widget build(BuildContext context) {
    final target = (item.progress.clamp(0, 100)) / 100;
    final bool isFolder = item.label.toLowerCase().startsWith('folder:');
    final bool isDone = item.progress >= 100;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isFolder ? Icons.folder_outlined : Icons.insert_drive_file_outlined,
                      size: 14, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: target),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      minHeight: 8,
                      value: value,
                      backgroundColor: const Color(0xFFF3F3F3),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFFFAB49)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        if (isDone)
          const Icon(Icons.check_circle, size: 14, color: Color(0xFF34C759))
        else
          Text('${item.progress}%', style: const TextStyle(fontSize: 11)),
      ],
    );
  }
} 