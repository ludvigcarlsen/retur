import 'package:flutter/material.dart';

/// Single source of truth for the app's colors. Standard Material roles live on
/// the [ColorScheme]; colors without a standard role live on [AppColors]. Read
/// them via `Theme.of(context)` — don't hard-code colors elsewhere so that
/// light/alternate themes can swap them later.

const _accent = Color(0xFF519AFF); // brand blue
const _accentFill =
    Color(0xFF7BAEF5); // filled accent surfaces (buttons, pills)
const _surface = Color(0xFF212025); // page / sheet background
const _card = Color(0xFF37373F); // raised cards
const _muted = Color(0xFF464F64); // low-emphasis filled buttons
const _divider = Color(0xFF4D4E5B); // hairline rails / separators
const _skeleton = Color(0xFF404149); // loading placeholders

/// Colors that don't map onto a standard [ColorScheme] role.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accentFill,
    required this.skeleton,
  });

  final Color accentFill;
  final Color skeleton;

  /// Always non-null: falls back to the default palette if a sub-tree's theme
  /// doesn't carry the extension.
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? _appColors;

  @override
  AppColors copyWith({Color? accentFill, Color? skeleton}) {
    return AppColors(
      accentFill: accentFill ?? this.accentFill,
      skeleton: skeleton ?? this.skeleton,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      accentFill: Color.lerp(accentFill, other.accentFill, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
    );
  }
}

const _scheme = ColorScheme.dark(
  primary: _accent,
  surface: _surface,
  surfaceContainerHighest: _card,
  secondaryContainer: _muted,
  outlineVariant: _divider,
);

const _appColors = AppColors(
  accentFill: _accentFill,
  skeleton: _skeleton,
);

ThemeData get appTheme => ThemeData(
      useMaterial3: true,
      fontFamily: 'TID',
      colorScheme: _scheme,
      scaffoldBackgroundColor: _scheme.surface,
      primaryColor: _scheme.surface,
      extensions: const [_appColors],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor:
              WidgetStatePropertyAll(_accentFill.withValues(alpha: 50 / 255)),
          foregroundColor: const WidgetStatePropertyAll(_accent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
      // top bar blends with the page (no M3 surface tint), like the navbar
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
