import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class MizanLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDarkBackground;

  const MizanLogo({
    super.key,
    this.size = 38,
    this.showText = true,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Emblem Container with Gold Edge & Subtle Glow
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFBBF24), // Gold highlight
                Color(0xFFD97706),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.emeraldPrimary.withAlpha(90),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(1.5), // Gold outline thickness
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.26),
            child: Image.asset(
              'assets/images/mizan_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) {
                // Fallback icon if image is not loaded
                return Container(
                  color: AppTheme.emeraldDark,
                  child: const Icon(
                    Icons.balance_rounded,
                    color: AppTheme.goldBright,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ),

        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مِيزَان',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: size * 0.52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDarkBackground ? Colors.white : AppTheme.textDark,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppTheme.goldAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'الرقيب المالي الذكي',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.w600,
                      color: isDarkBackground
                          ? Colors.white.withAlpha(180)
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }
}
