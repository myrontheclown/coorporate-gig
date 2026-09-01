import 'package:flutter/material.dart';

class CircleAvatarImage extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  final bool online;

  const CircleAvatarImage({
    super.key,
    required this.initials,
    required this.color,
    this.size = 48,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              color: color,
              fontSize: size * 0.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
