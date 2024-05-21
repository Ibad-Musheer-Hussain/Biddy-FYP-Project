import 'package:biddy/List/Product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

class FavouritesPage extends StatefulWidget {
  FavouritesPage();

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<dynamic> favourites = [];
  final String userID = "YPTNxEUcRbW4frgs5OkIcbEUjO73";

  @override
  void initState() {
    super.initState();
    fetchFavourites();
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

  Future<void> fetchFavourites() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourites'),
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: mergeStreams(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> allSnapshots = [];
          for (var snapList in snapshot.data!) {
            allSnapshots.addAll(snapList.docs);
          }
          // Filter documents based on favourites and search query
          final filteredDocs = allSnapshots.where((doc) {
            final docId = doc['id'];
            // Filter by favourites
            final isFavourite = favourites.contains(docId);
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
              final DocumentSnapshot document = filteredDocs[index];
              final List<dynamic> picsDynamic = document['pics'] ?? [];
              final List<String> uploadedImageUrls2 =
                  picsDynamic.map((pic) => pic.toString()).toList();
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
                  Navigator.pushNamed(context, '/itemScreen', arguments: {
                    'product': product,
                    'id': product.id,
                  });
                },
                child: Card.filled(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                frameBuilder: (BuildContext context,
                                    Widget child,
                                    int? frame,
                                    bool wasSynchronouslyLoaded) {
                                  if (frame != null) {
                                    return child; // Return the image if frame is not null (indicating loaded)
                                  } else {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(color: Colors.white),
                                    ); // Show shimmer effect while the image is loading
                                  }
                                },
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
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
              );
            },
          );
        },
      ),
    );
  }
}
