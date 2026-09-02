import 'package:flutter/material.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import 'matching_engine_screen.dart';

class RequestServicePhotosScreen extends StatelessWidget {
  final Worker worker;
  const RequestServicePhotosScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Photos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add photos to help the worker understand the work needed',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _PhotoUploadTile(
                  icon: Icons.camera_alt_outlined,
                  label: 'Leaking pipe',
                  shown: true,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _PhotoUploadTile(
                  icon: Icons.add_a_photo_outlined,
                  label: 'Add photo',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _PhotoUploadTile(
                  icon: Icons.add_a_photo_outlined,
                  label: 'Add photo',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _PhotoUploadTile(
                  icon: Icons.add_a_photo_outlined,
                  label: 'Add photo',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Photos help matching engine recommend the right worker faster',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Nav.push(
                context,
                MatchingEngineScreen(worker: worker),
              ),
              child: const Text('Find Best Match'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoUploadTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool shown;

  const _PhotoUploadTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.shown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: shown
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(14),
                          ),
                        ),
                        child: Text(
                          label,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: AppColors.primary, size: 30),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
