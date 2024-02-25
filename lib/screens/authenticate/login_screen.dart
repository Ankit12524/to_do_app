import 'package:flutter/material.dart';
import 'package:to_do/services/auth_service.dart'; // Import the AuthService class
import 'package:to_do/screens/authenticate/register_screen.dart'; // Import the RegisterScreen class
import 'package:to_do/shared/msgs.dart';
import 'package:to_do/to_do.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService(); // Create an instance of AuthService

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(

                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  icon: Icon(Icons.email),

                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },

              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  icon: Icon(Icons.lock),
                ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  }
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // TODO: Implement Email/Password Sign-In
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      var user = await _authService.signInWithEmailAndPassword(
                        emailController.text,
                        passwordController.text,
                      );
                      if (user != null) {
                        // Navigate to the main app screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ToDoScreen()),
                        );
                      }
                    } catch (error) {
                      ToastUtils.showErrorSnackbar(context,"Error: $error",);
                    }
                  }
                },
                child: const Text('Sign in'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // TODO: Implement Google Sign-In
                  var user = await _authService.signInWithGoogle();
                  if (user != null) {
                    // Navigate to the main app screen
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ToDoScreen()),
                    );
                  }
                },
                child: const Text('Sign in with Google'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the registration screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  // TODO: Implement Guest Sign-In
                  var user = await _authService.signInAsGuest();
                  if (user != null) {
                    // Navigate to the main app screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ToDoScreen()),
                    );
                  }
                },
                child: const Text('Continue as Guest?',style: TextStyle(decoration: TextDecoration.underline,)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
