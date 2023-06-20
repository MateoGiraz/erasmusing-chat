import 'package:erasmusing_chat/helper/helper_function.dart';
import 'package:erasmusing_chat/pages/profile_page.dart';
import 'package:erasmusing_chat/pages/search_page.dart';
import 'package:erasmusing_chat/service/auth_service.dart';
import 'package:erasmusing_chat/service/database_service.dart';
import 'package:erasmusing_chat/widgets/group_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  bool _isLoading = false;

  String userName = "";
  String email = "";
  String groupName = "";

  Stream? groups;

  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getUserData() async {
    await HelperFunction.getUserName().then((value) => {
          setState(() {
            userName = value!;
          })
        });

    await HelperFunction.getUserEmail().then((value) => {
          setState(() {
            email = value!;
          })
        });

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((value) => {
              setState(() {
                groups = value;
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => nextScreen(context, const SearchPage()),
              icon: Icon(Icons.search)),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Chat",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 27)),
      ),
      drawer: Drawer(
          child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 50),
              children: <Widget>[
            Icon(Icons.account_circle, size: 150, color: Colors.grey[700]),
            const SizedBox(height: 15),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () => nextScreenReplace(
                  context,
                  ProfilePage(
                    userName: userName,
                    email: email,
                  )),
              selectedColor: Theme.of(context).primaryColor,
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
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "LogOut",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ])),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => popUpDialog(context),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  signOut() async {
    authService
        .signOut()
        .whenComplete(() => nextScreenReplace(context, const LoginPage()));
  }

  popUpDialog(context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => StatefulBuilder(
            builder: ((context, setState) => AlertDialog(
                  title: const Text(
                    "Create a group",
                    textAlign: TextAlign.left,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor))
                          : TextField(
                              onChanged: (value) =>
                                  setState(() => groupName = value),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                            )
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (groupName.isNotEmpty) {
                          setState(() => _isLoading = true);
                          DatabaseService(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .createGroup(
                                  userName,
                                  FirebaseAuth.instance.currentUser!.uid,
                                  groupName)
                              .whenComplete(() {
                            Navigator.of(context).pop();
                            showSnackBar(context, "Group created succesfully",
                                Colors.green);
                            setState(() => _isLoading = false);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please enter a group name")));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      child: const Text("Create"),
                    )
                  ],
                ))));
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) => snapshot.hasData
          ? (snapshot.data["groups"] != null &&
                  snapshot.data["groups"].length > 0
              ? ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  itemBuilder: (context, index) {
                    int reverseIndex =
                        snapshot.data['groups'].length - 1 - index;
                    return GroupTile(
                        userName: snapshot.data['fullName'],
                        groupId: getId(snapshot.data['groups'][reverseIndex]),
                        groupName:
                            getName(snapshot.data['groups'][reverseIndex]));
                  },
                )
              : noGroupWidget())
          : Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            ),
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => popUpDialog(context),
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75),
          ),
          const SizedBox(height: 20),
          const Text(
            "You don't have any group yet, tap to create or search for a group to join",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
