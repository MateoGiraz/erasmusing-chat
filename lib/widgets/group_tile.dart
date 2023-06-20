import 'package:erasmusing_chat/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/chat_page.dart';
import '../service/database_service.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;

  const GroupTile(
      {super.key,
      required this.userName,
      required this.groupId,
      required this.groupName});

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => nextScreen(
          context,
          ChatPage(
            groupName: widget.groupName,
            groupId: widget.groupId,
            userName: widget.userName,
          )),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(widget.groupName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            title: Text(widget.groupName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text("Join the conversation as ${widget.userName}",
                  style: const TextStyle(fontSize: 13)),
            ),
          )),
    );
  }
}
