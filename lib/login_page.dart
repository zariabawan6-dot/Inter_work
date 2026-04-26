import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intern_work/Home_page.dart';
import 'package:intern_work/register_page.dart';
import 'forgot_password.dart';
import 'main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool loading = false;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  // ---------------- EMAIL LOGIN ----------------
  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMsg("Fields cannot be empty");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      showMsg("Enter valid email format");
      return;
    }

    if (password.length < 8) {
      showMsg("Password must be at least 8 characters");
      return;
    }

    try {
      setState(() => loading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() => loading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );

    } catch (e) {
      setState(() => loading = false);
      showMsg(e.toString());
    }
  }

  // ---------------- GOOGLE SIGN IN ----------------
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const Icon(Icons.lock_outline,
                  size: 70, color: Colors.white),

              const SizedBox(height: 20),

              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- EMAIL ----------------
              buildField(
                emailController,
                "Email",
                icon: Icons.email,
              ),

              const SizedBox(height: 15),

              // ---------------- PASSWORD ----------------
              buildField(
                passwordController,
                "Password",
                icon: Icons.lock,
                isPass: true,
                isVisible: isPasswordVisible,
                toggle: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ---------------- LOGIN BUTTON ----------------
              ElevatedButton(
                onPressed: loading ? null : login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blueAccent,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),

              const SizedBox(height: 10),

              // ---------------- FORGOT PASSWORD ----------------
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 10),

              const Text("OR",
                  style: TextStyle(color: Colors.white54)),

              const SizedBox(height: 15),

              // ---------------- GOOGLE SIGN IN ----------------
              OutlinedButton.icon(
                onPressed: () async {
                  final user = await signInWithGoogle();

                  if (user != null) {
                    showMsg("Google Sign-In Success");

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MainScreen(),),
                    );
                  } else {
                    showMsg("Google Sign-In Cancelled");
                  }
                },
                icon: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/300/300221.png",
                  height: 20,
                ),
                label: const Text(
                  "Sign in with Google",
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.white24),
                ),
              ),

              const SizedBox(height: 15),

              // ---------------- REGISTER ----------------
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- REUSABLE FIELD ----------------
  Widget buildField(
      TextEditingController controller,
      String hint, {
        bool isPass = false,
        bool isVisible = false,
        VoidCallback? toggle,
        IconData? icon,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPass ? !isVisible : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPass
            ? IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: toggle,
        )
            : null,
      ),
    );
  }
}