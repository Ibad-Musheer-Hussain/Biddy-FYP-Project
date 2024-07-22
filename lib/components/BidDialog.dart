import 'package:biddy/List/Product.dart';
import 'package:biddy/functions/showCustomSnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future<void> addToHistory(String productId, String? userId) async {
  try {
    // Get the reference to the user document
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    // Get the current history list
    DocumentSnapshot userSnapshot = await userRef.get();

    // Check if the 'history' field exists in the document
    if (userSnapshot.exists &&
        (userSnapshot.data() as Map<String, dynamic>).containsKey('history') &&
        (userSnapshot.data() as Map<String, dynamic>)['history']
            is List<dynamic> &&
        (userSnapshot.data() as Map<String, dynamic>)['history'].isNotEmpty) {
      List<String> history = List<String>.from((userSnapshot.data() as Map<
          String, dynamic>)['history']); // Get the existing favorites list

      // Add the new product ID to the favorites list
      history.add(productId);

      // Update the user document with the updated favorites list
      await userRef.update({'history': history});

      print('Product added to history successfully');
    } else {
      // If the 'history' field does not exist or is empty, create it with the new product ID
      await userRef.set({
        'history': [productId]
      }, SetOptions(merge: true));

      print('Created history list and added product successfully');
    }
  } catch (error) {
    print('Failed to add product to history: $error');
  }
}

void BidDialog(
    BuildContext context, Product products, int price, User auth) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      List<int> numbers = List.generate(8, (index) => 0);
      numbers = convertToDigitList(price);
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Select Bid Amount'),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(8, (index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_upward),
                          onPressed: () {
                            setState(() {
                              numbers[index]++;
                              if (numbers[index] > 9) {
                                numbers[index] = 0;
                              }
                            });
                          },
                        ),
                        Text(numbers[index].toString()),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: () {
                            setState(() {
                              if (numbers[index] == 0) {
                                numbers[index] = 9;
                              } else {
                                numbers[index]--;
                              }
                            });
                          },
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Place Bid'),
                onPressed: () {
                  int combinedNumber = int.parse(numbers.join());
                  if (combinedNumber >= price + 10000) {
                    updateCarPrice(products.id, products.price,
                        products.collectionValue, auth, combinedNumber);
                    showCustomSnackBar(context,
                        "Your bid is being processed. It may take a while!");
                    addToHistory(products.id, auth.uid);
                    Navigator.of(context).pop();
                  } else {
                    showCustomSnackBar(
                        context, "The bid needs to be greater than 10000");
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

List<int> convertToDigitList(int number) {
  String numberString = number.toString();

  while (numberString.length < 8) {
    numberString = '0$numberString';
  }

  List<int> digitList = [];
  for (int i = 0; i < numberString.length; i++) {
    digitList.add(int.parse(numberString[i]));
  }
  print("digit list");
  print(digitList);
  return digitList;
}

Future<void> updateCarPrice(String adId, int price, String collectionAddress,
    User user, int combinedNumber) async {
  try {
    DocumentReference adRefFirestore = FirebaseFirestore.instance
        .collection('Ads')
        .doc('Cars')
        .collection(collectionAddress)
        .doc(adId);

    DatabaseReference adRefRealtime = FirebaseDatabase.instance
        .reference()
        .child('adsCollection')
        .child('Cars')
        .child(collectionAddress)
        .child(adId);

    DocumentSnapshot adSnapshotBefore = await adRefFirestore.get();
    int priceBefore = adSnapshotBefore.exists
        ? (adSnapshotBefore.data() != null
            ? (adSnapshotBefore.data()! as Map<String, dynamic>)['price'] ?? 0
            : 0)
        : 0;
    print('Price before transaction (Firestore): $priceBefore');

    DataSnapshot adSnapshotBeforeRealtime =
        await adRefRealtime.once().then((snapshot) => snapshot.snapshot);

    int priceBeforeRealtime = 0;
    if (adSnapshotBeforeRealtime.value is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic>? data =
          adSnapshotBeforeRealtime.value as Map<dynamic, dynamic>?;
      if (data != null && data.containsKey('price') && data['price'] is int) {
        priceBeforeRealtime = data['price'] as int;
      }
    }
    print('Price before transaction (Realtime Database): $priceBeforeRealtime');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot adSnapshot = await transaction.get(adRefFirestore);
      if (adSnapshot.exists &&
          adSnapshot.data() != null &&
          (adSnapshot.data() as Map<String, dynamic>)['isUpdatingPrice'] ==
              true) {
        throw 'Another user is currently updating the price. Please try again later.';
      }

      await transaction.update(adRefFirestore, {
        'isUpdatingPrice': true,
      });
      price = combinedNumber;
      await transaction.update(adRefFirestore, {
        'price': price,
        'winningid': user.uid, // Assuming `user.uid` is the user's unique ID
      });

      await transaction.update(adRefFirestore, {
        'isUpdatingPrice': false,
      });
    });

    await adRefRealtime.update({
      'price': price,
      'winningid': user.uid, // Assuming `user.uid` is the user's unique ID
    });

    DocumentSnapshot adSnapshotAfter = await adRefFirestore.get();
    int priceAfter = adSnapshotAfter.exists
        ? (adSnapshotAfter.data() != null
            ? (adSnapshotAfter.data()! as Map<String, dynamic>)['price'] ?? 0
            : 0)
        : 0;
    print('Price after transaction (Firestore): $priceAfter');

    DataSnapshot adSnapshotAfterRealtime =
        await adRefRealtime.once().then((snapshot) => snapshot.snapshot);
    int priceAfterRealtime = 0;
    if (adSnapshotAfterRealtime.value is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic>? data =
          adSnapshotAfterRealtime.value as Map<dynamic, dynamic>?;
      if (data != null && data.containsKey('price') && data['price'] is int) {
        priceAfterRealtime = data['price'] as int;
      }
    }

    print('Price after transaction (Realtime Database): $priceAfterRealtime');
  } catch (error) {
    print('Error updating car price: $error');
  }
}
