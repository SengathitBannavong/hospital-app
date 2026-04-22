import 'package:flutter/material.dart';
import '../theme/hospital_theme.dart';

class MedicalInfoCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const MedicalInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  State<MedicalInfoCard> createState() => _MedicalInfoCardState();
}

class _MedicalInfoCardState extends State<MedicalInfoCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.color ?? context.colorScheme.primary;
    final scale = _isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTapDown: widget.onTap != null
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.onTap != null
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: widget.onTap != null
            ? () => setState(() => _isPressed = false)
            : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          curve: const Cubic(0.25, 1, 0.5, 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: AppSpacing.cardPaddingLarge,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: _isHovered
                    ? primaryColor.withValues(alpha: 0.5)
                    : context.colorScheme.outlineVariant,
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : AppShadows.card,
            ),
            child: Row(
              children: [
                // Icon Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? primaryColor.withValues(alpha: 0.15)
                        : primaryColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(widget.icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: context.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isHovered
                              ? primaryColor
                              : context.colorScheme.onSurface,
                        ),
                        child: Text(widget.value),
                      ),
                    ],
                  ),
                ),
                // Trailing arrow if clickable
                if (widget.onTap != null)
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.only(
                      right: _isHovered ? 0 : 4.0,
                      left: _isHovered ? 4.0 : 0,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: _isHovered
                          ? primaryColor
                          : context.colorScheme.outline,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
