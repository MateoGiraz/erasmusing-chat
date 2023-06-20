import 'package:erasmusing_chat/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;

  const GroupInfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.adminName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) => setState(() => members = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group info"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(0.2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(widget.groupName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Group: ${widget.groupName}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text("Admin: ${widget.adminName}"),
                ])
              ],
            ),
          ),
          memberList(),
        ]),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
        stream: members,
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data["members"] != null &&
                snapshot.data["members"] != 0) {
              return ListView.builder(
                  itemCount: snapshot.data["members"].length,
                  shrinkWrap: true,
                  itemBuilder: ((context, index) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              snapshot.data['members'][index]
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          title: Text(
                              snapshot.data["members"][index].split("_")[1]),
                          subtitle: Text(
                              snapshot.data["members"][index].split("_")[0]),
                        ),
                      )));
            } else {
              return const Center(child: Text("No members"));
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          }
        }));
  }
}
