import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import '../api_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const LoginPage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  // LOGIN FUNCTION
  Future<void> _login() async {
    
    // Check email
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
        ),
      );
      return;
    }

    // Check email format
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
        ),
      );
      return;
    }

    // Check password
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
        ),
      );
      return;
    }

    // Check password length
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must be at least 6 characters',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call ASP.NET Core API
      final result = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Get JWT token from backend
      final token = result['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception(
          'Login succeeded but no authentication token was received.',
        );
      }

      // Save JWT token locally
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'auth_token',
        token.toString(),
      );

      // Also save user information
      await prefs.setInt(
        'user_id',
        result['userId'],
      );

      await prefs.setString(
        'user_name',
        result['fullName'] ?? _nameController.text.trim(),
      );

      await prefs.setString(
        'user_email',
        result['email'] ?? _emailController.text.trim(),
      );

      // Navigate to Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            name: result['fullName'] ??
                _nameController.text.trim(),
            onToggleTheme: widget.onToggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // DARK / BRIGHT MODE BUTTON
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        widget.onToggleTheme();

                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                      },
                      icon: Icon(
                        _isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      tooltip: _isDarkMode
                          ? 'Switch to bright mode'
                          : 'Switch to dark mode',
                    ),
                  ),

                  // LOGO
                  Image.asset(
                    'assets/images/ibnsina-pharma-logo.png',
                    height: 300,
                    width: 300,
                    fit: BoxFit.contain,
                  ),

                  Transform.translate(
                    offset: const Offset(0, -50),
                    child: const Text(
                      'Your trusted pharmacy at your fingertips',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  

                  const SizedBox(height: 20),

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // LOGIN BUTTON
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(
                          255,
                          76,
                          87,
                          175,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CREATE ACCOUNT
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push (
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(
                                onToggleTheme: widget.onToggleTheme,
                                isDarkMode: widget.isDarkMode,
                               ),
                            ),
                          );
                        },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
