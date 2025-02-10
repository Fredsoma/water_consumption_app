import 'package:flutter/material.dart';
import 'package:water_consumption_app/consts.dart';
import 'package:water_consumption_app/services/auth_service.dart';
import 'package:water_consumption_app/services/navigation_service.dart';
import 'package:water_consumption_app/widgets/custom_form_field.dart';
import 'package:get_it/get_it.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  late AuthService _authService;
  late NavigationService _navigationService;
  String? email, password;
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
              _loginForm(),
              _accountLink(),
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
          "Stay Hydrated!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Login to track your water intake",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Login form
  Widget _loginForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _loginFormKey,
          child: Column(
            children: [
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
              _loginButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Login button
  Widget _loginButton() {
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
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                "Login",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  // Handle login functionality
  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState?.validate() ?? false) {
      _loginFormKey.currentState?.save();
      setState(() => _isLoading = true);

      bool result = await _authService.login(email!, password!);
      setState(() => _isLoading = false);

      if (result) {
        _navigationService.pushReplacementNamed("/home");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed. Please try again.")),
        );
      }
    }
  }

  // Account link for registration
  Widget _accountLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don't have an account?", style: TextStyle(color: Colors.white)),
          TextButton(
            onPressed: () => _navigationService.pushedNamed("/register"),
            child: Text(
              "Sign Up",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
