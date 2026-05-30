import 'package:flutter/material.dart';
import '../../../core/config/theme_config.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool outlined;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || isDisabled;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: outlined
          ? OutlinedButton(
              onPressed: disabled ? null : onPressed,
              child: _child(),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: disabled
                    ? null
                    : const LinearGradient(
                        colors: [NearMeColors.gold, NearMeColors.goldLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: disabled ? NearMeColors.navyBorder : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: disabled
                    ? null
                    : [
                        BoxShadow(
                          color: NearMeColors.gold.withAlpha(60),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: disabled ? null : onPressed,
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.white.withAlpha(30),
                  child: Center(child: _child()),
                ),
              ),
            ),
    );
  }

  Widget _child() {
    if (isLoading) {
      return const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: outlined ? NearMeColors.gold : Colors.black,
        letterSpacing: 0.2,
      ),
    );
  }
}
