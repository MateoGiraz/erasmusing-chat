import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupsCollection =
      FirebaseFirestore.instance.collection("groups");

  Future saveUser(fullName, email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid
    });
  }

  Future getUser(email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  Future getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  Future getUsers(name) async {
    return userCollection.where("fullName", isEqualTo: name).get();
  }

  Future createGroup(username, id, groupName) async {
    DocumentReference groupDocRef = await groupsCollection.add({
      "groupName": groupName,
      "admin": "${id}_$username",
      "members": [],
      "groupIcon": "",
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": ""
    });

    await groupDocRef.update({
      "members": FieldValue.arrayUnion(["${id}_$username"]),
      "groupId": groupDocRef.id
    });

    await userCollection.doc(uid).update({
      "groups": FieldValue.arrayUnion(["${groupDocRef.id}_$groupName"])
    });
  }

  Future getChats(groupId) async {
    return groupsCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time", descending: false)
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentSnapshot documentSnapshot =
        await groupsCollection.doc(groupId).get();
    return documentSnapshot["admin"];
  }

  Future getGroupMembers(String groupId) async {
    return groupsCollection.doc(groupId).snapshots();
  }

  Future searchGroup(name) async {
    QuerySnapshot snapshot =
        await groupsCollection.where("groupName", isEqualTo: name).get();
    return snapshot;
  }

  Future<bool> isUserJoined(groupName, groupId, userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocRef.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    return groups.contains("${groupId}_$groupName");
  }

  Future toggleGroupJoin(groupId, username, groupname) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentReference groupDocRef = groupsCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocRef.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupname")) {
      await userDocRef.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupname"])
      });
      await groupDocRef.update({
        "members": FieldValue.arrayRemove(["${uid}_$username"])
      });
    } else {
      await userDocRef.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupname"])
      });
      await groupDocRef.update({
        "members": FieldValue.arrayUnion(["${uid}_$username"])
      });
    }
  }

  Future sendMessage(groupId, chatMessageData) async {
    groupsCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupsCollection.doc(groupId).update({
      "recentMessage": chatMessageData["message"],
      "recentMessageSender": chatMessageData["sender"],
      "recentMessageTime": chatMessageData["time"].toString()
    });
  }
}
