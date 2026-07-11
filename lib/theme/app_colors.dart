// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ── Fondos (paleta oficial) ──────────────────────────────
  static const Color background  = Color(0xFF121212); // 🖤 Fondo
  static const Color surface     = Color(0xFF2B2B2B); // ⬛ Tarjetas
  static const Color surface2    = Color(0xFF3D3D3D); // ⚠️ Provisional: no está en la paleta oficial

  // ── Morados (paleta oficial) ─────────────────────────────
  static const Color accent      = Color(0xFFA83DE8); // 🟣 Morado principal
  static const Color accentDark  = Color(0xFF8A2BE2); // 🟪 Morado oscuro
  static const Color onAccent    = Color(0xFFFFFFFF); // Blanco sobre morado

  // ⚠️ Provisional: usado en gradientes (users_admin_screen.dart) pero
  // NO está en tu paleta oficial. Dime el hex exacto si lo tienes definido,
  // o si prefieres que las gradientes usen accentDark en su lugar.
  static const Color accentLight = Color(0xFFC070F0);

  // ── Estados (paleta oficial) ─────────────────────────────
  static const Color success     = Color(0xFF34C759); // 🟢 Verde
  static const Color error       = Color(0xFFE74C3C); // 🔴 Rojo
  static const Color warning     = Color(0xFFF4C542); // 🟡 Amarillo

  // ⚠️ Provisional: usado en KPI "Categorías activas" (dashboard_screen.dart)
  // pero NO está en tu paleta oficial. Dime el hex exacto o si prefieres
  // reemplazarlo por accent/accentDark.
  static const Color info        = Color(0xFF3498DB);

  // ── Texto / iconos (paleta oficial) ──────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF); // ⚪ Blanco
  static const Color textSecondary = Color(0xFFBDBDBD); // ⚫ Gris claro
  static const Color textFaint     = Color(0xFF8E8E93); // ⚙️ Gris iconos

  // ── Bordes ────────────────────────────────────────────────
  // ⚠️ Provisional: no están en la paleta oficial (derivados del fondo/tarjetas)
  static const Color border      = Color(0xFF424242);
  static const Color borderLight = Color(0xFF535353);
}