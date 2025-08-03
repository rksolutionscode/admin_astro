import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:testadm/permission_controller.dart';
import 'package:testadm/rasi.dart';

class Logincredintialpage extends StatefulWidget {
  const Logincredintialpage({super.key});

  @override
  State<Logincredintialpage> createState() => _LoginPageState();
}

class _LoginPageState extends State<Logincredintialpage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController adminIdController = TextEditingController();
  final ValueNotifier<bool> isPasswordVisible = ValueNotifier<bool>(false);

  Future<void> validateAndLogin() async {
    final String adminId = adminIdController.text.trim();
    final String username = usernameController.text.trim();
    final String password = passwordController.text;

    if (adminId.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('accountcreate')
              .where('adminId', isEqualTo: adminId)
              .where('username', isEqualTo: username)
              .where('password', isEqualTo: password)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final userDoc = snapshot.docs.first;
        final permission = userDoc['permission'] ?? {};

        final controller = Get.find<PermissionController>();
        controller.setPermissions(Map<String, dynamic>.from(permission));

        // ✅ Navigate based on access
        if (controller.getAllowedValues('rasi').isNotEmpty) {
          Get.offAll(() => AddRasiScreen());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Access denied: No Rasi permission")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Admin ID, Username, or Password"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    adminIdController.dispose();
    isPasswordVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade500,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/rka.png', height: 60),
              const SizedBox(height: 10),
              const Text(
                "Sign in with Admin ID, Username & Password",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: adminIdController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.admin_panel_settings),
                  labelText: 'Admin ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder<bool>(
                valueListenable: isPasswordVisible,
                builder: (context, value, child) {
                  return TextField(
                    controller: passwordController,
                    obscureText: !value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          value ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          isPasswordVisible.value = !value;
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validateAndLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Sign in"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
