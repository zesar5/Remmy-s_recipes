import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6C18C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.politicaPrivacidad,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            _SectionTittle(AppLocalizations.of(context)!.terminosServicios),
            _Paragraph(AppLocalizations.of(context)!.parrafoUnoTerminosServicios),

            SizedBox(height: 16),

            _Paragraph(AppLocalizations.of(context)!.parrafoDosTerminosServicios),

            SizedBox(height: 32),

            _SectionTittle(AppLocalizations.of(context)!.politicaPrivacidad),
            _Paragraph(AppLocalizations.of(context)!.parrafoUnoPoliticaPrivacidad),

            SizedBox(height: 16),

            _Paragraph(AppLocalizations.of(context)!.parrafoDosPoliticaPrivacidad),

            SizedBox(height: 32),

            _SectionTittle(AppLocalizations.of(context)!.contacto),
            _Paragraph(AppLocalizations.of(context)!.parrafoUnoContacto),
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
