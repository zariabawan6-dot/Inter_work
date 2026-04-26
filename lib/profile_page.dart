import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "User";
  File? image;

  final nameController = TextEditingController();
  final goalController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? "User";
      nameController.text = name;

      goalController.text = prefs.getString("goal") ?? "";
      bioController.text = prefs.getString("bio") ?? "";

      final path = prefs.getString("dp");
      if (path != null) image = File(path);
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear(); // clear saved data

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully 👋"),
        backgroundColor: Colors.red,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false, // removes all previous pages
    );
  }

  void save() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("name", nameController.text);
    prefs.setString("goal", goalController.text);
    prefs.setString("bio", bioController.text);

    if (image != null) {
      prefs.setString("dp", image!.path);
    }

    setState(() => name = nameController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated ✅")),
    );
  }

  void pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        title: const Text("Profile"),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 👤 PROFILE IMAGE
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[800],
                backgroundImage:
                image != null ? FileImage(image!) : null,
                child: image == null
                    ? const Icon(Icons.person,
                    size: 50, color: Colors.white70)
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Tap to change photo",
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 30),

            /// 🔹 NAME
            buildField("Name", nameController),

            const SizedBox(height: 15),

            /// 🎯 DAILY GOAL
            buildField("Daily Goal 🎯", goalController),

            const SizedBox(height: 15),

            /// 📝 BIO
            buildField("Bio", bioController, maxLines: 3),

            const SizedBox(height: 30),

            /// 💾 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 INPUT FIELD
  Widget buildField(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),

        filled: true,
        fillColor: const Color(0xFF1A1A1A),

        contentPadding:
        const EdgeInsets.symmetric(horizontal: 15, vertical: 15),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}