import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;


//  URL del Backend

const String _baseUrl = 'http://127.0.0.1:8000';

// ==========================================================================
// 1. MODELO DE DATOS
// ==========================================================================

class Usuario {
  final String id;
  final String userName;
  final String nombreUsuario;
  final String email;
  final String rol;
  final String? primerApellido;
  final String? segundoApellido;
  final String? descripcion;
  final String? anioNacimiento;
  final String? fotoPerfil;

  Usuario({
    required this.id,
    required this.userName,
    required this.nombreUsuario,
    required this.email,
    required this.rol,
    this.primerApellido,
    this.segundoApellido,
    this.descripcion,
    this.anioNacimiento,
    this.fotoPerfil,
  });

  // Constructor para crear un objeto Usuario desde una respuesta JSON (PerfilOut)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      userName: json['userName']as String,
      nombreUsuario: json['nombreUsuario'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      primerApellido: json['primerApellido'] as String?,
      // FastAPI devuelve las fechas como strings (e.g., "2025-11-03")
      segundoApellido: json['segundoApellido'] as String?, 
      descripcion: json['descripcion'] as String?,
      anioNacimiento: json['anioNacimiento'] as String?,
      fotoPerfil: json['fotoPerfil'] as String?,
    );
  }
}

// ==========================================================================
// 2. SERVICIO DE AUTENTICACION (Conexion con FastAPI)
// ==========================================================================

class AuthService {
  // Simula el almacenamiento del token de sesion (usar Secure Storage en produccion)
  
  String? _accessToken;
  Usuario? _currentUser;

  Usuario? get currentUser => _currentUser;

  Future<bool> login({required String username, required String password}) async {
    final url = Uri.parse('$_baseUrl/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        // La API de FastAPI espera 'username' y 'password' para OAuth2
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      // Despues de obtener el token, obtenemos el perfil del usuario
      return await fetchProfile();
    } else {
      // Manejo de errores de credenciales incorrectas
      throw Exception('Credenciales incorrectas o error de servidor.');
    }
  }

  Future<bool> register(Map<String, dynamic> data, {File? imageFile}) async {
    final url = Uri.parse('$_baseUrl/registro/');
    final request = http.MultipartRequest('POST', url);
    data.forEach((key, value){
      request.fields[key] = value.toString();
    }); 
    if (imageFile != null){
      request.files.add(
        await http.MultipartFile.fromPath(
          'fotoPerfil',
          imageFile.path,
        ),
      );
    }
    final streamedResponse = await request.send();
    final response =await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Registro exitoso, el backend devuelve el perfil del nuevo usuario
      _currentUser = Usuario.fromJson(json.decode(response.body));
     
      return true;
    } else {
      // Manejo de errores 
      final errorData = json.decode(response.body)['detail'];
      throw Exception(errorData.toString());
    }
  }

  Future<bool> fetchProfile() async {
    if (_accessToken == null) return false;

    final url = Uri.parse('$_baseUrl/perfil/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      _currentUser = Usuario.fromJson(json.decode(response.body));
      return true;
    } else {
      // Token invalido o expirado
      _accessToken = null;
      _currentUser = null;
      return false;
    }
  }

  void logout() {
    _accessToken = null;
    _currentUser = null;
  }
}

// ==========================================================================
// 3. WIDGETS Y CLASE PRINCIPAL
// ==========================================================================

// Usamos Provider o GetX en un proyecto real, pero para simplicidad, 
// pasamos el AuthService como un objeto.
final AuthService authService = AuthService();

void main() {
  runApp(const RemyRecipesApp());
}

