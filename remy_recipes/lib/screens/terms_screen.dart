import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6C18C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,
        title: const Text(
          'Términos y Política',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTittle('Terminos de Servicio'),
            _Paragraph(
              'Al utilizar esta aplicación, aceptas cumplir con estos términos. '
              'Si no estás de acuerdo con alguno de ellos, no uses la app por favor',
            ),
            SizedBox(height: 16),

            _Paragraph(
              'Nos reservamos el derecho de modificar o actualizar estos términos '
              'en cualquier momento.',
            ),

            SizedBox(height: 32),

            _SectionTittle('Politica de privacidad'),
            _Paragraph(
              'Tu privacidad es importante para nosotros. '
              'La información personal que recopilamos se utiliza únicamente '
              'para mejorar la experiencia de usuario.',
            ),

            SizedBox(height: 16),

            _Paragraph(
              'No compartimos tus datos personales con terceros sin tu consentimiento.',
            ),

            SizedBox(height: 32),

            _SectionTittle('Contacto'),
            _Paragraph(
              'Si tienes dudas sobre estos términos o sobre el uso de la aplicación, '
              'puedes contactarnos a través de los canales oficiales.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTittle extends StatelessWidget {
  final String text;

  const _SectionTittle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
    );
  }
}
