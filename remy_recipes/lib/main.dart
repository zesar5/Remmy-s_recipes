import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



//  URL del Backend

const String _baseUrl = 'http://127.0.0.1:8000';

// ==========================================================================
// 1. MODELO DE DATOS
// ==========================================================================

class Usuario {
  final String id;
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

  Future<bool> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/registro/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

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

  final List<String> _countries = ['España', 'Mexico', 'Colombia', 'Argentina', 'Chile', 'Otro'];
  String? _selectedCountry;

  // Variables para la fecha de nacimiento 
  final List<String> _birthYears = List<String>.generate(100, (i) => (DateTime.now().year - i).toString());
  String? _selectedBirthYear;

  // Controladores de texto
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });
      
      // Construimos el body que espera la API de FastAPI
      final Map<String, dynamic> registerData = {
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

        final success = await widget.authService.register(apiData);

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
                // Titulo
                const Text(
                  'Remmy\'s Recipes',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4226),
                  ),
                ),
                const SizedBox(height: 30),

                // Foto de Perfil
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text('Añadir foto de perfil', style: TextStyle(color: Color(0xFF6B4226), fontSize: 12)),
                const SizedBox(height: 30),

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

// ==========================================================================
// 6. PANTALLA DE INICIO (HOME) - SIMULADA
// ==========================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6B4226)),
              ),
              const SizedBox(height: 20),
              if (user != null) ...[
                Text('Usuario: ${user.nombreUsuario}', style: const TextStyle(fontSize: 18)),
                Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
                Text('Rol: ${user.rol}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                const Text('Autenticacion exitosa con FastAPI!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ] else ...[
                const Text('Has accedido como invitado o la sesion ha expirado.', style: TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
