import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ihnxiqsllbrmnvquxacc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlobnhpcXNsbGJybW52cXV4YWNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2Nzc4MjMsImV4cCI6MjA5MTI1MzgyM30.Krs3RPqwpcQFxaVFkO1omQgft-N3aWtO_7gCQumSjHY',
  );
  runApp(const ProviderScope(child: PersonaHubApp()));
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// ── Custom Color Palettes ────────────────────────────────────────────────────

const _light = ColorScheme(
  brightness: Brightness.light,

  primary:              Color(0xFF6750A4),
  onPrimary:            Color(0xFFFFFFFF),
  primaryContainer:     Color(0xFFEADDFF),
  onPrimaryContainer:   Color(0xFF21005D),

  secondary:            Color(0xFF625B71),
  onSecondary:          Color(0xFFFFFFFF),
  secondaryContainer:   Color(0xFFE8DEF8),
  onSecondaryContainer: Color(0xFF1D192B),

  tertiary:             Color(0xFF7D5260),
  onTertiary:           Color(0xFFFFFFFF),
  tertiaryContainer:    Color(0xFFFFD8E4),
  onTertiaryContainer:  Color(0xFF31111D),

  error:                Color(0xFFB3261E),
  onError:              Color(0xFFFFFFFF),
  errorContainer:       Color(0xFFF9DEDC),
  onErrorContainer:     Color(0xFF410E0B),

  surface:              Color(0xFFFEF7FF),
  onSurface:            Color(0xFF1D1B20),
  onSurfaceVariant:     Color(0xFF49454F),

  surfaceContainerLowest:  Color(0xFFFFFFFF),
  surfaceContainerLow:     Color(0xFFF7F2FA),
  surfaceContainer:        Color(0xFFF3EDF7),
  surfaceContainerHigh:    Color(0xFFECE6F0),
  surfaceContainerHighest: Color(0xFFE6E0E9),

  inverseSurface:       Color(0xFF322F35),
  onInverseSurface:     Color(0xFFF5EFF7),
  inversePrimary:       Color(0xFFD0BCFF),

  outline:              Color(0xFF79747E),
  outlineVariant:       Color(0xFFCAC4D0),

  shadow:               Color(0xFF000000),
  scrim:                Color(0xFF000000),
);

const _dark = ColorScheme(
  brightness: Brightness.dark,

  primary:              Color(0xFFD0BCFF),
  onPrimary:            Color(0xFF381E72),
  primaryContainer:     Color(0xFF4F378B),
  onPrimaryContainer:   Color(0xFFEADDFF),

  secondary:            Color(0xFFCCC2DC),
  onSecondary:          Color(0xFF332D41),
  secondaryContainer:   Color(0xFF4A4458),
  onSecondaryContainer: Color(0xFFE8DEF8),

  tertiary:             Color(0xFFEFB8C8),
  onTertiary:           Color(0xFF492532),
  tertiaryContainer:    Color(0xFF633B48),
  onTertiaryContainer:  Color(0xFFFFD8E4),

  error:                Color(0xFFF2B8B5),
  onError:              Color(0xFF601410),
  errorContainer:       Color(0xFF8C1D18),
  onErrorContainer:     Color(0xFFF9DEDC),

  surface:              Color(0xFF141218),
  onSurface:            Color(0xFFE6E0E9),
  onSurfaceVariant:     Color(0xFFCAC4D0),

  surfaceContainerLowest:  Color(0xFF0F0D13),
  surfaceContainerLow:     Color(0xFF1D1B20),
  surfaceContainer:        Color(0xFF211F26),
  surfaceContainerHigh:    Color(0xFF2B2930),
  surfaceContainerHighest: Color(0xFF36343B),

  inverseSurface:       Color(0xFFE6E0E9),
  onInverseSurface:     Color(0xFF322F35),
  inversePrimary:       Color(0xFF6750A4),

  outline:              Color(0xFF938F99),
  outlineVariant:       Color(0xFF49454F),

  shadow:               Color(0xFF000000),
  scrim:                Color(0xFF000000),
);

// ── App ──────────────────────────────────────────────────────────────────────

class PersonaHubApp extends ConsumerWidget {
  const PersonaHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PersonaHub',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(_light),
      darkTheme: _buildTheme(_dark),
      themeMode: ref.watch(themeModeProvider),
      home: const SplashScreen(),
    );
  }

  static ThemeData _buildTheme(ColorScheme s) => ThemeData(
    useMaterial3: true,
    colorScheme: s,
    scaffoldBackgroundColor: s.surface,
    shadowColor: s.shadow,
    splashColor: s.scrim.withValues(alpha: 0.12),

    appBarTheme: AppBarTheme(
      backgroundColor: s.surface,
      foregroundColor: s.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: s.shadow,
      systemOverlayStyle: s.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: s.surfaceContainer,
      indicatorColor: s.secondaryContainer,
      shadowColor: s.shadow,
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? s.onSecondaryContainer
            : s.onSurfaceVariant,
      )),
      labelTextStyle:
      WidgetStateProperty.resolveWith((states) => TextStyle(
        color: states.contains(WidgetState.selected)
            ? s.onSurface
            : s.onSurfaceVariant,
        fontSize: 12,
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w600
            : FontWeight.w400,
      )),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: s.primaryContainer,
      foregroundColor: s.onPrimaryContainer,
      elevation: 3,
    ),

    cardTheme: CardThemeData(
      color: s.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shadowColor: s.shadow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: s.outlineVariant),
      ),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: s.surfaceContainerHighest,
      hintStyle: TextStyle(color: s.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: s.primary),
      errorStyle: TextStyle(color: s.error),
      prefixIconColor: s.onSurfaceVariant,
      suffixIconColor: s.onSurfaceVariant,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: s.outline.withValues(alpha: 0.4))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: s.primary, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: s.error)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: s.errorContainer, width: 2)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: s.primary,
        foregroundColor: s.onPrimary,
        shadowColor: s.shadow,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: s.primaryContainer,
        foregroundColor: s.onPrimaryContainer,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: s.primary,
        minimumSize: const Size(64, 48),
        side: BorderSide(color: s.outline),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: s.primary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: s.surfaceContainerLow,
      selectedColor: s.secondaryContainer,
      labelStyle: TextStyle(color: s.onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: s.outlineVariant),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: s.surfaceContainerHigh,
      shadowColor: s.shadow,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28)),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: s.surfaceContainerLow,
      dragHandleColor: s.onSurfaceVariant.withValues(alpha: 0.4),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: s.inverseSurface,
      contentTextStyle: TextStyle(color: s.onInverseSurface),
      actionTextColor: s.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ),

    dividerTheme: DividerThemeData(
        color: s.outlineVariant, thickness: 1, space: 1),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected) ? s.onPrimary : s.outline),
      trackColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected)
          ? s.primary
          : s.surfaceContainerHighest),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected) ? s.primary : null),
      checkColor: WidgetStateProperty.all(s.onPrimary),
      side: BorderSide(color: s.outline, width: 1.5),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected)
          ? s.primary
          : s.onSurfaceVariant),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: s.primary,
      linearTrackColor: s.surfaceContainerHighest,
      circularTrackColor: s.surfaceContainerHighest,
    ),

    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: s.onSurfaceVariant,
      titleTextStyle: TextStyle(color: s.onSurface, fontSize: 16),
      subtitleTextStyle:
      TextStyle(color: s.onSurfaceVariant, fontSize: 13),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ),
  );
}