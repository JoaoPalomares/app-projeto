import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cores extraídas do protótipo do Miaudote (Engenharia de Software II).
class AppCores {
  AppCores._();

  static const Color coral = Color(0xFFE8735A);
  static const Color verde = Color(0xFF2D7A78);
  static const Color turquesa = Color(0xFF14B8A6);
  static const Color fundo = Color(0xFFFDFBF8);
  static const Color texto = Color(0xFF1F2937);
  static const Color textoSuave = Color(0xFF6B7280);
  static const Color borda = Color(0xFFE5E7EB);
}

class AppTema {
  AppTema._();

  static ThemeData get claro {
    final borda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppCores.borda),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppCores.coral,
        primary: AppCores.coral,
        secondary: AppCores.verde,
      ),
      scaffoldBackgroundColor: AppCores.fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppCores.coral,
        foregroundColor: Colors.white, // título, seta de voltar e ícones
        surfaceTintColor: Colors.transparent, // evita o "clareamento" do M3
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light, // barra de status clara
      ),
      // Bottom sheets (detalhe do animal, filtros) e diálogos (introdução,
      // triagem) em branco, sem o tom rosado do Material 3.
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: borda,
        enabledBorder: borda,
        focusedBorder: borda.copyWith(
          borderSide: const BorderSide(color: AppCores.coral, width: 2),
        ),
        errorBorder: borda.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: borda.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppCores.coral,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppCores.coral),
      ),
    );
  }
}