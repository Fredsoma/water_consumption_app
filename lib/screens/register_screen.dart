import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:water_consumption_app/consts.dart';
import 'package:water_consumption_app/services/auth_service.dart';
import 'package:water_consumption_app/services/navigation_service.dart';
import 'package:water_consumption_app/widgets/custom_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  late AuthService _authService;
  late NavigationService _navigationService;

  String? email, password, name;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(child: _buildUI()),
        ],
      ),
    );
  }

  // Water-like background gradient
  Widget _background() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan, Colors.blueAccent], // Water-like gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _headerText(),
              _registerForm(),
              _loginAccountLink(),
            ],
          ),
        ),
      ),
    );
  }

  // Header text with water droplet icon and theme
  Widget _headerText() {
    return Column(
      children: [
        Icon(
          Icons.water_drop,  // Water droplet icon
          size: 60,
          color: Colors.white,
        ),
        SizedBox(height: 10),
        Text(
          "Let's Get Started!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Create an account below",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Registration form
  Widget _registerForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _registerFormKey,
          child: Column(
            children: [
              CustomFormField(
                height: 50,
                hintText: "Full Name",
                validationRegEx: NAME_VALIDATION_REGEX,
                onSaved: (value) => name = value,
              ),
              SizedBox(height: 15),
              CustomFormField(
                height: 50,
                hintText: "Email",
                validationRegEx: EMAIL_VALIDATION_REGEX,
                onSaved: (value) => email = value,
              ),
              SizedBox(height: 15),
              TextFormField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
                onSaved: (value) => password = value,
              ),
              SizedBox(height: 20),
              _registerButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Register button with water theme
  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent, // Water-themed button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading ? null : _handleRegister,
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                "Register",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  // Handle registration logic
  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState?.validate() ?? false) {
      _registerFormKey.currentState?.save();
      setState(() => _isLoading = true);

      try {
        bool result = await _authService.signup(email!, password!);
        if (result) {
          _navigationService.pushReplacementNamed("/login");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration failed. Try again.")),
          );
        }
      } catch (e) {
        print(e);
      }

      setState(() => _isLoading = false);
    }
  }

  // Link to login screen
  Widget _loginAccountLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already have an account?", style: TextStyle(color: Colors.white)),
          TextButton(
            onPressed: () => _navigationService.goback(),
            child: Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
