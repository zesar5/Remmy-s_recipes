import '../../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
const String _baseUrl = 'http://127.0.0.1:8000';


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