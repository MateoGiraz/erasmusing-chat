import 'package:erasmusing_chat/helper/helper_function.dart';
import 'package:erasmusing_chat/pages/auth/login_page.dart';
import 'package:erasmusing_chat/pages/home_page.dart';
import 'package:erasmusing_chat/service/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  AuthService authService = AuthService();

  bool _isLoading = false;

  String email = "";
  String password = "";
  String fullName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text("Erasmusing",
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("Log in to join the chat!",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400)),
                        Image.asset("assets/login.png"),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: "Full Name",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              )),
                          onChanged: (value) =>
                              setState(() => fullName = value),
                          validator: (value) => value!.isNotEmpty
                              ? null
                              : "Name must not be empty!",
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                            decoration: textInputDecoration.copyWith(
                                labelText: "Email",
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColor,
                                )),
                            onChanged: (value) => setState(() => email = value),
                            validator: (value) =>
                                RegExp("^(.+)@(.+)").hasMatch(value!)
                                    ? null
                                    : "invalid email"),
                        const SizedBox(height: 20),
                        TextFormField(
                            obscureText: true,
                            decoration: textInputDecoration.copyWith(
                                labelText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Theme.of(context).primaryColor,
                                )),
                            onChanged: (value) =>
                                setState(() => password = value),
                            validator: (value) => value!.length < 6
                                ? "password must be at least 6 characters"
                                : null),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              onPressed: () => register()),
                        ),
                        const SizedBox(height: 10),
                        Text.rich(TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Login here!",
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        nextScreen(context, const LoginPage()))
                            ],
                            text: "Already have an account? ",
                            style: const TextStyle(fontSize: 14))),
                      ],
                    )),
              ),
            ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerUser(fullName, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmail(email);
          await HelperFunction.saveUserName(fullName);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackBar(context, value, Colors.red);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
