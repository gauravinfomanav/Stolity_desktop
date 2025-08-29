import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stolity_desktop_application/Constants.dart';
import 'package:stolity_desktop_application/controllers/user_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _email;
  UserFolderSize? _folderSize;
  bool _loading = true;

  static const int kPlanBytes = 5 * 1024 * 1024 * 1024; // 5 GB

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    final res = await UserController().getUserFolderSize(context);
    setState(() {
      _email = email;
      _folderSize = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFFFFAB49);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildProfileCard(primary),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStorageCard(primary),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14505050), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(color: primary, width: 4),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontFamily: Constants.FONT_DEFAULT_NEW, color: Colors.black),
                    children: const [
                      TextSpan(text: 'User Permission: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22, color: Color(0xFFFFAB49))),
                      TextSpan(text: 'View Only', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, color: Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Email: ${_email ?? '-'}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Mobile:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), side: BorderSide(color: primary)),
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFCD2D2D), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      child: const Text('Delete Account'),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStorageCard(Color primary) {
    final int usedBytes = _folderSize?.sizeInBytes ?? 0;
    final double usedPercent = (usedBytes / kPlanBytes).clamp(0.0, 1.0);
    final String usedLabel = _folderSize?.totalSize.isNotEmpty == true ? _folderSize!.totalSize : _formatBytes(usedBytes);
    final String remainingLabel = _formatBytes(kPlanBytes - usedBytes);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14505050), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                height: 220,
                width: 220,
                child: _RadialProgress(
                  progress: usedPercent,
                  color: primary,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Storage Used', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text('$usedLabel / 5 GB', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87)),
                    const SizedBox(height: 24),
                    const Text('Storage Remaining', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text('$remainingLabel / 5 GB', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(bytes) / math.log(1024)).floor();
    final size = bytes / math.pow(1024, i);
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }
}

class _RadialProgress extends StatelessWidget {
  final double progress; // 0..1
  final Color color;
  const _RadialProgress({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadialPainter(progress: progress, color: color),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Used', style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RadialPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 18.0;
    final Rect rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - stroke;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFF4EDE6);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;

    canvas.drawCircle(center, radius, bg);

    final sweep = 2 * math.pi * progress;
    final start = -math.pi / 2;
    final rectArc = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rectArc, start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RadialPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}


