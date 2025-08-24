// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// class AdminSignupPage extends StatefulWidget {
//   const AdminSignupPage({super.key});

//   @override
//   State<AdminSignupPage> createState() => _AdminSignupPageState();
// }

// class _AdminSignupPageState extends State<AdminSignupPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final ValueNotifier<bool> isPasswordVisible = ValueNotifier<bool>(false);

//   bool _isLoading = false;

//   Future<void> createAdmin() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final name = nameController.text.trim();
//     final email = emailController.text.trim();
//     final password = passwordController.text;

//     try {
//       final response = await http.post(
//         Uri.parse(
//           'https://astro-j7b4.onrender.com/api/superadmin/create-admin',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'name': name, 'email': email, 'password': password}),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data['message'] ?? 'Admin created successfully'),
//           ),
//         );
//         nameController.clear();
//         emailController.clear();
//         passwordController.clear();
//       } else {
//         final errorData = jsonDecode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to create admin: ${errorData['message'] ?? 'Unknown error'}',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     isPasswordVisible.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade500,
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
//             width: 350,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset('assets/rka.png', height: 60),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "Create Admin Account",
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Name',
//                       prefixIcon: Icon(Icons.person),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator:
//                         (value) =>
//                             value == null || value.isEmpty
//                                 ? 'Please enter name'
//                                 : null,
//                   ),
//                   const SizedBox(height: 15),
//                   TextFormField(
//                     controller: emailController,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email),
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Please enter email';
//                       final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//                       if (!emailRegex.hasMatch(value))
//                         return 'Enter a valid email';
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 15),
//                   ValueListenableBuilder<bool>(
//                     valueListenable: isPasswordVisible,
//                     builder: (context, value, child) {
//                       return TextFormField(
//                         controller: passwordController,
//                         obscureText: !value,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           prefixIcon: const Icon(Icons.lock),
//                           border: const OutlineInputBorder(),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               value ? Icons.visibility_off : Icons.visibility,
//                             ),
//                             onPressed: () => isPasswordVisible.value = !value,
//                           ),
//                         ),
//                         validator:
//                             (value) =>
//                                 value == null || value.length < 3
//                                     ? 'Password must be at least 3 characters'
//                                     : null,
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : createAdmin,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child:
//                           _isLoading
//                               ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                               : const Text('Create Admin'),
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   GestureDetector(
//                     onTap: () {
//                       Get.back(); // Navigate back to login page
//                     },
//                     child: const Text(
//                       "Already have an account? Sign in.",
//                       style: TextStyle(
//                         color: Colors.blue,
//                         decoration: TextDecoration.underline,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
