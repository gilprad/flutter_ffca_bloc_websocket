import 'package:flutter/material.dart';

class AppConstant {
  static const List<String> defaultSymbols = ['ETH-USD', 'BTC-USD'];
  static const Color greenColor = Color(0xFF2ECC71);
  static const Color redColor = Color(0xFFE74C3C);
  static const double cardRadius = 12;
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(cardRadius),
  );

  static TextStyle? tableHeaderLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? errorLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.error,
    );
  }

  // Theme helpers (avoid Theme.of(context) in UI widgets)
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color onSurfaceVariant(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color outlineVariant(BuildContext context, {double alpha = 1}) {
    return Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: alpha);
  }

  static Color primary(BuildContext context, {double alpha = 1}) {
    return Theme.of(context).colorScheme.primary.withValues(alpha: alpha);
  }

  static Color secondaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  static TextStyle? labelSmall(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall;

  static TextStyle? labelMedium(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium;

  static TextStyle? labelLarge(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge;

  static TextStyle? titleSmall(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall;

  static TextStyle? titleMedium(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;

  static TextStyle? headlineSmall(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall;

  static BoxDecoration surfaceCardDecoration(
    BuildContext context, {
    double borderAlpha = 0.7,
  }) {
    return BoxDecoration(
      color: surface(context),
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(color: outlineVariant(context, alpha: borderAlpha)),
    );
  }
}
