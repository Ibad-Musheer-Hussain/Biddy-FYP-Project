import 'package:biddy/List/Product.dart';
import 'package:biddy/functions/showCustomSnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
                child: Text('Approve'),
                onPressed: () {
                  int combinedNumber = int.parse(numbers.join());
                  if (combinedNumber > price) {
                    updateCarPrice(products.id, products.price,
                        products.collectionValue, auth, combinedNumber);
                    showCustomSnackBar(context, "Your bid is being processed");
                    Navigator.of(context).pop();
                  } else {
                    showCustomSnackBar(
                        context, "The amount needs to be greater");
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
