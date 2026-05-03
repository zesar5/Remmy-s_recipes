import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Widget reutilizable para botón "Cargar más"
/// Se coloca al final de una ListView.builder
class CargarMasButton extends StatefulWidget {
  final VoidCallback onPresionado;
  final bool estaCargando;
  final bool hayMas;
  final int elementosActuales;
  final int totalElementos;

  const CargarMasButton({
    Key? key,
    required this.onPresionado,
    required this.estaCargando,
    required this.hayMas,
    required this.elementosActuales,
    required this.totalElementos,
  }) : super(key: key);

  @override
  State<CargarMasButton> createState() => _CargarMasButtonState();
}

class _CargarMasButtonState extends State<CargarMasButton> {
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    // No mostrar si no hay más elementos
    if (!widget.hayMas) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Se han cargado todos los elementos (${widget.elementosActuales}/${widget.totalElementos})',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: widget.estaCargando ? null : widget.onPresionado,
          icon: widget.estaCargando
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : const Icon(Icons.expand_more),
          label: Text(
            widget.estaCargando
                ? 'Cargando...'
                : 'Cargar más (${widget.elementosActuales}/${widget.totalElementos})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDEB887),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar mensaje de error en la carga
class ErrorCargarMas extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const ErrorCargarMas({
    Key? key,
    this.mensaje = 'Error al cargar más elementos',
    required this.onReintentar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onReintentar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
