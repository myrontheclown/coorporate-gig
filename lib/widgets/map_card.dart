import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../theme/app_theme.dart';
import 'circle_avatar.dart';

/// Mock map placeholder card with worker markers.
///
/// Architected so a real map provider (Google Maps / OSM) can replace the
/// inner content later while keeping the same visual contract.
class MapCard extends StatelessWidget {
  final List<Worker> workers;
  final Worker? selectedWorker;
  final VoidCallback? onViewProfile;

  const MapCard({
    super.key,
    required this.workers,
    this.selectedWorker,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Stack(
        children: [
          // Mock map background
          Positioned.fill(
            child: CustomPaint(painter: _MapGridPainter()),
          ),
          // Map controls
          Positioned(
            right: 12,
            top: 12,
            child: Column(
              children: [
                _MapButton(icon: Icons.add, onTap: () {}),
                const SizedBox(height: 6),
                _MapButton(icon: Icons.remove, onTap: () {}),
                const SizedBox(height: 6),
                _MapButton(icon: Icons.my_location, onTap: () {}),
              ],
            ),
          ),
          // Worker markers
          for (var i = 0; i < workers.take(5).length; i++)
            Positioned(
              left: 28 + (i * 44) % 220,
              top: 26 + (i * 37) % 120,
              child: _MarkerDot(
                worker: workers[i],
                selected: workers[i].id == selectedWorker?.id,
              ),
            ),
          // My location pin
          Positioned(
            left: 32,
            bottom: 26,
            child: const Icon(
              Icons.my_location,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          // Selected worker floating card
          if (selectedWorker != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _SelectedWorkerCard(
                worker: selectedWorker!,
                onViewProfile: onViewProfile,
              ),
            ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD8DEE6)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _MarkerDot extends StatelessWidget {
  final Worker worker;
  final bool selected;
  const _MarkerDot({required this.worker, required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : worker.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x44000000), blurRadius: 4),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          worker.avatarInitials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SelectedWorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback? onViewProfile;
  const _SelectedWorkerCard({
    required this.worker,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatarImage(
              initials: worker.avatarInitials,
              color: worker.color,
              size: 40,
              online: worker.available,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${worker.profession} • ★ ${worker.ratingLabel} • ${worker.experience}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onViewProfile,
              child: const Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }
}