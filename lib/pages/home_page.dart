import 'package:erasmusing_chat/service/auth_service.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(
      onPressed: () => signOut(),
      child: const Text("Sign Out"),
    )));
  }

  signOut() async {
    await authService.signOut();
    nextScreen(context, const LoginPage());
  }
}
