import 'package:flutter/material.dart';
import 'package:remy_recipes/l10n/app_localizations.dart';

// ==========================================================================
//          DIÁLOGO DE SESIÓN CADUCADA
// ==========================================================================

class SessionExpiredDialog {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLoginTapped,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // No permitir cerrar con tap fuera
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.lock_clock,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)?.sesionCaducada ?? 'Sesión caducada',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)?.sesionCaducadaMsg ??
                'Tu sesión ha expirado por inactividad. Por favor, inicia sesión nuevamente para continuar.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Cerrar diálogo
                  onLoginTapped(); // Ejecutar callback
                },
                icon: const Icon(Icons.login),
                label: Text(
                  AppLocalizations.of(context)?.irAlLogin ?? 'Ir al login',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9A56),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
