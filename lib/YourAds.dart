import 'package:biddy/List/Product.dart';
import 'package:biddy/functions/mergeStreams.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Yourads extends StatefulWidget {
  const Yourads({super.key});

  @override
  State<Yourads> createState() => _YouradsState();
}

class _YouradsState extends State<Yourads> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<dynamic> Ads = [];
  bool isLoading = true;

  void initState() {
    super.initState();
    fetchFavourites();
  }

  Future<void> fetchFavourites() async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      print(user?.uid);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          Ads = userDoc.get('Userads') ?? [];
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching favourites: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Center(
                child: Text(
                  'Your Ads',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.transparent,
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 228, 129, 142),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: RefreshIndicator(
                onRefresh: () => fetchFavourites(),
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
                    // Filter documents based on favourites and search query
                    final filteredDocs = allSnapshots.where((doc) {
                      final docId = doc['id'];
                      // Filter by favourites
                      final isFavourite = Ads.contains(docId);
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
                        final List<dynamic> picsDynamic =
                            document['pics'] ?? [];
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
                            Navigator.pushNamed(context, '/itemScreen',
                                arguments: {
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
                                    width: 400,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Adjust the radius as needed
                                          child: Image.network(
                                            product.title,
                                            width: 300,
                                            height: 270,
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
              ),
            ),
    );
  }
}
