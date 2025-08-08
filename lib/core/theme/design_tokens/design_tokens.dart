import 'package:flutter/material.dart';

abstract class DesignTokens {
  static const double _baseUnit = 8.0;
  
  static const double spacing2xs = _baseUnit * 0.5; // 4px
  static const double spacingXs = _baseUnit; // 8px
  static const double spacingSm = _baseUnit * 2; // 16px
  static const double spacingMd = _baseUnit * 3; // 24px
  static const double spacingLg = _baseUnit * 4; // 32px
  static const double spacingXl = _baseUnit * 6; // 48px
  static const double spacing2xl = _baseUnit * 8; // 64px
  static const double spacing3xl = _baseUnit * 10; // 80px
  
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 1000.0;

  static const double elevationCard = 2.0;
  static const double elevationModal = 8.0;
  static const double elevationFab = 6.0;

  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.87;
  
  static const Duration durationFast = Duration(milliseconds: 100);
  static const Duration durationMedium = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 300);
  
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;
  
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;
  
  static const double fontSizeDisplay = 57.0;
  static const double fontSizeHeadline = 32.0;
  static const double fontSizeTitle = 22.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeLabel = 14.0;
  static const double fontSizeCaption = 12.0;
  
  static const List<BoxShadow> shadowCard = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> shadowElevated = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
