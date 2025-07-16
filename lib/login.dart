import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'signup.dart';
import 'supabase_service.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  )
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    if (SupabaseService.isSignedIn()) {
      // User is already logged in, navigate to main screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      });
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response = await SupabaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        if (response.user != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful! Welcome back.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Navigate to main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        } else {
          throw Exception('Failed to sign in');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed';
        
        // Handle specific auth errors
        if (e.message.contains('Invalid login credentials')) {
          errorMessage = 'Invalid email or password. Please try again.';
        } else if (e.message.contains('Email not confirmed')) {
          errorMessage = 'Please verify your email address before signing in.';
        } else if (e.message.contains('Too many requests')) {
          errorMessage = 'Too many login attempts. Please try again later.';
        } else {
          errorMessage = e.message;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await SupabaseService.client.auth.resetPasswordForEmail(email);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.orange.shade900,
                Colors.orange.shade800,
                Colors.orange.shade400
              ]
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: const Text(
                        "Welcome Back",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60)
                    )
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 60),
                          
                          // Form Container
                          FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(225, 95, 27, .3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10)
                                  )
                                ]
                              ),
                              child: Column(
                                children: <Widget>[
                                  // Email Field
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey.shade200)
                                      )
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      enabled: !_isLoading,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        hintText: "Email or Phone number",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                        if (!emailRegex.hasMatch(value.trim())) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  
                                  // Password Field
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      enabled: !_isLoading,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        hintText: "Password",
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
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
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Forgot Password Link
                          FadeInUp(
                            duration: const Duration(milliseconds: 1500),
                            child: GestureDetector(
                              onTap: _isLoading ? null : _showForgotPasswordDialog,
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: _isLoading ? Colors.grey : Colors.orange[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Login Button
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: Container(
                              width: double.infinity,
                              child: MaterialButton(
                                onPressed: _isLoading ? null : _signIn,
                                height: 50,
                                color: _isLoading ? Colors.grey : Colors.orange[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 50),
                          
                          // Social Media Text
                          FadeInUp(
                            duration: const Duration(milliseconds: 1700),
                            child: const Text(
                              "Continue with social media",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Social Media Buttons
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: FadeInUp(
                                  duration: const Duration(milliseconds: 1800),
                                  child: MaterialButton(
                                    onPressed: _isLoading ? null : () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Facebook login coming soon!'),
                                        ),
                                      );
                                    },
                                    height: 50,
                                    color: _isLoading ? Colors.grey : Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Text(
                                      "Facebook",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 30),
                              Expanded(
                                child: FadeInUp(
                                  duration: const Duration(milliseconds: 1900),
                                  child: MaterialButton(
                                    onPressed: _isLoading ? null : () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('GitHub login coming soon!'),
                                        ),
                                      );
                                    },
                                    height: 50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    color: _isLoading ? Colors.grey : Colors.black,
                                    child: const Text(
                                      "Github",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Sign Up Link
                          FadeInUp(
                            duration: const Duration(milliseconds: 2000),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                GestureDetector(
                                  onTap: _isLoading ? null : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignUpPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: _isLoading ? Colors.grey : Colors.orange[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}