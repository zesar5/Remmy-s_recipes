import 'package:flutter/widgets.dart';

class AppStrings {
  //APP
  static const appName = "Remmy's Recipes";

  //HOME
  static const recetas = "Recetas";
  static const noHayRecetas = "No hay recetas";
  static const debesIniciarSesion = "Debes iniciar sesión";
  static const errorCargarReceta = "No se pudo cargar la receta";

  //LOGIN
  static const correoElectronico = "Correo electrónico";
  static const contrasena = "Contraseña";
  static const iniciarSesion = "Iniciar sesión";
  static const registrarse = "Registrarse";
  static const omitir = "Omitir";
  static const olvidarContrasena = "He olvidado la contraseña";

  static const campoVacio = "Campo vacío";
  static const correoVacioMsg = "Por favor, introduce tu correo electrónico.";
  static const correoInvalido = "Correo inválido";
  static const correoInvalidoMsg = "El formato del correo no es válido.";
  static const contrasenaVaciaMsg = "Por favor, introduce tu contraseña.";
  static const errorInicioSesion = "Error de inicio de sesión";
  static const credencialesIncorrectas = "Credenciales incorrectas.";
  static const errorConexion = "Error de conexión";

  static const recuperarContrasena = "Recuperar contraseña";
  static const recuperarContrasenaMsg =
      "Te enviaremos un enlace para restablecer tu contraseña.";

  static const aceptarTerminos = "Al hacer click, aceptas nuestros Términos de";
  static const politicaPrivacidad = "servicio y Política de privacidad";

  static const ok = "OK";

  //PERFIL
  static const editarPerfil = "Editar perfil";
  static const descripcion = "Descripción:";
  static const sinDescripcion = "Sin descripción";
  static const noRecetasGuardadas = "No tienes recetas guardadas";
  static const vistaPrincipalPerfil = "Vista principal del perfil.";
  static const favoritos = "Favoritos";
  static const personas = "Personas";
  static const anadirElemento = "Añadir elemento desde descripción";

  static const abrirSelectorImagen = "Aquí abrirías selector de imagen";
  static const abrirEditarPerfil = "Aquí abrirías edición de perfil";

  //DETALLE RECETA
  static const eliminarReceta = "Eliminar receta";
  static const confirmarEliminarReceta =
      "¿Seguro que deseas eliminar esta receta?";
  static const cancelar = "Cancelar";
  static const eliminar = "Eliminar";
  static const ingredientes = "Ingredientes";
  static const pasos = "Pasos";

  //MODELOS
  static const sinTitulo = "Sin título";

  static const anadirImagen = "Añadir imagen:";
  static const titulo = "Título:";
  static const ingredientesLabel = "Ingredientes:";
  static const ingredienteHint = "Ingrediente";
  static const cantidadHint = "Cantidad";
  static const agregarIngrediente = "Agregar Ingrediente";
  static const guardarReceta = "Guardar Receta";
  static const anadirNuevaReceta = "Añadir Nueva Receta";
  static const editarReceta = "Editar Receta";
  static const seleccionarAlergenos = "Seleccionar alérgenos";
  static const aceptar = "Aceptar";

  // REGISTRO
  static const usuario = "Usuario";
  static const correo = "Correo electrónico";
  static const contrasenaRegistro = "Contraseña";
  static const confirmarContrasena = "Confirmar contraseña";
  static const descripcionOpcional = "Descripción (opcional)";
  static const pais = "País";
  static const seleccionarPais = "Selecciona un país";
  static const anioNacimiento = "Año nacimiento";
  static const seleccionarAnio = "Selecciona un año";
  static const registrarUsuarioExitoso = "Usuario registrado exitosamente.";
  static const agregarFotoPerfil = "Añadir foto de perfil";
  static const informacion = "Información";
  static const error = "Error";

  //Color de cabecera y botones
  static const colorFondo = Color(0xFF5C3317);

