import 'package:biddy/List/Product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String buyername = '';
  String sellername = '';
  Product? product;
  bool isLoading = true;
  String winnerID = '';
  String creatorID = '';
  String othername = '';
  bool _isLocked = false;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    winnerID = arguments['winningID'] as String;
    creatorID = arguments['creatorID'] as String;
    chatRoomId = _generateChatRoomId(winnerID, creatorID);
    createAndStoreChatRoom(winnerID, creatorID);
    buyername = await _getUserName(winnerID);
    sellername = await _getUserName(creatorID);

    getothername();
    _simulateLoadingDelay();
  }

  Future<void> getothername() async {
    if (winnerID == auth!.uid) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(creatorID)
          .get();
      var data = doc.data() as Map<String, dynamic>;
      othername = data['name'];
    } else {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(winnerID)
          .get();
      var data = doc.data() as Map<String, dynamic>;
      othername = data['name'];
    }
  }

  Future<void> _simulateLoadingDelay() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  Future<String> _getUserName(String userId) async {
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
    buyername = await _getUserName(winnerID);
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
          'buyer': buyername,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Center(
              child: Container(
                color: Colors.white,
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 228, 129, 142),
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0.0,
              backgroundColor: const Color.fromARGB(255, 255, 149, 163),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Center(
                      child: Text(
                        '$othername \'s chat',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: (String result) {
                    switch (result) {
                      case 'Option 1':
                        // Handle Option 1
                        break;
                      case 'Option 2':
                        setState(() {
                          _isLocked = !_isLocked;
                        });
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'Option 1',
                      child: Text('Report Chat'),
                    ),
                    PopupMenuItem<String>(
                      value: 'Option 2',
                      child: Text(_isLocked
                          ? 'Mark Item as Unsold'
                          : 'Mark Item as Sold'),
                    ),
                  ],
                ),
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
                          bool isMe = doc['userId'] ==
                              FirebaseAuth.instance.currentUser!.uid;
                          return Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15.0),
                                margin: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Color.fromARGB(255, 255, 149, 164)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc['text'],
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.black),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      isMe ? 'You' : '$othername',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                          enabled: !_isLocked,
                          decoration: InputDecoration(
                            labelText: _isLocked ? 'Chat Closed' : 'Enter text',
                            labelStyle: TextStyle(
                                color: Color.fromARGB(
                                    255, 255, 149, 164)), // Change label color
                            hintText: 'Type your message here...',
                            hintStyle: TextStyle(
                                color: Colors.grey), // Change hint text color
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Change border color when enabled
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 255, 149,
                                      164)), // Change border color when focused
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_upward),
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
