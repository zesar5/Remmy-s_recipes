import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Remmy\'s Recipes'**
  String get appName;

  /// No description provided for @recetas.
  ///
  /// In es, this message translates to:
  /// **'Recetas'**
  String get recetas;

  /// No description provided for @noHayRecetas.
  ///
  /// In es, this message translates to:
  /// **'No hay recetas'**
  String get noHayRecetas;

  /// No description provided for @debesIniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión'**
  String get debesIniciarSesion;

  /// No description provided for @errorCargarReceta.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la receta'**
  String get errorCargarReceta;

  /// No description provided for @correoElectronico.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get correoElectronico;

  /// No description provided for @contrasena.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get contrasena;

  /// No description provided for @iniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get iniciarSesion;

  /// No description provided for @registrarse.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registrarse;

  /// No description provided for @omitir.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get omitir;

  /// No description provided for @olvidarContrasena.
  ///
  /// In es, this message translates to:
  /// **'He olvidado la contraseña'**
  String get olvidarContrasena;

  /// No description provided for @campoVacio.
  ///
  /// In es, this message translates to:
  /// **'Campo vacío'**
  String get campoVacio;

  /// No description provided for @correoVacioMsg.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce tu correo electrónico.'**
  String get correoVacioMsg;

  /// No description provided for @correoInvalido.
  ///
  /// In es, this message translates to:
  /// **'Correo inválido'**
  String get correoInvalido;

  /// No description provided for @correoInvalidoMsg.
  ///
  /// In es, this message translates to:
  /// **'El formato del correo no es válido.'**
  String get correoInvalidoMsg;

  /// No description provided for @contrasenaVaciaMsg.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce tu contraseña.'**
  String get contrasenaVaciaMsg;

  /// No description provided for @errorInicioSesion.
  ///
  /// In es, this message translates to:
  /// **'Error de inicio de sesión'**
  String get errorInicioSesion;

  /// No description provided for @credencialesIncorrectas.
  ///
  /// In es, this message translates to:
  /// **'Credenciales incorrectas.'**
  String get credencialesIncorrectas;

  /// No description provided for @errorConexion.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión'**
  String get errorConexion;

  /// No description provided for @recuperarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get recuperarContrasena;

  /// No description provided for @recuperarContrasenaMsg.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un enlace para restablecer tu contraseña.'**
  String get recuperarContrasenaMsg;

  /// No description provided for @aceptarTerminos.
  ///
  /// In es, this message translates to:
  /// **'Al hacer click, aceptas nuestros Términos de'**
  String get aceptarTerminos;

  /// No description provided for @politicaPrivacidadLogin.
  ///
  /// In es, this message translates to:
  /// **'servicio y Política de privacidad'**
  String get politicaPrivacidadLogin;

  /// No description provided for @ok.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @editarPerfil.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editarPerfil;

  /// No description provided for @descripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción:'**
  String get descripcion;

  /// No description provided for @sinDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción'**
  String get sinDescripcion;

  /// No description provided for @noRecetasGuardadas.
  ///
  /// In es, this message translates to:
  /// **'No tienes recetas guardadas'**
  String get noRecetasGuardadas;

  /// No description provided for @vistaPrincipalPerfil.
  ///
  /// In es, this message translates to:
  /// **'Vista principal del perfil.'**
  String get vistaPrincipalPerfil;

  /// No description provided for @favoritos.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favoritos;

  /// No description provided for @personas.
  ///
  /// In es, this message translates to:
  /// **'Personas'**
  String get personas;

  /// No description provided for @anadirElemento.
  ///
  /// In es, this message translates to:
  /// **'Añadir elemento desde descripción'**
  String get anadirElemento;

  /// No description provided for @abrirSelectorImagen.
  ///
  /// In es, this message translates to:
  /// **'Aquí abrirías selector de imagen'**
  String get abrirSelectorImagen;

  /// No description provided for @abrirEditarPerfil.
  ///
  /// In es, this message translates to:
  /// **'Aquí abrirías edición de perfil'**
  String get abrirEditarPerfil;

  /// No description provided for @eliminarReceta.
  ///
  /// In es, this message translates to:
  /// **'Eliminar receta'**
  String get eliminarReceta;

  /// No description provided for @confirmarEliminarReceta.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que deseas eliminar esta receta?'**
  String get confirmarEliminarReceta;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @eliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get eliminar;

  /// No description provided for @ingredientes.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes'**
  String get ingredientes;

  /// No description provided for @pasos.
  ///
  /// In es, this message translates to:
  /// **'Pasos'**
  String get pasos;

  /// No description provided for @sinTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sin título'**
  String get sinTitulo;

  /// No description provided for @anadirImagen.
  ///
  /// In es, this message translates to:
  /// **'Añadir imagen:'**
  String get anadirImagen;

  /// No description provided for @titulo.
  ///
  /// In es, this message translates to:
  /// **'Título:'**
  String get titulo;

  /// No description provided for @ingredientesLabel.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes:'**
  String get ingredientesLabel;

  /// No description provided for @ingredienteHint.
  ///
  /// In es, this message translates to:
  /// **'Ingrediente'**
  String get ingredienteHint;

  /// No description provided for @cantidadHint.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get cantidadHint;

  /// No description provided for @agregarIngrediente.
  ///
  /// In es, this message translates to:
  /// **'Agregar Ingrediente'**
  String get agregarIngrediente;

  /// No description provided for @guardarReceta.
  ///
  /// In es, this message translates to:
  /// **'Guardar Receta'**
  String get guardarReceta;

  /// No description provided for @anadirNuevaReceta.
  ///
  /// In es, this message translates to:
  /// **'Añadir Nueva Receta'**
  String get anadirNuevaReceta;

  /// No description provided for @editarReceta.
  ///
  /// In es, this message translates to:
  /// **'Editar Receta'**
  String get editarReceta;

  /// No description provided for @seleccionarAlergenos.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar alérgenos'**
  String get seleccionarAlergenos;

  /// No description provided for @aceptar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get aceptar;

  /// No description provided for @usuario.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get usuario;

  /// No description provided for @correo.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get correo;

  /// No description provided for @contrasenaRegistro.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get contrasenaRegistro;

  /// No description provided for @confirmarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmarContrasena;

  /// No description provided for @descripcionOpcional.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descripcionOpcional;

  /// No description provided for @pais.
  ///
  /// In es, this message translates to:
  /// **'País'**
  String get pais;

  /// No description provided for @seleccionarPais.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un país'**
  String get seleccionarPais;

  /// No description provided for @anioNacimiento.
  ///
  /// In es, this message translates to:
  /// **'Año nacimiento'**
  String get anioNacimiento;

  /// No description provided for @seleccionarAnio.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un año'**
  String get seleccionarAnio;

  /// No description provided for @registrarUsuarioExitoso.
  ///
  /// In es, this message translates to:
  /// **'Usuario registrado exitosamente.'**
  String get registrarUsuarioExitoso;

  /// No description provided for @agregarFotoPerfil.
  ///
  /// In es, this message translates to:
  /// **'Añadir foto de perfil'**
  String get agregarFotoPerfil;

  /// No description provided for @informacion.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get informacion;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @exito.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get exito;

  /// No description provided for @ingredientesDosPuntos.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes:'**
  String get ingredientesDosPuntos;

  /// No description provided for @pasosDosPuntos.
  ///
  /// In es, this message translates to:
  /// **'Pasos:'**
  String get pasosDosPuntos;

  /// No description provided for @recetaGuardadaExito.
  ///
  /// In es, this message translates to:
  /// **'Receta guardada con éxito'**
  String get recetaGuardadaExito;

  /// No description provided for @advertencia.
  ///
  /// In es, this message translates to:
  /// **'Advertencia'**
  String get advertencia;

  /// No description provided for @errorCamposObligatorios.
  ///
  /// In es, this message translates to:
  /// **'Error, no ha rellenado todos los campos'**
  String get errorCamposObligatorios;

  /// No description provided for @debeRellenarCampos.
  ///
  /// In es, this message translates to:
  /// **'Debe rellenar todos los campos obligatorios'**
  String get debeRellenarCampos;

  /// No description provided for @pasoHint.
  ///
  /// In es, this message translates to:
  /// **'Paso'**
  String get pasoHint;

  /// No description provided for @duracionLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración (min)'**
  String get duracionLabel;

  /// No description provided for @paisLabel.
  ///
  /// In es, this message translates to:
  /// **'País'**
  String get paisLabel;

  /// No description provided for @alergenosLabel.
  ///
  /// In es, this message translates to:
  /// **'Alérgenos'**
  String get alergenosLabel;

  /// No description provided for @estacionLabel.
  ///
  /// In es, this message translates to:
  /// **'Estación'**
  String get estacionLabel;

  /// No description provided for @agregarIngredienteBtn.
  ///
  /// In es, this message translates to:
  /// **'Agregar ingrediente'**
  String get agregarIngredienteBtn;

  /// No description provided for @agregarPasoBtn.
  ///
  /// In es, this message translates to:
  /// **'Agregar paso'**
  String get agregarPasoBtn;

  /// No description provided for @alergenosInformacion.
  ///
  /// In es, this message translates to:
  /// **'Alérgenos: '**
  String get alergenosInformacion;

  /// No description provided for @paisInformacion.
  ///
  /// In es, this message translates to:
  /// **'País: '**
  String get paisInformacion;

  /// No description provided for @duracionInformacion.
  ///
  /// In es, this message translates to:
  /// **'Duración: '**
  String get duracionInformacion;

  /// No description provided for @alergenosSinEspecificar.
  ///
  /// In es, this message translates to:
  /// **'Alérgenos: Ninguno especificado'**
  String get alergenosSinEspecificar;

  /// No description provided for @estacionInformacion.
  ///
  /// In es, this message translates to:
  /// **'Estación: '**
  String get estacionInformacion;

  /// No description provided for @creadoPor.
  ///
  /// In es, this message translates to:
  /// **'Creado por: '**
  String get creadoPor;

  /// No description provided for @debesIniciarSesionParaLike.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para dar like'**
  String get debesIniciarSesionParaLike;

  /// No description provided for @likeAnyadido.
  ///
  /// In es, this message translates to:
  /// **'Like añadido a receta'**
  String get likeAnyadido;

  /// No description provided for @likeQuitado.
  ///
  /// In es, this message translates to:
  /// **'Like quitado de receta'**
  String get likeQuitado;

  /// No description provided for @errorEliminarReceta.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar receta'**
  String get errorEliminarReceta;

  /// No description provided for @errorEliminarPorPermisos.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar receta. Verifica permisos'**
  String get errorEliminarPorPermisos;

  /// No description provided for @necesitamosPermisos.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos permiso para acceder a tus fotos'**
  String get necesitamosPermisos;

  /// No description provided for @permisosFotosBloqueado.
  ///
  /// In es, this message translates to:
  /// **'Permiso de fotos bloqueado, activalo en ajustes'**
  String get permisosFotosBloqueado;

  /// No description provided for @ajustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get ajustes;

  /// No description provided for @nombreUsuario.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario'**
  String get nombreUsuario;

  /// No description provided for @descripcionSinPuntos.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get descripcionSinPuntos;

  /// No description provided for @introduceCodigoValido.
  ///
  /// In es, this message translates to:
  /// **'Introduce un código de 6 dígitos válido'**
  String get introduceCodigoValido;

  /// No description provided for @introduceCodigo.
  ///
  /// In es, this message translates to:
  /// **'Introduce el código'**
  String get introduceCodigo;

  /// No description provided for @hemosEnviadoCodigo.
  ///
  /// In es, this message translates to:
  /// **'Hemos enviado un código a '**
  String get hemosEnviadoCodigo;

  /// No description provided for @introduceLosSeisDigitos.
  ///
  /// In es, this message translates to:
  /// **'Introduce los 6 dígitos:'**
  String get introduceLosSeisDigitos;

  /// No description provided for @verificarCodigo.
  ///
  /// In es, this message translates to:
  /// **'Verificar código'**
  String get verificarCodigo;

  /// No description provided for @volver.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get volver;

  /// No description provided for @enviarCodigo.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get enviarCodigo;

  /// No description provided for @campoRequerido.
  ///
  /// In es, this message translates to:
  /// **'Campo requerido'**
  String get campoRequerido;

  /// No description provided for @formatoInvalido.
  ///
  /// In es, this message translates to:
  /// **'Formato inválido'**
  String get formatoInvalido;

  /// No description provided for @contrasenyaCambiada.
  ///
  /// In es, this message translates to:
  /// **'Contraseña cambiada exitosamente'**
  String get contrasenyaCambiada;

  /// No description provided for @nuevaContrasenya.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get nuevaContrasenya;

  /// No description provided for @cambiarContrasenya.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get cambiarContrasenya;

  /// No description provided for @requisitosContrasenya.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un símbolo.'**
  String get requisitosContrasenya;

  /// No description provided for @debil.
  ///
  /// In es, this message translates to:
  /// **'Débil'**
  String get debil;

  /// No description provided for @contrasenyaNoCoinciden.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get contrasenyaNoCoinciden;

  /// No description provided for @noCoinciden.
  ///
  /// In es, this message translates to:
  /// **'No coinciden'**
  String get noCoinciden;

  /// No description provided for @completaTodosLosCampos.
  ///
  /// In es, this message translates to:
  /// **'Completa todos los campos'**
  String get completaTodosLosCampos;

  /// No description provided for @camposRequeridos.
  ///
  /// In es, this message translates to:
  /// **'Campos requeridos'**
  String get camposRequeridos;

  /// No description provided for @aQueIdioma.
  ///
  /// In es, this message translates to:
  /// **'¿A qué idioma quieres traducir la app?'**
  String get aQueIdioma;

  /// No description provided for @idiomaEspanyol.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get idiomaEspanyol;

  /// No description provided for @idiomaIngles.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get idiomaIngles;

  /// No description provided for @buscarReceta.
  ///
  /// In es, this message translates to:
  /// **'Buscar receta o receta por ingrediente...'**
  String get buscarReceta;

  /// No description provided for @cargarRecetasPredeterminadas.
  ///
  /// In es, this message translates to:
  /// **'Cargar recetas predeterminadas'**
  String get cargarRecetasPredeterminadas;

  /// No description provided for @aplicarFiltros.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get aplicarFiltros;

  /// No description provided for @comunidad.
  ///
  /// In es, this message translates to:
  /// **'Comunidad'**
  String get comunidad;

  /// No description provided for @idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @necesitasIniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Necesitas iniciar sesión'**
  String get necesitasIniciarSesion;

  /// No description provided for @irPaginaIniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Ir a la página de iniciar sesión'**
  String get irPaginaIniciarSesion;

  /// No description provided for @permanecerInvitado.
  ///
  /// In es, this message translates to:
  /// **'Permanecer de invitado'**
  String get permanecerInvitado;

  /// No description provided for @aceptasCondiciones.
  ///
  /// In es, this message translates to:
  /// **'Al continuar aceptas los '**
  String get aceptasCondiciones;

  /// No description provided for @terminosServicios.
  ///
  /// In es, this message translates to:
  /// **'Terminos de servicio'**
  String get terminosServicios;

  /// No description provided for @politicaPrivacidadDos.
  ///
  /// In es, this message translates to:
  /// **'Politica de privacidad'**
  String get politicaPrivacidadDos;

  /// No description provided for @cerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cerrarSesion;

  /// No description provided for @guardados.
  ///
  /// In es, this message translates to:
  /// **'Guardados'**
  String get guardados;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Casa'**
  String get home;

  /// No description provided for @terminosPolitica.
  ///
  /// In es, this message translates to:
  /// **'Términos y política'**
  String get terminosPolitica;

  /// No description provided for @parrafoUnoTerminosServicios.
  ///
  /// In es, this message translates to:
  /// **'Al utilizar esta aplicación, aceptas cumplir con estos términos. Si no estás de acuerdo con alguno de ellos, no uses la app por favor'**
  String get parrafoUnoTerminosServicios;

  /// No description provided for @parrafoDosTerminosServicios.
  ///
  /// In es, this message translates to:
  /// **'Nos reservamos el derecho de modificar o actualizar estos términos en cualquier momento.'**
  String get parrafoDosTerminosServicios;

  /// No description provided for @politicaPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get politicaPrivacidad;

  /// No description provided for @parrafoUnoPoliticaPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Tu privacidad es importante para nosotros.\nLa información personal que recopilamos se utiliza únicamente para mejorar la experiencia de usuario.'**
  String get parrafoUnoPoliticaPrivacidad;

  /// No description provided for @parrafoDosPoliticaPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'No compartimos tus datos personales con terceros sin tu consentimiento.'**
  String get parrafoDosPoliticaPrivacidad;

  /// No description provided for @contacto.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get contacto;

  /// No description provided for @parrafoUnoContacto.
  ///
  /// In es, this message translates to:
  /// **'Si tienes dudas sobre estos términos o sobre el uso de la aplicación, puedes contactarnos a través de los canales oficiales.'**
  String get parrafoUnoContacto;

  /// No description provided for @exitoBtnOk.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get exitoBtnOk;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
