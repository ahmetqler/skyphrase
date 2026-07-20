import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';

/// Basınca alta çöken 3B kenarlı buton. Dokunsal ve özenli bir his verir.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final base = enabled ? (widget.color ?? AppColors.primary) : AppColors.locked;
    final edge = AppColors.darken(base, 0.28);

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              SoundService.instance.playClick();
              widget.onPressed!();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: edge,
                      offset: Offset(0, _pressed ? 1 : 5),
                      blurRadius: 0,
                    ),
                  ]
                : const [],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