  //Datos sobre descripcion de receta
  static const List<String> countries = [
    "Afganistán",
    "Albania",
    "Alemania",
    "Andorra",
    "Angola",
    "Antigua y Barbuda",
    "Arabia Saudita",
    "Argelia",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaiyán",
    "Bahamas",
    "Bangladés",
    "Barbados",
    "Baréin",
    "Bélgica",
    "Belice",
    "Benín",
    "Bielorrusia",
    "Birmania",
    "Bolivia",
    "Bosnia y Herzegovina",
    "Botsuana",
    "Brasil",
    "Brunéi",
    "Bulgaria",
    "Burkina Faso",
    "Burundi",
    "Bután",
    "Cabo Verde",
    "Camboya",
    "Camerún",
    "Canadá",
    "Catar",
    "Chad",
    "Chile",
    "China",
    "Chipre",
    "Ciudad del Vaticano",
    "Colombia",
    "Comoras",
    "Corea del Norte",
    "Corea del Sur",
    "Costa de Marfil",
    "Costa Rica",
    "Croacia",
    "Cuba",
    "Dinamarca",
    "Dominica",
    "Ecuador",
    "Egipto",
    "El Salvador",
    "Emiratos Árabes Unidos",
    "Eritrea",
    "Eslovaquia",
    "Eslovenia",
    "España",
    "Estados Unidos",
    "Estonia",
    "Esuatini",
    "Etiopía",
    "Filipinas",
    "Finlandia",
    "Fiyi",
    "Francia",
    "Gabón",
    "Gambia",
    "Georgia",
    "Ghana",
    "Granada",
    "Grecia",
    "Guatemala",
    "Guinea",
    "Guinea-Bisáu",
    "Guinea Ecuatorial",
    "Guyana",
    "Haití",
    "Honduras",
    "Hungría",
    "India",
    "Indonesia",
    "Irak",
    "Irán",
    "Irlanda",
    "Islandia",
    "Islas Marshall",
    "Islas Salomón",
    "Israel",
    "Italia",
    "Jamaica",
    "Japón",
    "Jordania",
    "Kazajistán",
    "Kenia",
    "Kirguistán",
    "Kiribati",
    "Kuwait",
    "Laos",
    "Lesoto",
    "Letonia",
    "Líbano",
    "Liberia",
    "Libia",
    "Liechtenstein",
    "Lituania",
    "Luxemburgo",
    "Madagascar",
    "Malasia",
    "Malaui",
    "Maldivas",
    "Malí",
    "Malta",
    "Marruecos",
    "Mauricio",
    "Mauritania",
    "México",
    "Micronesia",
    "Moldavia",
    "Mónaco",
    "Mongolia",
    "Montenegro",
    "Mozambique",
    "Namibia",
    "Nauru",
    "Nepal",
    "Nicaragua",
    "Níger",
    "Nigeria",
    "Noruega",
    "Nueva Zelanda",
    "Omán",
    "Países Bajos",
    "Pakistán",
    "Palaos",
    "Panamá",
    "Papúa Nueva Guinea",
    "Paraguay",
    "Perú",
    "Polonia",
    "Portugal",
    "Reino Unido",
    "República Centroafricana",
    "República Checa",
    "República del Congo",
    "República Democrática del Congo",
    "República Dominicana",
    "Ruanda",
    "Rumanía",
    "Rusia",
    "Samoa",
    "San Cristóbal y Nieves",
    "San Marino",
    "San Vicente y las Granadinas",
    "Santa Lucía",
    "Santo Tomé y Príncipe",
    "Senegal",
    "Serbia",
    "Seychelles",
    "Sierra Leona",
    "Singapur",
    "Siria",
    "Somalia",
    "Sri Lanka",
    "Sudáfrica",
    "Sudán",
    "Sudán del Sur",
    "Suecia",
    "Suiza",
    "Surinam",
    "Tailandia",
    "Tanzania",
    "Tayikistán",
    "Timor Oriental",
    "Togo",
    "Tonga",
    "Trinidad y Tobago",
    "Túnez",
    "Turkmenistán",
    "Turquía",
    "Tuvalu",
    "Ucrania",
    "Uganda",
    "Uruguay",
    "Uzbekistán",
    "Vanuatu",
    "Venezuela",
    "Vietnam",
    "Yemen",
    "Yibuti",
    "Zambia",
    "Zimbabue",
  ];

  static const List<String> allergens = [
    'Ninguna',
    'Gluten',
    'Lácteos / Lactosa',
    'Huevo',
    'Frutos secos',
    'Cacahuete',
    'Soja',
    'Pescado',
    'Mariscos',
    'Sésamo',
    'Mostaza',
    'Apio',
    'Sulfitos',
    'Altramuces',
  ];

  static const List<String> seasons = [
    'Todas',
    'Primavera',
    'Verano',
    'Otoño',
    'Invierno',
  ];
}
