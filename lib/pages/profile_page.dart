import 'package:erasmusing_chat/pages/home_page.dart';
import 'package:erasmusing_chat/service/auth_service.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  String userName = "";
  String email = "";
  ProfilePage({super.key, required this.userName, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: const Text(
            "Profile",
            style: TextStyle(
                color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
          ),
        ),
        drawer: Drawer(
            child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 50),
                children: <Widget>[
              Icon(Icons.account_circle, size: 150, color: Colors.grey[700]),
              const SizedBox(height: 15),
              Text(
                widget.userName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Divider(
                height: 2,
              ),
              ListTile(
                onTap: () => nextScreen(context, const HomePage()),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.group),
                title: const Text(
                  "Groups",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {},
                selectedColor: Theme.of(context).primaryColor,
                selected: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.account_circle),
                title: const Text(
                  "Profile",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () async => signOut(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.exit_to_app),
                title: const Text(
                  "LogOut",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ])),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 170),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Icon(
                Icons.account_circle,
                size: 200,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Full Name", style: TextStyle(fontSize: 17)),
                  Text(widget.userName, style: TextStyle(fontSize: 17))
                ],
              ),
              const Divider(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Email", style: TextStyle(fontSize: 17)),
                  Text(widget.email, style: TextStyle(fontSize: 17))
                ],
              ),
            ])));
  }

  signOut() async {
    authService
        .signOut()
        .whenComplete(() => nextScreenReplace(context, const LoginPage()));
  }
}
