import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'supabase_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedYear = 'First Year';
  String _selectedBranch = 'Computer Science';
  
  bool _isLoading = false;

  final List<String> _years = [
    'First Year',
    'Second Year',
    'Third Year',
    'Final Year'
  ];

  final List<String> _branches = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Chemical',
    'Electrical',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse response = await SupabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        year: _selectedYear,
        branch: _selectedBranch,
      );

      if (mounted) {
        if (response.user != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully! Please check your email for verification.'),
              backgroundColor: Colors.green,
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
          throw Exception('Failed to create account');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
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
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: const Text(
                        "Create your account",
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
                          const SizedBox(height: 40),
                          
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
                                  // Full Name Field
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey.shade200)
                                      )
                                    ),
                                    child: TextFormField(
                                      controller: _nameController,
                                      enabled: !_isLoading,
                                      decoration: const InputDecoration(
                                        hintText: "Full Name",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your full name';
                                        }
                                        if (value.trim().length < 2) {
                                          return 'Name must be at least 2 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  
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
                                        hintText: "College Email",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none
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
                                  
                                  // Year Dropdown
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey.shade200)
                                      )
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedYear,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ),
                                      items: _years.map((String year) {
                                        return DropdownMenuItem<String>(
                                          value: year,
                                          child: Text(year),
                                        );
                                      }).toList(),
                                      onChanged: _isLoading ? null : (String? newValue) {
                                        setState(() {
                                          _selectedYear = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  
                                  // Branch Dropdown
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey.shade200)
                                      )
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedBranch,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ),
                                      items: _branches.map((String branch) {
                                        return DropdownMenuItem<String>(
                                          value: branch,
                                          child: Text(branch),
                                        );
                                      }).toList(),
                                      onChanged: _isLoading ? null : (String? newValue) {
                                        setState(() {
                                          _selectedBranch = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                  
                                  // Password Field
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey.shade200)
                                      )
                                    ),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      enabled: !_isLoading,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        hintText: "Password",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        }
                                        if (value.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                                          return 'Password must contain uppercase, lowercase, and number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  
                                  // Confirm Password Field
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      enabled: !_isLoading,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        hintText: "Confirm Password",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'Passwords do not match';
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
                          
                          // Sign Up Button
                          FadeInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: Container(
                              width: double.infinity,
                              child: MaterialButton(
                                onPressed: _isLoading ? null : _signUp,
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
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Login Link
                          FadeInUp(
                            duration: const Duration(milliseconds: 1700),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account? ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                GestureDetector(
                                  onTap: _isLoading ? null : () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Login",
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
                          
                          FadeInUp(
                            duration: const Duration(milliseconds: 1800),
                            child: const Text(
                              "Or continue with social media",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Social Media Buttons
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: FadeInUp(
                                  duration: const Duration(milliseconds: 1900),
                                  child: MaterialButton(
                                    onPressed: _isLoading ? null : () {
                                      // TODO: Implement Facebook OAuth
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
                                  duration: const Duration(milliseconds: 2000),
                                  child: MaterialButton(
                                    onPressed: _isLoading ? null : () {
                                      // TODO: Implement GitHub OAuth
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