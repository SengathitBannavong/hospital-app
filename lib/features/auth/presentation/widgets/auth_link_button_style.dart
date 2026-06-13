import 'package:flutter/material.dart';

/// Shared style for the inline text links on the auth pages (e.g. "Quên mật
/// khẩu?", "Đăng ký ngay").
///
/// The text style is built with `inherit: false` on purpose: an inheriting
/// style gets lerped against the ambient theme during route transitions, and a
/// partial (null-field) text style can throw mid-animation. A fully-specified,
/// non-inheriting style is animation-safe.
ButtonStyle authLinkButtonStyle(
  BuildContext context, {
  bool compact = false,
  double? fontSize,
  FontWeight fontWeight = FontWeight.w600,
}) {
  return TextButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.primary,
    visualDensity: compact ? VisualDensity.compact : null,
    textStyle: TextStyle(
      inherit: false,
      fontFamily: 'Plus Jakarta Sans',
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight,
    ),
  );
}
