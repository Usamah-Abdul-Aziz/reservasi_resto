import 'package:flutter/material.dart';

// ============================================================================
// APP CONFIGURATION
// ============================================================================

/// Nama restoran (ubah sesuai kebutuhan Anda)
const String RESTAURANT_NAME = 'Restoran Kami';
const String RESTAURANT_SLOGAN = 'Cita Rasa Istimewa, Pelayanan Terbaik';
const String RESTAURANT_PHONE = '+62 812 3456 7890';
const String RESTAURANT_EMAIL = 'info@restoran.com';

// ============================================================================
// COLORS
// ============================================================================

class AppColors {
  // Primary Colors - Warm Orange (makanan/restoran)
  static const Color primary = Color(0xFFE07B39); // Warm Orange
  static const Color primaryLight = Color(0xFFFFC4A3); // Light Orange
  static const Color primaryDark = Color(0xFFC85A1A); // Dark Orange

  // Secondary Colors
  static const Color secondary = Color(0xFF2E7D32); // Green (fresh food)
  static const Color secondaryLight = Color(0xFF81C784); // Light Green

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue

  // Neutral Colors
  static const Color background = Color(0xFFFAF8F5); // Warm white/beige
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light grey
  static const Color outline = Color(0xFFE0E0E0); // Border grey

  // Text Colors
  static const Color textPrimary = Color(0xFF2C2C2C); // Dark grey
  static const Color textSecondary = Color(0xFF757575); // Medium grey
  static const Color textTertiary = Color(0xFFA0A0A0); // Light grey
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Special Colors
  static const Color spicy = Color(0xFFD32F2F); // Red for spicy indicator
  static const Color vegetarian = Color(0xFF689F38); // Green for vegetarian
  static const Color soldOut = Color(0xFF9E9E9E); // Grey for sold out

  // Legacy support
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xFF424242);
}

// ============================================================================
// TEXT STYLES
// ============================================================================

class AppTextStyles {
  // Headline Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

// ============================================================================
// SPACING
// ============================================================================

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ============================================================================
// RADIUS
// ============================================================================

class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double round = 50.0;
}

// ============================================================================
// SHADOWS
// ============================================================================

class AppShadows {
  static const BoxShadow small = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x24000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow large = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const List<BoxShadow> elevation1 = [small];
  static const List<BoxShadow> elevation2 = [medium];
  static const List<BoxShadow> elevation3 = [large];
}
