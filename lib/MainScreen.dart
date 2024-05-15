// ignore_for_file: file_names, prefer_const_constructors, avoid_print, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:biddy/List/Product.dart';
import 'package:biddy/List/Types.dart';
import 'package:biddy/components/CustomDrawer.dart';
import 'package:biddy/functions/animateStart.dart';
import 'package:biddy/functions/signOut.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  String role = 'User';
  final CollectionReference _motorbikesCollection = FirebaseFirestore.instance
      .collection('Ads')
      .doc('Cars')
      .collection('Motorbikes');
  final CollectionReference _sedansCollection = FirebaseFirestore.instance
      .collection('Ads')
      .doc('Cars')
      .collection('Sedans');
  final CollectionReference _suvsCollection = FirebaseFirestore.instance
      .collection('Ads')
      .doc('Cars')
      .collection('SUVs');
  var currentItem = Sedans;
  final User? user = FirebaseAuth.instance.currentUser;
  late AnimationController _controller;
  String _searchQuery = '';
  Offset offsetvar = const Offset(1, 0);
  int selectedIndex = 0;
  int previousIndex = 0;
  String address = 'Cars/Sedans/';
  List<Product> products = [];
  bool isContainerVisible = false;
  int _selectedTab = 0;
  TextEditingController controller = TextEditingController();
  TextEditingController priceMin = TextEditingController();
  TextEditingController priceMax = TextEditingController();
  TextEditingController YearMin = TextEditingController();
  TextEditingController YearMax = TextEditingController();
  TextEditingController KMMin = TextEditingController();
  TextEditingController KMMax = TextEditingController();
  List<bool> expandedList = [false];
  double containerWidth = 60.0;
  bool isExpanded = false;

  @override
  void initState() {
    products = [];
    super.initState();
    login();
    readSubcollectionDocuments('Cars/Sedan/', 0);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100), // Set your animation duration
    );
  }

  _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });

    switch (index) {
      case 0:
        return 'Cars/Sedan/';
      case 1:
        return 'Cars/SUVs/';
      case 2:
        print(user);
        print(user?.uid);
        if (user != null) {
          Navigator.pushNamed(context, '/CreateAd');
        } else {
          Navigator.pushNamed(context,
              '/LoginPage'); //user not signed in dialog box and turn to signin screen
        }

      case 3:
        return 'Cars/SUVs/';
      case 4:
        signOut(context);
      default:
        return 'Unknown'; // Handle unknown index
    }
  }

  void login() async {
    //can be used for getting first name of user
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
          role = data['First'] as String;
          print('Role: $role');
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

  Stream<List<QuerySnapshot>> mergeStreams() {
    // Create a list of streams from each collection
    List<Stream<QuerySnapshot>> streams = [
      _motorbikesCollection.snapshots(),
      _sedansCollection.snapshots(),
      _suvsCollection.snapshots(),
    ];

    // Merge all streams into a single stream
    return CombineLatestStream.list(streams);
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
          products.add(product);
        }

        // Now, 'products' contains all the documents in the subcollection.
        // ignore: unused_local_variable
        for (Product product in products) {
          print(products);
          // Add more fields as needed.
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _selectedTab = 0;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        //silverappbar search kro
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
                    _searchQuery = value.toLowerCase();
                  });
                },
                hintStyle: MaterialStateProperty.all(
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
              onTap: () {},
              child: CircleAvatar(
                radius: 20, // Adjust the size as needed
                backgroundColor: Colors.white, // Background color of the avatar
                backgroundImage: AssetImage('lib/images/avatar.jpg'),
                // You can also put initials or icons inside the avatar
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _searchQuery.isEmpty
              ? Container(
                  // Categories
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 149, 163),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  height: 40.0,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: Types.length,
                    itemBuilder: (BuildContext context, int index) {
                      Type types = Types[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _animateToIndex(index);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8.0, left: 4),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 149, 163),
                              borderRadius: BorderRadius.circular(15)),
                          height: 30,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                types.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: index == selectedIndex
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: index == selectedIndex
                                      ? Colors.white
                                      : Colors.black,
                                  decorationColor: index == selectedIndex
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  height: containerWidth,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        width: 200, // Adjust the width as needed
                        child: ExpansionTile(
                          enableFeedback: false,
                          onExpansionChanged: _handleExpansionChanged,
                          title: Text("Price Range"),
                          //leading: Icon(Icons.price_change),
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Min  "),
                                Container(
                                    width: 60,
                                    child: TextField(
                                      controller: priceMin,
                                    )),
                                Text("Max  "),
                                Container(
                                    width: 60,
                                    child: TextField(
                                      controller: priceMax,
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200, // Adjust the width as needed
                        child: ExpansionTile(
                          onExpansionChanged: _handleExpansionChanged,
                          title: Text("Year Range"),
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Min  "),
                                Container(
                                    width: 60,
                                    child: TextField(
                                      controller: YearMin,
                                    )),
                                Text("Max  "),
                                Container(
                                    width: 60,
                                    child: TextField(
                                      controller: YearMax,
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200, // Adjust the width as needed
                        child: ExpansionTile(
                          onExpansionChanged: _handleExpansionChanged,
                          title: Text("KMs Driven "),
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Min  "),
                                Container(
                                    width: 60,
                                    child: TextField(
                                      controller: KMMin,
                                    )),
                                Text("Max  "),
                                Container(
                                    width: 60,
                                    child: TextField(
                                      controller: KMMax,
                                    ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          Expanded(
            flex: 1000,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      //Change to expanded if any issues
                      child: _searchQuery.isEmpty
                          ? GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 30.0,
                              ),
                              itemCount: products.length,
                              itemBuilder: (BuildContext context, int index) {
                                Product data = products[index];
                                return GestureDetector(
                                  onTap: () {
                                    print(data);
                                    Navigator.pushNamed(context, '/itemScreen',
                                        arguments: {
                                          'product': data,
                                          'id': data.id
                                        });
                                  },
                                  child: Card.filled(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                fit: StackFit.expand,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0), // Adjust the radius as needed
                                                    child: Image.network(
                                                      data.title,
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
                                                            baseColor: Colors
                                                                .grey[300]!,
                                                            highlightColor:
                                                                Colors
                                                                    .grey[100]!,
                                                            child: Container(
                                                                color: Colors
                                                                    .white),
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
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0, vertical: 4),
                                          child: Text(
                                            data.model,
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Text(
                                            '${data.price}',
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : StreamBuilder<List<QuerySnapshot>>(
                              stream: mergeStreams(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError ||
                                    snapshot.data == null) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }

                                // Merge all snapshots into a single list
                                List<DocumentSnapshot> allSnapshots = [];
                                for (var snapList in snapshot.data!) {
                                  allSnapshots.addAll(snapList.docs);
                                }

                                // Filter documents based on search query
                                final filteredDocs = allSnapshots.where((doc) {
                                  final vehicleName =
                                      doc['model'].toString().toLowerCase();
                                  final price = doc['price']
                                      as int; // Assuming price is stored as an integer
                                  final year = doc['year']
                                      as int; // Assuming year is stored as an integer
                                  final time = doc['timestamp2'];
                                  final currentTime = storeTimestamp();
                                  return vehicleName.contains(_searchQuery) &&
                                      ((priceMin.text.isEmpty ||
                                              (int.tryParse(priceMin.text.toString()) ??
                                                      1) <=
                                                  price) &&
                                          (priceMax.text.isEmpty ||
                                              price <=
                                                  (int.tryParse(priceMax.text.toString()) ??
                                                      double.infinity))) &&
                                      ((KMMin.text.isEmpty ||
                                              (int.tryParse(KMMin.text.toString()) ??
                                                      1) <=
                                                  price) &&
                                          (KMMax.text.isEmpty ||
                                              price <=
                                                  (int.tryParse(priceMax.text.toString()) ??
                                                      double.infinity))) &&
                                      ((YearMin.text.isEmpty ||
                                              (int.tryParse(YearMin.text.toString()) ??
                                                      1) <=
                                                  year) &&
                                          time > currentTime &&
                                          (YearMax.text.isEmpty ||
                                              year <=
                                                  (int.tryParse(YearMax.text.toString()) ??
                                                      double.infinity)));
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
                                    final DocumentSnapshot document =
                                        filteredDocs[index];
                                    final List<dynamic>
                                        picsDynamic = //this shit is very imp
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
                                      price: document['price'],
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
                                            context, '/itemScreen', arguments: {
                                          'product': product,
                                          'id': product.id
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
                                                width: 430,
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Image.network(
                                                      product.title,
                                                      width: 300,
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
                                                            baseColor: Colors
                                                                .grey[300]!,
                                                            highlightColor:
                                                                Colors
                                                                    .grey[100]!,
                                                            child: Container(
                                                                color: Colors
                                                                    .white),
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 8),
                                              child: Text(
                                                product.model,
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 8),
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
                  ],
                )),
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create"),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: "Notification"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
      drawer: CustomDrawer(),
    );
  }
}
