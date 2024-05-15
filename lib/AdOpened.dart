// ignore_for_file: await_only_futures, file_names, library_private_types_in_public_api, deprecated_member_use, sized_box_for_whitespace, avoid_print, non_constant_identifier_names, avoid_unnecessary_containers, unused_local_variable, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:biddy/List/Product.dart';
import 'package:biddy/Signing.dart';
import 'package:biddy/components/FABcustom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:biddy/functions/openimagenetwork.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  int flag = 0; //for snackbar displaying that price has been updated
  int price = 0;
  String address = '';
  late Timer _timer;
  Duration _remainingTime = const Duration();
  final User? auth = FirebaseAuth.instance.currentUser;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    address = arguments['id'] as String;
    Product products = arguments['product'] as Product;
    FirebaseDatabase.instance
        .reference()
        .child('adsCollection')
        .child('Cars')
        .child(products.collectionValue)
        .child(address)
        .child('price')
        .onValue
        .listen((event) {
      if (flag < 1) {
        print("value changed"); // change to snackbar later //neccessary
      }
      flag++;
      if (event.snapshot.value != null) {
        setState(() {
          print(event.snapshot.value);
          price = event.snapshot.value as int;
        });
      }
    });
  }

  Future<void> updateCarPrice(
      String adId, int Price, String collectionaddress) async {
    try {
      DocumentReference adRefFirestore =
          FirebaseFirestore.instance // Get the document reference for Firestore
              .collection('Ads')
              .doc('Cars')
              .collection(collectionaddress)
              .doc(adId);

      DatabaseReference adRefRealtime = FirebaseDatabase
          .instance // Get the document reference for the Realtime Database
          .reference()
          .child('adsCollection')
          .child('Cars')
          .child(collectionaddress)
          .child(adId);

      DocumentSnapshot adSnapshotBefore = await adRefFirestore
          .get(); // Get the latest data before the transaction from Firestore
      int priceBefore = adSnapshotBefore.exists
          ? (adSnapshotBefore.data() != null
              ? (adSnapshotBefore.data()! as Map<String, dynamic>)['price'] ?? 0
              : 0)
          : 0;
      print('Price before transaction (Firestore): $priceBefore');

      // Get the latest data before the transaction from the Realtime Database
      DataSnapshot adSnapshotBeforeRealtime =
          await adRefRealtime.once().then((snapshot) => snapshot.snapshot);

      int priceBeforeRealtime = 0; // Default value
      int priceAfterRealtime = 0;
      int price = 0;

      // Check if the value is a map with dynamic keys
      if (adSnapshotBeforeRealtime.value is Map<dynamic, dynamic>) {
        // Cast the value to a map with dynamic keys
        Map<dynamic, dynamic>? data =
            adSnapshotBeforeRealtime.value as Map<dynamic, dynamic>?;

        // Check if the 'price' key exists and is an integer
        if (data != null && data.containsKey('price') && data['price'] is int) {
          priceBeforeRealtime = data['price'] as int;
          price = priceBeforeRealtime + 500;
        }
      }
      print(
          'Price before transaction (Realtime Database): $priceBeforeRealtime');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot adSnapshot = await transaction
            .get(adRefFirestore); // Get the latest data from Firestore

        if (adSnapshot
                .exists && // Check if the snapshot exists and contains data
            adSnapshot.data() != null &&
            (adSnapshot.data() as Map<String, dynamic>)['isUpdatingPrice'] ==
                true) {
          throw 'Another user is currently updating the price. Please try again later.';
        }

        await transaction.update(adRefFirestore, {
          // Update the 'isUpdatingPrice' field to prevent concurrent updates in Firestore
          'isUpdatingPrice': true
        });

        await transaction.update(
            adRefFirestore, // Perform the price update in Firestore
            {'price': price});

        await transaction.update(adRefFirestore, {
          'isUpdatingPrice':
              false // Set 'isUpdatingPrice' back to false to allow other updates in Firestore
        });
      });

      await adRefRealtime.update(// Update the price in the Realtime Database
          {'price': price});

      DocumentSnapshot adSnapshotAfter = await adRefFirestore
          .get(); // Get the latest data after the transaction from Firestore
      int priceAfter = adSnapshotAfter.exists
          ? (adSnapshotAfter.data() != null
              ? (adSnapshotAfter.data()! as Map<String, dynamic>)['price'] ?? 0
              : 0)
          : 0;
      print('Price after transaction (Firestore): $priceAfter');

      DataSnapshot
          adSnapshotAfterRealtime = // Get the latest data after the transaction from the Realtime Database
          await adRefRealtime.once().then((snapshot) => snapshot.snapshot);
      if (adSnapshotAfterRealtime.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic>? data = adSnapshotAfterRealtime.value as Map<
            dynamic, dynamic>?; // Cast the value to a map with dynamic keys

        if (data != null && data.containsKey('price') && data['price'] is int) {
          priceAfterRealtime = data['price'] as int;
        }
      }
      print('Price after transaction (Realtime Database): $priceAfterRealtime');
    } catch (error) {
      print(
          'Error updating car price: $error'); // Handle error, notify the user, etc.
    }
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

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.isNegative) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Product products = arguments['product'] as Product;
    DateTime currentTime = DateTime.now();
    _remainingTime = DateTime.fromMillisecondsSinceEpoch(products.timestamp2)
        .difference(currentTime);
    int totalSeconds = _remainingTime.inSeconds;
    int days = totalSeconds ~/ (3600 * 24);
    int hours = (totalSeconds % (3600 * 24)) ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    // Format the remaining time as DD:HH:MM:SS
    String formattedTime = '${days.toString().padLeft(2, '0')}:'
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
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
                icon: const Icon(Icons.arrow_back)),
            Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Center(
                child: Text(
                  '${products.brand} ${products.model}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  () {};
                },
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                ))
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  //For images
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: products.uploadedImageUrls.isEmpty
                            ? Center(
                                child: Container(
                                  child: GestureDetector(
                                    onTap: () {}, //_getImages,
                                    child: Image.asset(
                                      'lib/images/download.png',
                                      width: 250,
                                      height: 250,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: products.uploadedImageUrls.length +
                                    1, // Add 1 for the extra item
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    // Display the extra item at index 0
                                    return GestureDetector(
                                      onTap: () {
                                        openFullSizeImage(
                                          products
                                              .title, // Adjust index for the list
                                          context,
                                        );
                                      },
                                      onLongPress: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 250,
                                          height: 200,
                                          child: Image.network(
                                            products.title,
                                            width: 300,
                                            fit: BoxFit.fill,
                                            frameBuilder: (BuildContext context,
                                                Widget child,
                                                int? frame,
                                                bool wasSynchronouslyLoaded) {
                                              if (frame != null) {
                                                return child; // Return the image if frame is not null (indicating loaded)
                                              } else {
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                      color: Colors.white),
                                                ); // Show shimmer effect while the image is loading
                                              }
                                            },
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child; // Return the image if loading is complete
                                              } else {
                                                return child; // Return the image with loading progress if it's still loading
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Display other items from the list
                                    return GestureDetector(
                                      onTap: () {
                                        print(products.uploadedImageUrls[index -
                                            1]); // Adjust index for the list
                                        openFullSizeImage(
                                          products.uploadedImageUrls[index -
                                              1], // Adjust index for the list
                                          context,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          products.uploadedImageUrls[index -
                                              1], // Adjust index for the list
                                          width: 250,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    '${price}',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      'Product Description',
                      style: TextStyle(fontSize: 24),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          products.description,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    title: const Text(
                      'Product Specifications',
                      style: TextStyle(fontSize: 24),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Brand'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Column 2'),
                                  ),
                                ),
                              ],
                            ),
                            const TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Year'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Column 2'),
                                  ),
                                ),
                              ],
                            ),
                            const TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Model'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Column 2'),
                                  ),
                                ),
                              ],
                            ),
                            const TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Fuel'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Column 2'),
                                  ),
                                ),
                              ],
                            ),
                            const TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('KMs Driven'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Column 2'),
                                  ),
                                ),
                              ],
                            ),
                            const TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Transmission'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Column 2'),
                                  ),
                                ),
                              ],
                            ),
                            const TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('City'),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Column 2'),
                                  ),
                                ),
                              ],
                            ),
                            // Copy tablerow for more rows
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18),
                  child: Text(
                    "Related Products",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Container(
                    height: 390,
                    child: StreamBuilder<List<QuerySnapshot>>(
                      stream: mergeStreams(),
                      builder: (context, snapshot) {
                        // Merge all snapshots into a single list
                        List<DocumentSnapshot> allSnapshots = [];
                        for (var snapList in snapshot.data!) {
                          allSnapshots.addAll(snapList.docs);
                        }
                        // Filter documents based on search query
                        final filteredDocs = allSnapshots.where((doc) {
                          final vehicleName =
                              doc['brand'].toString().toLowerCase();
                          final price = doc['price']
                              as int; // Assuming price is stored as an integer
                          final year = doc['year']
                              as int; // Assuming year is stored as an integer
                          //final kmsDriven = doc['kmsDriven']as int; // Assuming kmsDriven is stored as an integer
                          final time = doc['timestamp2'];
                          return vehicleName.contains("");
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return Center(
                            child: Container(
                              width: 300,
                              child: Text(
                                  'No results found. Try changing or resetting the filter settings'),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: filteredDocs.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot document =
                                filteredDocs[index];
                            final List<dynamic>
                                picsDynamic = //this shit is very imp
                                document['pics'] ?? [];
                            final List<String> uploadedImageUrls2 = picsDynamic
                                .map((pic) => pic.toString())
                                .toList();
                            Product product = Product(
                              brand: document['brand'],
                              model: document['model'],
                              year: document['year'],
                              title: document['title'],
                              id: document['id'],
                              price: document['price'],
                              description: 'change',
                              collectionValue: document['collectionValue'],
                              timestamp: document['timestamp'],
                              timestamp2: document['timestamp2'],
                              uploadedImageUrls: uploadedImageUrls2,
                            );
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/itemScreen',
                                    arguments: {
                                      'product': product,
                                      'id': product.id
                                    });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                            width: 320,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.network(
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
                                                      return Shimmer.fromColors(
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
                                                  loadingBuilder:
                                                      (BuildContext context,
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
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8),
                                        child: Text(
                                          product.model,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8),
                                        child: Text(
                                          '${product.price}',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ))
              ], //ALL product items here
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 24),
                ),
                Container(
                  width: 150,
                  child: FABcustom(
                    onTap: () {
                      bool isUserLoggedin = (auth != null);
                      if (isUserLoggedin) {
                        updateCarPrice(
                            products.id, 12, products.collectionValue);
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      }
                    },
                    text: "Bid",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
