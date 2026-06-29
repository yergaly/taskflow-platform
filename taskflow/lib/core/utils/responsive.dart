import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  static ScreenSize screenSizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return ScreenSize.desktop;
    if (width >= tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.desktop;

  static int columnsFor(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    return switch (screenSizeOf(context)) {
      ScreenSize.mobile => mobile,
      ScreenSize.tablet => tablet,
      ScreenSize.desktop => desktop,
    };
  }

  static EdgeInsets pagePaddingOf(BuildContext context) {
    final size = screenSizeOf(context);
    final horizontal = switch (size) {
      ScreenSize.mobile => AppSpacing.pagePadding,
      ScreenSize.tablet => AppSpacing.lg,
      ScreenSize.desktop => AppSpacing.xl,
    };
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: AppSpacing.lg);
  }

  static Widget constrainedContent({
    required Widget child,
    double maxWidth = AppSpacing.maxContentWidth,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
