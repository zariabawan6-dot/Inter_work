import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool isPasswordVisible = false;
  bool isConfirmVisible = false;

  Future<void> register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    // ✅ Validation
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMsg("All fields are required");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      showMsg("Enter valid email");
      return;
    }

    if (password.length < 8) {
      showMsg("Password must be at least 8 characters");
      return;
    }

    if (password != confirmPassword) {
      showMsg("Passwords do not match");
      return;
    }

    try {
      setState(() => loading = true);

      /// 🔐 Create user
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      /// 📦 Save extra data
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "uid": uid,
        "createdAt": DateTime.now(),
      });

      /// 📩 Email verification
      await userCredential.user!.sendEmailVerification();

      setState(() => loading = false);

      showMsg("Registered successfully. Verify your email.");

      /// ✅ Navigate to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );

    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);
      showMsg(e.message ?? "Registration failed");
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

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 10),

            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            buildField(nameController, "Name", Icons.person),

            const SizedBox(height: 15),

            buildField(emailController, "Email", Icons.email),

            const SizedBox(height: 15),

            buildField(phoneController, "Phone", Icons.phone),

            const SizedBox(height: 15),

            /// PASSWORD
            buildField(
              passwordController,
              "Password",
              Icons.lock,
              isPass: true,
              isVisible: isPasswordVisible,
              toggle: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),

            const SizedBox(height: 15),

            /// CONFIRM PASSWORD
            buildField(
              confirmPasswordController,
              "Confirm Password",
              Icons.lock_outline,
              isPass: true,
              isVisible: isConfirmVisible,
              toggle: () {
                setState(() {
                  isConfirmVisible = !isConfirmVisible;
                });
              },
            ),

            const SizedBox(height: 25),

            /// REGISTER BUTTON
            ElevatedButton(
              onPressed: loading ? null : register,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Register"),
            ),

            const SizedBox(height: 15),

            /// BACK TO LOGIN
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 REUSABLE FIELD
  Widget buildField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        bool isPass = false,
        bool isVisible = false,
        VoidCallback? toggle,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPass ? !isVisible : false,
      style: const TextStyle(color: Colors.white),
      keyboardType:
      hint == "Email" ? TextInputType.emailAddress : TextInputType.text,
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
            isVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: toggle,
        )
            : null,
      ),
    );
  }
}