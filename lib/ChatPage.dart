import 'package:biddy/List/Product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  late String chatRoomId;
  final User? auth = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Product? product;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String winnerID = arguments['winningID'] as String;
    String creatorID = arguments['creatorID'] as String;
    chatRoomId = _generateChatRoomId(winnerID, creatorID);
    createAndStoreChatRoom(winnerID, creatorID);
    /*
    _requestNotificationPermissions();
    _saveDeviceToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        print('Message also contained a notification: ${notification.title}');
      }
    });*/
  }

  Future<String> _getUserName(String userId) async {
    //for testing using chat1@gmail.com
    //for testing using chat2@gmail.com
    String userName = '';
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name']; // Assuming the field name is 'name'
          print(userName);
        });
        return userName;
      } else {
        print('User does not exist');
        return userName;
      }
    } catch (e) {
      print('Error getting user: $e');
      return userName;
    }
  }

  Future<void> createAndStoreChatRoom(String winnerID, String creatorID) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(auth!.uid);
    // Get the user document
    String buyer = await _getUserName(winnerID);
    DocumentSnapshot userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      Map<String, dynamic>? userData = userSnapshot.data()
          as Map<String, dynamic>?; // Cast to Map<String, dynamic> or null
      List<dynamic> chats = userData?['chats'] ?? [];
      // Check if the chat room already exists for the current user
      if (!chats.contains(chatRoomId)) {
        // Create a new document in the 'chatRooms' collection
        DocumentReference newChatRef =
            FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId);
        // Set the chat room data
        await newChatRef.update({
          'users': [winnerID, creatorID],
          'buyer': buyer,
          'seller': await _getUserName(creatorID),
          'createdAt': Timestamp.now(),
        });
        // Add the chat room ID to the user's chats array
        chats.add(chatRoomId);
        await userRef.update({'chats': chats});
        print('New chat room created with ID: $chatRoomId');
      } else {
        print('Chat room already exists');
      }
    } else {
      print('User document not found');
    }
  }

  String _generateChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? '$user1-$user2' : '$user2-$user1';
  }

  void _requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _saveDeviceToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      final currentUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'fcmToken': fcmToken,
      });
    }
  }

  Future<void> _sendMessage() async {
    String lastMessage = _controller.text;
    _controller.clear();
    if (lastMessage.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': lastMessage,
        'createdAt': Timestamp.now(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
      });
      DocumentReference newChatRef =
          FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId);
      // Set the chat room data
      await newChatRef.update({
        'lastMessage': lastMessage,
      });
      _controller.clear();
      _sendNotificationToOtherUser(FirebaseAuth.instance.currentUser!.uid);
    }
  }

  Future _sendNotificationToOtherUser(String winnerID) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid) //change
        .get();
    String? fcmToken = userDoc['fcmToken'];
    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'token': fcmToken,
        'title': 'New Message',
        'body': 'You have a new message in the chat',
      });
      print("noti");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatRoomId),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    bool isMe =
                        doc['userId'] == FirebaseAuth.instance.currentUser!.uid;
                    return ListTile(
                      title: Text(doc['text']),
                      subtitle: Text(isMe ? 'Me' : 'Other'),
                      tileColor: isMe ? Colors.blue[100] : Colors.grey[200],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Create Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
