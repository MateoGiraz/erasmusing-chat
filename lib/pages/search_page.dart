import 'dart:developer';

import 'package:erasmusing_chat/pages/group_info.dart';
import 'package:erasmusing_chat/service/database_service.dart';
import 'package:erasmusing_chat/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helper/helper_function.dart';
import 'chat_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  bool _hasUserSearch = false;
  bool _isJoined = false;

  QuerySnapshot? searchSnapshot;
  QuerySnapshot? usersSnapshot;

  String username = "";
  User? user;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  getCurrentUser() async {
    await HelperFunction.getUserName()
        .then((value) => setState(() => username = value!));
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text("Search",
                style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(children: [
                Expanded(
                  child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search Groups...",
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16))),
                ),
                GestureDetector(
                  onTap: () => search(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                )
              ]),
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor))
                : groupList(),
            userList()
          ],
        ));
  }

  search() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .getUsers(searchController.text)
          .then((value) => setState(() {
                usersSnapshot = value;
              }));
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .searchGroup(searchController.text)
          .then((snapshot) => setState(() {
                searchSnapshot = snapshot;
                _isLoading = false;
                _hasUserSearch = true;
              }));
    }
  }

  groupList() {
    if (_hasUserSearch) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: searchSnapshot!.docs.length,
          itemBuilder: ((context, index) => groupTile(
              username,
              searchSnapshot!.docs[index]["groupId"],
              searchSnapshot!.docs[index]["groupName"],
              searchSnapshot!.docs[index]["admin"])));
    } else {
      return const Text("hello!");
    }
  }

  userList() {
    if (_hasUserSearch) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: usersSnapshot!.docs.length,
          itemBuilder: ((context, index) => const Text("data")));
    } else {
      return const Text("hello!");
    }
  }

  hasJoined(username, groupId, groupName) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, username)
        .then((value) => setState(() => _isJoined = value));
  }

  Widget groupTile(username, groupId, groupName, admin) {
    hasJoined(username, groupId, groupName);
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 30,
            child: Text(
              groupName.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )),
        title: Text(groupName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Admin: ${admin.split("_")[1]}"),
        trailing: InkWell(
            onTap: () async {
              await DatabaseService(uid: user!.uid)
                  .toggleGroupJoin(groupId, username, groupName);
              if (_isJoined) {
                setState(() {
                  _isJoined = false;
                });
              } else {
                setState(() {
                  _isJoined = true;
                });
                Future.delayed(const Duration(seconds: 1), () {
                  nextScreen(
                      context,
                      ChatPage(
                        groupId: groupId,
                        groupName: groupName,
                        userName: username,
                      ));
                });
              }
            },
            child: _isJoined
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black,
                        border: Border.all(color: Colors.white, width: 1)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: const Text(
                      "Joined",
                      style: TextStyle(color: Colors.white),
                    ))
                : Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: const Text(
                      "Join",
                      style: TextStyle(color: Colors.white),
                    ))));
  }
}
