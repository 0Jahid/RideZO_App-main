import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_zo/reusable_widgets/reusable_widget.dart';
import 'package:ride_zo/screens/authentication_screens/signin_screen.dart';

class NoAtSignInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.contains('@')) {
      return oldValue;
    }
    return newValue;
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController = TextEditingController();

  Future<void> _createAccount(BuildContext context) async {
    final name = _nameTextController.text.trim();
    final username = _emailTextController.text.trim(); // Only the username entered by the user
    final password = _passwordTextController.text.trim();
    final confirmPassword = _confirmPasswordTextController.text.trim();

    if (name.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill up all the fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Add @northsouth.edu domain
    // final email = '$username@northsouth.edu';
    final email  = '$username@gmail.com';
    print("Attempting to sign up with email: $email");

    try {
      // Create the user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();
      print("Verification email sent to: $email");

      // Display success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent. Please check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );

      // Show a dialog informing the user about email verification
      _showVerifyEmailDialog(context);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showVerifyEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Verification'),
          content: const Text(
            'A verification email has been sent. Please verify your email before logging in.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: screenHeight * 0.02),
                      const Text(
                        'Create a New Account',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      reusableTextField(
                        "Name",
                        Icons.person_outline,
                        false,
                        _nameTextController,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      reusableTextField(
                        "Enter Your Mail",
                        Icons.email_outlined,
                        false,
                        _emailTextController,
                        // suffixText: '@northsouth.edu',
                        suffixText: '@gmail.com',
                        inputFormatter: NoAtSignInputFormatter(),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      reusableTextField(
                        "Password",
                        Icons.lock_outline,
                        true,
                        _passwordTextController,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      reusableTextField(
                        "Confirm Password",
                        Icons.lock_outline,
                        true,
                        _confirmPasswordTextController,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.08),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, screenHeight * 0.06),
                    backgroundColor: Color.fromARGB(167, 133, 211, 178),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => _createAccount(context),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}