class RemyRecipesApp extends StatelessWidget {
  const RemyRecipesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remy\'s Recipes',
      theme: ThemeData(
        // Colores base 
        primaryColor: const Color(0xFF6B4226), // Marron oscuro
        scaffoldBackgroundColor: const Color(0xFFE9C893), // Color de fondo claro 
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(0xFF6B4226, {
            50: Color(0xFFf3e5c9),
            100: Color(0xFFdcc194),
            200: Color(0xFFc69d5f),
            300: Color(0xFFb0792a),
            400: Color(0xFF995600),
            500: Color(0xFF6B4226),
            600: Color(0xFF5f3b21),
            700: Color(0xFF53331b),
            800: Color(0xFF472c16),
            900: Color(0xFF3a2411),
          }),
        ).copyWith(
          secondary: const Color(0xFFE9C893),
        ),
        
        
        // La aplicacion usara la fuente por defecto del sistema.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      // Usamos un simple Navigatior para cambiar entre Login y Registro
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(authService: authService),
        '/register': (context) => RegisterScreen(authService: authService),
        '/home': (context) => const HomeScreen(),
        '/add_recipe': (context) => RecipeFormPage(),
      },
    );
  }
}

// ==========================================================================
// 4. PANTALLA DE INICIO DE SESION 
// ==========================================================================

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _ocultarContrasena = true;
  bool _isLoading = false;
  
  // ==== LOGIN HANDLER ====
  Future<void> _handleLogin() async {
    final correo = _correoController.text.trim();
    final contrasena = _contrasenaController.text.trim();

    // Validaciones locales (como en WPF)
    if (correo.isEmpty) {
      _showErrorDialog('Campo vacío', 'Por favor, introduce tu correo electrónico.');
      return;
    }
    if (!_esCorreoValido(correo)) {
      _showErrorDialog('Correo inválido', 'El formato del correo no es válido.');
      return;
    }
    if (contrasena.isEmpty) {
      _showErrorDialog('Campo vacío', 'Por favor, introduce tu contraseña.');
      return;
    }

    // Simulación del backend real
    setState(() => _isLoading = true);
    try {
      final success = await widget.authService.login(
        username: correo,
        password: contrasena,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showErrorDialog('Error de inicio de sesión', 'Credenciales incorrectas.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error de conexión', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==== UTILIDADES ====
  bool _esCorreoValido(String correo) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(correo);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // ==== BUILD UI ====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887), // BurlyWood
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),

            // LOGO + TITULO
            const Text(
              "Remmy's Recipes",
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Times New Roman',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            Image.asset(
              'assets/logosinfondoBien.png',
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height *0.2,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),

            // CORREO
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Correo electrónico",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),

            // CONTRASEÑA
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Contraseña",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _contrasenaController,
                obscureText: _ocultarContrasena,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarContrasena ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarContrasena = !_ocultarContrasena;
                      });
                    },
                  ),
                ),
              ),
            ),

            // OLVIDE CONTRASEÑA
            TextButton(
              onPressed: () => _showErrorDialog(
                'Recuperar contraseña',
                'Te enviaremos un enlace para restablecer tu contraseña.',
              ),
              child: const Text(
                'He olvidado la contraseña',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            // BOTÓN INICIAR SESIÓN
            const SizedBox(height: 10),
            _buildActionButton(
              text: 'Iniciar Sesión',
              color: Colors.black,
              textColor: Colors.white,
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
            ),

            // BOTÓN REGISTRARSE
            const SizedBox(height: 20),
            _buildActionButton(
              text: 'Registrarse',
              color: Colors.black,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
            ),

            // BOTÓN OMITIR
            const SizedBox(height: 25),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: const Text(
                'Omitir',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 30),

            // TÉRMINOS Y POLÍTICA
            const Text(
              "Al hacer click, aceptas nuestros Términos de",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue),
            ),
            const Text(
              "servicio y Política de privacidad",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==== BOTÓN ESTILIZADO ====
  Widget _buildActionButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

  Widget _buildAuthButton({required String text, VoidCallback? onPressed, required Color color, required Color textColor, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                text,
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }


// ==========================================================================
// 5. PANTALLA DE REGISTRO
// ==========================================================================

class RegisterScreen extends StatefulWidget {
  final AuthService authService;
  const RegisterScreen({super.key, required this.authService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker =ImagePicker();
  //AÑADIR IMAGEN
   Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  final List<String> _countries = ['España', 'Mexico', 'Colombia', 'Argentina', 'Chile', 'Otro'];
  String? _selectedCountry;

  // Variables para la fecha de nacimiento 
  final List<String> _birthYears = List<String>.generate(100, (i) => (DateTime.now().year - i).toString());
  String? _selectedBirthYear;

  // Controladores de texto
  
  final TextEditingController _userNameController =TextEditingController();
  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _primerApellidoController = TextEditingController();
  final TextEditingController _segundoApellidoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  
  // Guardamos las referencias a los controllers para limpieza
  @override
  void dispose() {
    _userNameController.dispose();
    _nombreUsuarioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    _primerApellidoController.dispose();
    _segundoApellidoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }


  Future<void> _handleRegister() async {
    final userName = _userNameController.text.trim(); 
    final nombreUsuario = _nombreUsuarioController.text.trim();
    final correo = _emailController.text.trim();
    final primeraContrasena = _passwordController.text.trim();
    final segundaContrasena = _password2Controller.text.trim();
    if (userName.isEmpty || nombreUsuario.isEmpty || correo.isEmpty || primeraContrasena.isEmpty) {
        _showErrorDialog('Campos incompletos', 'Por favor, rellena todos los campos obligatorios.');
        return;
    }
    
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });
      
      // Construimos el body que espera la API de FastAPI
      final Map<String, dynamic> registerData = {
        'userName': _userNameController.text,
        'nombreUsuario': _nombreUsuarioController.text,
        'email': _emailController.text,
        // Usamos 'contrasena' y 'contrasena2' porque con'ñ ' nos da error
        'contrasena': _passwordController.text, 
        'contrasena2': _password2Controller.text, 
        'primerApellido': _primerApellidoController.text.isNotEmpty ? _primerApellidoController.text : null,
        'segundoApellido': _segundoApellidoController.text.isNotEmpty ? _segundoApellidoController.text : null,
        'descripcion': _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
        'anioNacimiento': _selectedBirthYear, 
        'rol': 'usuario', // Valor por defecto
      };

      
      
      try {
        
        final Map<String, dynamic> apiData = {
          'userName':registerData['userName'],
          'nombreUsuario': registerData['nombreUsuario'],
          'email': registerData['email'],
          'contrasena': registerData['contrasena'],
          'contrasena2': registerData['contrasena2'],
          'primerApellido': registerData['primerApellido'],
          'segundoApellido': registerData['segundoApellido'],
          'descripcion': registerData['descripcion'],
          'anioNacimiento': registerData['anioNacimiento'],
          'rol': registerData['rol'],
        };
        final success = await widget.authService.register(
        {
          'userName': userName,
          'nombreUsuario': nombreUsuario,
          'email': correo,
          'contrasena': primeraContrasena,
          'rol': 'Usuario', 
        },
        imageFile: _imageFile, // <-- Pasamos el archivo aquí
      );

        

        if (!mounted) return; 

        if (success) {
          _showSuccessDialog('Registro Exitoso!', 'Tu cuenta ha sido creada. Puedes iniciar sesion o seras redirigido.');
          // Navegar a la pantalla de inicio despues de un breve retraso
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pushReplacementNamed('/home');
          });
        }
      } catch (e) {
        if (!mounted) return; 
        _showErrorDialog('Error al registrar', e.toString().replaceFirst('Exception: ', ''));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }
  
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse', style: TextStyle(color: Color(0xFF6B4226))),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6B4226)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
               GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider<Object>?
                      : null,
                  child: _imageFile == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar Foto de Perfil'),
              ),
              const SizedBox(height: 30),  
                // Titulo
                

                // Foto de Perfil
               
TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario (userName)',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              
                
              
                // Nombre y Apellidos
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _nombreUsuarioController,
                        hintText: 'Nombre',
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        fieldName: 'nombreUsuario',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _primerApellidoController,
                        hintText: 'Apellidos (Primer Apellido)',
                        fieldName: 'primerApellido',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Segundo Apellido (
                _buildTextFormField(
                  controller: _segundoApellidoController,
                  hintText: 'Segundo Apellido (Opcional)',
                  fieldName: 'segundoApellido',
                ),
                const SizedBox(height: 20),


                // Pais y Año de nacimiento 
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          hintText: 'Pais',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        initialValue: _selectedCountry,
                        items: _countries.map((String country) {
                          return DropdownMenuItem<String>(
                            value: country,
                            child: Text(country),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCountry = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          hintText: 'Año de nacimiento',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        initialValue: _selectedBirthYear,
                        items: _birthYears.map((String year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(year),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBirthYear = newValue;
                          });
                        },
                        validator: (v) => v == null ? 'Selecciona un año' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo Correo electronico
                _buildTextFormField(
                  controller: _emailController,
                  hintText: 'Correo electronico',
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email invalido' : null,
                  keyboardType: TextInputType.emailAddress,
                  fieldName: 'email',
                ),
                const SizedBox(height: 20),

                // Campo Contraseña
                _buildTextFormField(
                  controller: _passwordController,
                  hintText: 'Contraseña',
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Minimo 6 caracteres' : null,
                  fieldName: 'contrasena', 
                ),
                const SizedBox(height: 20),

                // Campo Confirmar contraseña
                _buildTextFormField(
                  controller: _password2Controller,
                  hintText: 'Confirmar contraseña',
                  obscureText: true,
                  validator: (v) {
                    if (v!.isEmpty) return 'Confirmacion requerida';
                    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                  fieldName: 'contrasena2', 
                ),
                const SizedBox(height: 20),

                // Campo Descripcion
                _buildTextFormField(
                  controller: _descripcionController,
                  hintText: 'Descripcion',
                  maxLines: 3,
                  fieldName: 'descripcion',
                ),
                const SizedBox(height: 40),

                // Boton Registrarse
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text(
                            'Registrarse',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    required String fieldName,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      onSaved: (value) {
        _formData[fieldName] = value;
      },
    );
  }
}

// DESPUES de la Seccion 4 y antes de la Seccion 5 (o donde desees ubicarla)
// ==========================================================================
// 4.5. PANTALLA DE INICIO (Dummy)
// ==========================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser; // Si el usuario ha iniciado sesion
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Recetas"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) 
              Text("¡Bienvenido, ${user.nombreUsuario}!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            // Boton para ir al formulario de recetas
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/add_recipe');
              },
              child: const Text('+'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authService.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
// ... (Despues de la clase LoginScreen y antes de RegisterScreen)
// ==========================================================================
// 6. FORMULARIO DE RECETAS
// ==========================================================================

// Clases de datos auxiliares (Ingrediente y Paso)
class Ingredient {
  String name;
  Ingredient(this.name);
}

class StepItem {
  String description;
  StepItem(this.description);
}

class RecipeFormPage extends StatefulWidget {
  @override
  _RecipeFormPageState createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  String? imagePath;
  String title = '';
  String? duration;
  String? country;
  String? selectedAllergen;
  String? season;

  List<Ingredient> ingredients = [];
  List<StepItem> steps = [];

  final TextEditingController titleController = TextEditingController();

  final List<String> durations =
      List.generate(60, (index) => ((index + 1) * 5).toString()); // 5-300
  final List<String> countries = [
    'España',
    'Italia',
    'México',
    'Francia',
    'Alemania',
    'Japón',
    'China'
  ];
  final List<String> allergens = [
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
  final List<String> seasons = ['Todas', 'Primavera', 'Verano', 'Otoño', 'Invierno'];

  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  void addIngredient() {
    setState(() {
      
      ingredients.add(Ingredient(''));
    });
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  void addStep() {
    setState(() {
      steps.add(StepItem(''));
    });
  }

  void removeStep(int index) {
    setState(() {
      steps.removeAt(index);
    });
  }

  bool isFormValid() {
    if (title.trim().isEmpty) return false;
    if (imagePath == null) return false;
    if (duration == null) return false;
    if (country == null) return false;
    if (selectedAllergen == null) return false;
    if (season == null) return false;
    if (ingredients.isEmpty || ingredients.any((i) => i.name.trim().isEmpty))
      return false;
    if (steps.isEmpty || steps.any((s) => s.description.trim().isEmpty))
      return false;
    return true;
  }

  void onSubmit() {
    if (isFormValid()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Éxito'),
          content: Text('Receta guardada con éxito'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Advertencia'),
          content: Text('Error, no ha rellenado todos los campos'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el color de fondo definido en el Theme para consistencia
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: Text("Añadir Nueva Receta"),
        backgroundColor: Theme.of(context).primaryColor, // Usamos el color primario
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Remmy's Recipes",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Añadir imagen
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Añadir imagen:"),
            ),
            SizedBox(height: 5),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0), // Usamos el mismo radio de borde que en el Theme
                ),
                child: imagePath == null
                    ? const Center(
                        child: Text(
                          '+',
                          style: TextStyle(fontSize: 40),
                        ),
                      )
                      : kIsWeb
                      ? Image.network(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Text("Error al cargar imagen web")),
              )
                    // Importante: La clase File ya está importada en el inicio del archivo
                    : Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            SizedBox(height: 15),

            // Título
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Título:"),
            ),
            SizedBox(height: 5),
            TextField(
              controller: titleController,
              onChanged: (val) => title = val,
              
              // Usamos el InputDecoration Theme del MaterialApp
            ),
            SizedBox(height: 15),

            // Ingredientes
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Ingredientes:"),
            ),
            // ... (mapeo de ingredientes)
            ...ingredients.asMap().entries.map((entry) {
              int idx = entry.key;
              Ingredient ing = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => ing.name = val,
                        decoration: const InputDecoration(
                          hintText: 'Ingrediente',
                          // No se necesita border, fillColor, filled, ya están en el Theme
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => removeIngredient(idx),
                      child: const Text('-'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addIngredient, 
              child: const Text('Agregar Ingrediente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            SizedBox(height: 15),

            // Pasos
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Pasos:"),
            ),
            // ... (mapeo de pasos)
            ...steps.asMap().entries.map((entry) {
              int idx = entry.key;
              StepItem s = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => s.description = val,
                        decoration: const InputDecoration(
                          hintText: 'Paso',
                          // No se necesita border, fillColor, filled, ya están en el Theme
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => removeStep(idx),
                      child: const Text('-'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addStep, 
              child: const Text('Agregar Paso'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            SizedBox(height: 20),

            // Combo boxes (Duración y País)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: duration,
                    decoration: const InputDecoration(
                      labelText: 'Duración (min)',
                      // Tema aplicado automáticamente
                    ),
                    items: durations
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setState(() => duration = val),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: country,
                    decoration: const InputDecoration(
                      labelText: 'País',
                      // Tema aplicado automáticamente
                    ),
                    items: countries
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => country = val),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            
            // Combo boxes (Alérgenos y Estación)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAllergen,
                    decoration: const InputDecoration(
                      labelText: 'Alérgenos',
                      // Tema aplicado automáticamente
                    ),
                    items: allergens
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedAllergen = val),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: season,
                    decoration: const InputDecoration(
                      labelText: 'Estación',
                      // Tema aplicado automáticamente
                    ),
                    items: seasons
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => season = val),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Botón guardar (usamos un estilo similar al de Login/Register)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onSubmit,
                child: const Text('Guardar Receta'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}