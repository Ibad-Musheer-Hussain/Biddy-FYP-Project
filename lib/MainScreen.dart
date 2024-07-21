// ignore_for_file: file_names, prefer_const_constructors, avoid_print, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:async';

import 'package:biddy/List/Product.dart';
import 'package:biddy/NeedLoginDialog.dart';
import 'package:biddy/components/CategoryList.dart';
import 'package:biddy/components/CustomDrawer.dart';
import 'package:biddy/components/FilterOptions.dart';
import 'package:biddy/functions/animateStart.dart';
import 'package:biddy/functions/mergeStreams.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool favoriteclicked = false;
  var currentItem = Sedans;
  final user = FirebaseAuth.instance.currentUser;
  late AnimationController _controller;
  String _searchQuery = '';
  Offset offsetvar = const Offset(1, 0);
  int selectedIndex = 0, previousIndex = 0, balance = 0;
  String address = 'Cars/Sedans/';
  String name = "User Last Name";
  bool showCategoryList = true;
  List<Product> products = [];
  bool isContainerVisible = false,
      _homeactive = true,
      chatactive = false,
      historyactive = false,
      isExpanded = false;
  int _selectedTab = 0;
  TextEditingController controller = TextEditingController(),
      priceMin = TextEditingController(),
      priceMax = TextEditingController(),
      YearMin = TextEditingController(),
      YearMax = TextEditingController(),
      KMMin = TextEditingController(),
      KMMax = TextEditingController();
  List<bool> expandedList = [false];
  double containerWidth = 60.0;
  List<dynamic> favourites = [], history = [], chatrooms = [];
  late Future<List<String>> chatRoomIds;
  List<String> chatsadded = [];
  List<String> chatIds = [];

  @override
  void initState() {
    products = [];
    super.initState();
    login();
    fetchFavourites();
    readSubcollectionDocuments('Cars/Sedan/', 0);
    loadChatrooms();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100), // Set your animation duration
    );
  }

  Future<void> loadChatrooms() async {
    chatIds = await _getUserChatRooms();
    getChatrooms(chatIds);
  }

  Future<List<String>> _getUserChatRooms() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (!userDoc.exists ||
          userDoc.data() == null ||
          userDoc['chats'] == null) {
        return [];
      }

      chatIds = List<String>.from(userDoc['chats'] ?? []);

      if (chatIds.isEmpty) {
        return [];
      }

      return chatIds;
    } catch (e) {
      print('Error fetching chat rooms: $e');
      return [];
    }
  }

  void getChatrooms(List<String> chatIds) {
    chatsadded.clear();
    for (String chatId in chatIds) {
      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatId)
          .get()
          .then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          chatrooms.add(snapshot);
          chatsadded.add(chatId);
        }
      });
    }
  }

  _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });

    switch (index) {
      case 0:
        login();
        _homeactive = true;
        showCategoryList = true;
        chatactive = false;
        historyactive = false;
        favoriteclicked = false;
        return 'Cars/Sedan/';
      case 1:
        _homeactive = false;
        showCategoryList = false;
        favoriteclicked = true;
        historyactive = false;
        chatactive = false;
        fetchFavourites();
      case 2:
        favoriteclicked = false;
        showCategoryList = false;
        chatactive = false;
        historyactive = false;
        _homeactive = false;
        if (user != null) {
          _changeTab(0);
          Navigator.pushNamed(context, '/CreateAd');
          _changeTab(0);
        } else {
          index = 0;
          _changeTab(index);
          _showLoginDialog(
              context); //user not signed in dialog box and turn to signin screen
        }

      case 3:
        favoriteclicked = false;
        chatactive = true;
        showCategoryList = false;
        historyactive = false;
        _homeactive = false;
        chatIds.clear;
        loadChatrooms();
        return 'Cars/SUVs/';
      case 4:
        favoriteclicked = false;
        chatactive = false;
        showCategoryList = false;
        _homeactive = false;
        historyactive = true;
        fetchHistory();

      default:
        return 'Unknown'; // Handle unknown index
    }
  }

  Future<void> fetchFavourites() async {
    try {
      print(user?.uid);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          favourites = userDoc.get('favourites') ?? [];
        });
      }
    } catch (e) {
      print("Error fetching favourites: $e");
    }
  }

  Future<void> fetchHistory() async {
    try {
      print(user?.uid);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          history = userDoc.get('history') ?? [];
        });
      }
      print(history);
    } catch (e) {
      print("Error fetching History: $e");
    }
  }

  void login() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          name = data['name'];
          balance = data['balance'];
          print('name: $name');
          print('Balance: $balance');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  int storeTimestamp() {
    tz.initializeTimeZones();
    DateTime now = DateTime.now();
    String karachiTimeZone = 'Asia/Karachi';
    tz.Location karachiLocation = tz.getLocation(karachiTimeZone);
    tz.TZDateTime karachiTime = tz.TZDateTime.from(now, karachiLocation);
    Timestamp timestamp = Timestamp.fromDate(karachiTime);
    int timestampMillis = timestamp.millisecondsSinceEpoch;
    print('Timestamp stored successfully!');
    return timestampMillis;
  }

  void _animateToIndex(int index) {
    setState(() {
      selectedIndex = index;
      _changeTab(0);
      products = []; // Reset products for new selection
      // Map index to corresponding address and currentItem
      address = {
        0: 'Cars/Sedan/',
        1: 'Cars/SUVs/',
        2: 'Cars/Coupes/',
        3: 'Cars/Hatchbacks/',
        4: 'Cars/Hybrid/',
        5: 'Cars/Motorbikes/'
      }[index]!; // Ensure value exists using !
      currentItem = Sedans; // Assuming currentItem is always Sedans
    });
    readSubcollectionDocuments(address, index);
  }

  Future<void> readSubcollectionDocuments(String address, int index) async {
    try {
      CollectionReference subCollectionRef =
          FirebaseFirestore.instance.collection('/Ads/$address');

      QuerySnapshot subCollectionSnapshot = await subCollectionRef.get();
      products = [];
      if (subCollectionSnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot subDocSnapshot
            in subCollectionSnapshot.docs) {
          // Convert Firestore data to Product objects.
          Product product =
              Product.fromMap(subDocSnapshot.data() as Map<String, dynamic>);
          print(product);
          if (product.timestamp2 > DateTime.now().millisecondsSinceEpoch) {
            products.add(product);
          }
        }
        // Now, 'products' contains all the documents in the subcollection.

        // ignore: unused_local_variable
        for (Product product in products) {
          print(products);
        }
        animateStart(index, previousIndex, selectedIndex, _controller);
        setState(() {
          offsetvar =
              animateStart(index, previousIndex, selectedIndex, _controller);
          previousIndex = selectedIndex;
        });
      } else {
        print('No documents found in the subcollection.');
      }
    } catch (e) {
      print('Error reading subcollection: $e');
    }
  }

  void _handleExpansionChanged(bool isExpanded) {
    setState(() {
      if (isExpanded) {
        containerWidth = 120;
      } else {
        containerWidth = 60;
      }
      isExpanded = !isExpanded;
    });
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NeedLogin();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        scrolledUnderElevation:
            0.0, //for disabling changing of color when scrolling app
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 255, 149, 163),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 3),
              height: 40,
              width: MediaQuery.of(context).size.width / 1.38,
              child: SearchBar(
                hintText: "Search for vehicles",
                controller: controller,
                trailing: [
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        onPressed: () {
                          controller.clear();
                          priceMax.clear;
                          priceMin.clear;
                          YearMax.clear;
                          YearMin.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(Icons.close),
                        color: Colors.white,
                      );
                    },
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _homeactive = true;
                    chatactive = false;
                    historyactive = false;
                    favoriteclicked = false;
                    _changeTab(0);
                    _searchQuery = value.toLowerCase();
                  });
                },
                hintStyle: WidgetStateProperty.all(
                  const TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                  ),
                ),
                leading: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.search),
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: 12,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (user != null) {
                  login();
                  _scaffoldKey.currentState?.openDrawer();
                } else {
                  //_showLoginDialog(context);
                  Navigator.pushNamed(
                    context,
                    '/LoginPage',
                    arguments: {},
                  );
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('lib/images/avatar.jpg'),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_searchQuery.isEmpty && showCategoryList == true)
            CategoryList(
                types: Types,
                selectedIndex: selectedIndex,
                onCategoryTap: _animateToIndex)
          else if (_searchQuery.isEmpty && showCategoryList == false)
            Container()
          else
            FilterOptions(
                priceMin: priceMin,
                priceMax: priceMax,
                yearMin: YearMin,
                yearMax: YearMax,
                kmMin: KMMin,
                kmMax: KMMax,
                onExpansionChanged: _handleExpansionChanged),
          chatactive
              ? Expanded(
                  // CHATS
                  child: chatsadded.isEmpty
                      ? Center(child: Text('You have no active chats'))
                      : ListView.builder(
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: chatsadded.length,
                          itemBuilder: (BuildContext context, int index) {
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('chatRooms')
                                  .doc(chatsadded[index])
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  }

                                  if (snapshot.hasData &&
                                      snapshot.data!.exists) {
                                    var data = snapshot.data!.data()
                                        as Map<String, dynamic>;
                                    List<dynamic> users = data['users'];
                                    if (users.length == 2 &&
                                        users.every((user) => user is String)) {
                                      String user1 = users[0];
                                      String user2 = users[1];
                                      return GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/chatPage',
                                              arguments: {
                                                'winningID': user1,
                                                'creatorID': user2,
                                              },
                                            );
                                          },
                                          child: ListTile(
                                              leading: Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        '${data['title']}'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              title: Text("${data['buyer']}"),
                                              trailing: IconButton(
                                                icon: Icon(Icons.arrow_forward),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/chatPage',
                                                    arguments: {
                                                      'winningID': user1,
                                                      'creatorID': user2,
                                                    },
                                                  );
                                                },
                                              ),
                                              subtitle: Text(
                                                "Me: ${data['lastMessage']}",
                                              )));
                                    } else {
                                      return Center(
                                        child: Text(
                                          'Expected exactly two user IDs for chatId: ${chatsadded[index]}',
                                        ),
                                      );
                                    }
                                  } else {
                                    return Center(
                                      child: Container(
                                        color: Colors.red,
                                        child: Text(
                                          'Document does not exist for chatId: ${chatsadded[index]}',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  return Center(
                                    child: Text(
                                        'State: ${snapshot.connectionState}'),
                                  );
                                }
                              },
                            );
                          },
                        ),
                )
              : historyactive
                  ? Expanded(
                      child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RefreshIndicator(
                        onRefresh: () => fetchHistory(),
                        child: StreamBuilder<List<QuerySnapshot>>(
                          stream: mergeStreams(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            List<DocumentSnapshot> allSnapshots = [];
                            for (var snapList in snapshot.data!) {
                              allSnapshots.addAll(snapList.docs);
                            }
                            // Filter documents based on history and search query
                            final filteredDocs = allSnapshots.where((doc) {
                              final docId = doc['id'];
                              // Filter by history
                              final isHistory = history.contains(docId);
                              return isHistory;
                            }).toList();

                            if (filteredDocs.isEmpty) {
                              return Center(
                                child: Text('Your history is empty.'),
                              );
                            }
                            return ListView.builder(
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final DocumentSnapshot document =
                                    filteredDocs[index];
                                final List<dynamic> picsDynamic =
                                    document['pics'] ?? [];
                                final List<String> uploadedImageUrls2 =
                                    picsDynamic
                                        .map((pic) => pic.toString())
                                        .toList();
                                Product product = Product(
                                  brand: document['brand'],
                                  model: document['model'],
                                  year: document['year'],
                                  title: document['title'],
                                  id: document['id'],
                                  fuel: document['fuel'],
                                  price: document['price'],
                                  kms: document['kms'],
                                  city: document['city'],
                                  creatorID: document['creatorID'],
                                  transmission: document['transmission'],
                                  winningid: document['winningid'],
                                  collectionValue: document['collectionValue'],
                                  description: 'change',
                                  timestamp: document['timestamp'],
                                  timestamp2: document['timestamp2'],
                                  uploadedImageUrls: uploadedImageUrls2,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/itemScreen',
                                        arguments: {
                                          'product': product,
                                          'id': product.id,
                                        });
                                  },
                                  child: Card.filled(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            height: 270,
                                            width: 400,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Adjust the radius as needed
                                                  child: Image.network(
                                                    product.title,
                                                    width: 300,
                                                    height: 270,
                                                    fit: BoxFit.fill,
                                                    frameBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        int? frame,
                                                        bool
                                                            wasSynchronouslyLoaded) {
                                                      if (frame != null) {
                                                        return child; // Return the image if frame is not null (indicating loaded)
                                                      } else {
                                                        return Shimmer
                                                            .fromColors(
                                                          baseColor:
                                                              Colors.grey[300]!,
                                                          highlightColor:
                                                              Colors.grey[100]!,
                                                          child: Container(
                                                              color:
                                                                  Colors.white),
                                                        ); // Show shimmer effect while the image is loading
                                                      }
                                                    },
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child; // Return the image if loading is complete
                                                      } else {
                                                        return child; // Return the image with loading progress if it's still loading
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0, vertical: 4),
                                          child: Text(
                                            product.model,
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Text(
                                            '${product.price}',
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ))
                  : Expanded(
                      child: favoriteclicked
                          ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: RefreshIndicator(
                                onRefresh: () => fetchFavourites(),
                                child: StreamBuilder<List<QuerySnapshot>>(
                                  stream: mergeStreams(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    List<DocumentSnapshot> allSnapshots = [];
                                    for (var snapList in snapshot.data!) {
                                      allSnapshots.addAll(snapList.docs);
                                    }
                                    // Filter documents based on favourites and search query
                                    final filteredDocs =
                                        allSnapshots.where((doc) {
                                      final docId = doc['id'];
                                      // Filter by favourites
                                      final isFavourite =
                                          favourites.contains(docId);
                                      return isFavourite;
                                    }).toList();

                                    if (filteredDocs.isEmpty) {
                                      return Center(
                                        child: Text('You have no favorites'),
                                      );
                                    }
                                    return ListView.builder(
                                      itemCount: filteredDocs.length,
                                      itemBuilder: (context, index) {
                                        final DocumentSnapshot document =
                                            filteredDocs[index];
                                        final List<dynamic> picsDynamic =
                                            document['pics'] ?? [];
                                        final List<String> uploadedImageUrls2 =
                                            picsDynamic
                                                .map((pic) => pic.toString())
                                                .toList();
                                        Product product = Product(
                                          brand: document['brand'],
                                          model: document['model'],
                                          year: document['year'],
                                          title: document['title'],
                                          id: document['id'],
                                          fuel: document['fuel'],
                                          price: document['price'],
                                          kms: document['kms'],
                                          city: document['city'],
                                          creatorID: document['creatorID'],
                                          transmission:
                                              document['transmission'],
                                          winningid: document['winningid'],
                                          collectionValue:
                                              document['collectionValue'],
                                          description: 'change',
                                          timestamp: document['timestamp'],
                                          timestamp2: document['timestamp2'],
                                          uploadedImageUrls: uploadedImageUrls2,
                                        );

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/itemScreen',
                                                arguments: {
                                                  'product': product,
                                                  'id': product.id,
                                                });
                                          },
                                          child: Card.filled(
                                            color: Colors.transparent,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    height: 270,
                                                    width: 400,
                                                    child: Stack(
                                                      fit: StackFit.expand,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  8.0), // Adjust the radius as needed
                                                          child: Image.network(
                                                            product.title,
                                                            width: 300,
                                                            height: 270,
                                                            fit: BoxFit.fill,
                                                            frameBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    int? frame,
                                                                    bool
                                                                        wasSynchronouslyLoaded) {
                                                              if (frame !=
                                                                  null) {
                                                                return child; // Return the image if frame is not null (indicating loaded)
                                                              } else {
                                                                return Shimmer
                                                                    .fromColors(
                                                                  baseColor:
                                                                      Colors.grey[
                                                                          300]!,
                                                                  highlightColor:
                                                                      Colors.grey[
                                                                          100]!,
                                                                  child: Container(
                                                                      color: Colors
                                                                          .white),
                                                                ); // Show shimmer effect while the image is loading
                                                              }
                                                            },
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child; // Return the image if loading is complete
                                                              } else {
                                                                return child; // Return the image with loading progress if it's still loading
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4.0,
                                                      vertical: 4),
                                                  child: Text(
                                                    product.model,
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4.0),
                                                  child: Text(
                                                    '${product.price}',
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            )
                          : Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Container(
                                    child: _searchQuery.isEmpty
                                        ? RefreshIndicator(
                                            onRefresh: () =>
                                                readSubcollectionDocuments(
                                                    address, _selectedTab),
                                            child: GridView.builder(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 1,
                                                mainAxisSpacing: 30.0,
                                              ),
                                              itemCount: products.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                Product data = products[index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                        context, '/itemScreen',
                                                        arguments: {
                                                          'product': data,
                                                          'id': data.id
                                                        });
                                                  },
                                                  child: Card.filled(
                                                    color: Colors.transparent,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Expanded(
                                                          child: Center(
                                                            child: Container(
                                                              height: 270,
                                                              width: 430,
                                                              child: Stack(
                                                                fit: StackFit
                                                                    .expand,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0), // Adjust the radius as needed
                                                                    child: Image
                                                                        .network(
                                                                      data.title,
                                                                      width:
                                                                          300,
                                                                      height:
                                                                          270,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      frameBuilder: (BuildContext context,
                                                                          Widget
                                                                              child,
                                                                          int?
                                                                              frame,
                                                                          bool
                                                                              wasSynchronouslyLoaded) {
                                                                        if (frame !=
                                                                            null) {
                                                                          return child; // Return the image if frame is not null (indicating loaded)
                                                                        } else {
                                                                          return Shimmer
                                                                              .fromColors(
                                                                            baseColor:
                                                                                Colors.grey[300]!,
                                                                            highlightColor:
                                                                                Colors.grey[100]!,
                                                                            child:
                                                                                Container(color: Colors.white),
                                                                          ); // Show shimmer effect while the image is loading
                                                                        }
                                                                      },
                                                                      loadingBuilder: (BuildContext context,
                                                                          Widget
                                                                              child,
                                                                          ImageChunkEvent?
                                                                              loadingProgress) {
                                                                        if (loadingProgress ==
                                                                            null) {
                                                                          return child; // Return the image if loading is complete
                                                                        } else {
                                                                          return child; // Return the image with loading progress if it's still loading
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0,
                                                                  vertical: 4),
                                                          child: Text(
                                                            data.model,
                                                            style: TextStyle(
                                                                fontSize: 22,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          child: Text(
                                                            '${data.price}',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        18),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : StreamBuilder<List<QuerySnapshot>>(
                                            stream: mergeStreams(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              if (snapshot.hasError ||
                                                  snapshot.data == null) {
                                                return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'),
                                                );
                                              }

                                              // Merge all snapshots into a single list
                                              List<DocumentSnapshot>
                                                  allSnapshots = [];
                                              for (var snapList
                                                  in snapshot.data!) {
                                                allSnapshots
                                                    .addAll(snapList.docs);
                                              }

                                              // Filter documents based on search query
                                              final filteredDocs =
                                                  allSnapshots.where((doc) {
                                                final vehicleName = doc['model']
                                                    .toString()
                                                    .toLowerCase();
                                                final price = doc['price']
                                                    as int; // Assuming price is stored as an integer
                                                final year = doc['year']
                                                    as int; // Assuming year is stored as an integer
                                                final time = doc['timestamp2'];
                                                final currentTime =
                                                    storeTimestamp();
                                                return vehicleName.contains(_searchQuery) &&
                                                    ((priceMin.text.isEmpty ||
                                                            (int.tryParse(priceMin.text.toString()) ?? 1) <=
                                                                price) &&
                                                        (priceMax.text.isEmpty ||
                                                            price <=
                                                                (int.tryParse(priceMax.text.toString()) ??
                                                                    double
                                                                        .infinity))) &&
                                                    ((KMMin.text.isEmpty ||
                                                            (int.tryParse(KMMin.text.toString()) ?? 1) <=
                                                                price) &&
                                                        (KMMax.text.isEmpty ||
                                                            price <=
                                                                (int.tryParse(priceMax.text.toString()) ??
                                                                    double
                                                                        .infinity))) &&
                                                    ((YearMin.text.isEmpty ||
                                                            (int.tryParse(YearMin.text.toString()) ??
                                                                    1) <=
                                                                year) &&
                                                        time > currentTime &&
                                                        (YearMax.text.isEmpty ||
                                                            year <= (int.tryParse(YearMax.text.toString()) ?? double.infinity)));
                                              }).toList();

                                              if (filteredDocs.isEmpty) {
                                                return Center(
                                                  child: Text(
                                                      'No results found. Try changing or resetting the filter settings'),
                                                );
                                              }
                                              return ListView.builder(
                                                itemCount: filteredDocs.length,
                                                itemBuilder: (context, index) {
                                                  final DocumentSnapshot
                                                      document =
                                                      filteredDocs[index];
                                                  final List<dynamic>
                                                      picsDynamic = //this shit is very imp
                                                      document['pics'] ?? [];
                                                  final List<String>
                                                      uploadedImageUrls2 =
                                                      picsDynamic
                                                          .map((pic) =>
                                                              pic.toString())
                                                          .toList();
                                                  Product product = Product(
                                                    brand: document['brand'],
                                                    model: document['model'],
                                                    year: document['year'],
                                                    title: document['title'],
                                                    id: document['id'],
                                                    fuel: document['fuel'],
                                                    price: document['price'],
                                                    kms: document['kms'],
                                                    city: document['city'],
                                                    creatorID:
                                                        document['creatorID'],
                                                    transmission: document[
                                                        'transmission'],
                                                    winningid:
                                                        document['winningid'],
                                                    collectionValue: document[
                                                        'collectionValue'],
                                                    description: 'change',
                                                    timestamp:
                                                        document['timestamp'],
                                                    timestamp2:
                                                        document['timestamp2'],
                                                    uploadedImageUrls:
                                                        uploadedImageUrls2,
                                                  );
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/itemScreen',
                                                          arguments: {
                                                            'product': product,
                                                            'id': product.id
                                                          });
                                                    },
                                                    child: Card.filled(
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Center(
                                                            child: Container(
                                                              height: 270,
                                                              width: 400,
                                                              child: Stack(
                                                                fit: StackFit
                                                                    .expand,
                                                                children: [
                                                                  Image.network(
                                                                    product
                                                                        .title,
                                                                    width: 300,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    frameBuilder: (BuildContext
                                                                            context,
                                                                        Widget
                                                                            child,
                                                                        int?
                                                                            frame,
                                                                        bool
                                                                            wasSynchronouslyLoaded) {
                                                                      if (frame !=
                                                                          null) {
                                                                        return child; // Return the image if frame is not null (indicating loaded)
                                                                      } else {
                                                                        return Shimmer
                                                                            .fromColors(
                                                                          baseColor:
                                                                              Colors.grey[300]!,
                                                                          highlightColor:
                                                                              Colors.grey[100]!,
                                                                          child:
                                                                              Container(color: Colors.white),
                                                                        ); // Show shimmer effect while the image is loading
                                                                      }
                                                                    },
                                                                    loadingBuilder: (BuildContext
                                                                            context,
                                                                        Widget
                                                                            child,
                                                                        ImageChunkEvent?
                                                                            loadingProgress) {
                                                                      if (loadingProgress ==
                                                                          null) {
                                                                        return child; // Return the image if loading is complete
                                                                      } else {
                                                                        return child; // Return the image with loading progress if it's still loading
                                                                      }
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        8),
                                                            child: Text(
                                                              product.model,
                                                              style: TextStyle(
                                                                  fontSize: 18),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        8),
                                                            child: Text(
                                                              '${product.price}',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                  )),
                            ),
                    )
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          currentIndex: _selectedTab,
          onTap: (index) => _changeTab(index),
          unselectedItemColor: Colors.black,
          backgroundColor:
              Color.fromARGB(255, 255, 149, 163), // Set background color
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                  color: _homeactive ? Colors.white : Colors.black,
                ),
                label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite_border_outlined,
                  color: favoriteclicked ? Colors.white : Colors.black,
                ),
                label: "Favorite"),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.message_outlined,
                  color: chatactive ? Colors.white : Colors.black,
                ),
                label: "Chats"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.history,
                  color: historyactive ? Colors.white : Colors.black,
                ),
                label: "History"),
          ],
        ),
      ),
      drawer: CustomDrawer(
          name: name,
          balance: balance,
          onBidHistoryTap: () {
            _changeTab(4);
          }),
    );
  }
}
