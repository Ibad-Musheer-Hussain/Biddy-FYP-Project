// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, deprecated_member_use

import 'package:biddy/PickImagesForAd.dart';
import 'package:biddy/components/FABcustom.dart';
import 'package:biddy/components/LoginTextField.dart';
import 'package:biddy/components/NumberField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ContinueAd extends StatefulWidget {
  const ContinueAd({Key? key, required this.uploadImagesFuture})
      : super(key: key);
  final Future<AdData> uploadImagesFuture;

  @override
  State<ContinueAd> createState() => _ContinueAdState();
}

class _ContinueAdState extends State<ContinueAd> {
  final TextEditingController brand = TextEditingController();
  final TextEditingController Year = TextEditingController();
  final TextEditingController model = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController kms = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController transmission = TextEditingController();
  final TextEditingController fuel = TextEditingController();
  int selectedDays = 3;
  String titleURL = '';
  List<String> pictureUrls = [];
  String dropdownValue = '3 Days';
  int days = 3;
  String dropdownValue2 = 'SUVs';
  String CollectionValue = 'SUVs';
  bool isFutureComplete = false;
  Timestamp timestamp = Timestamp(0, 0);

  final User? auth = FirebaseAuth.instance.currentUser;
  final CollectionReference adsCollection =
      FirebaseFirestore.instance.collection('Ads');

  bool validateform() {
    final regex = RegExp(r'^[19][6-9]\d|20[0-2][0-4]$');
    if (!regex.hasMatch(Year.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Year must be from 1960-2024',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        duration: Duration(seconds: 2), // SnackBar duration
      ));
      return false;
    }

    return true;
  }

  Future<void> processImageData(Future<AdData> uploadImagesFuture) async {
    // Await the result of the future
    try {
      AdData adData = await uploadImagesFuture;
      setState(() {
        isFutureComplete = true;
      });
      titleURL = adData.titleURL;
      pictureUrls = adData.pictureUrls;
      print('Title URL: ${adData.titleURL}');
      print('Picture URLs: ${adData.pictureUrls}');
    } catch (error) {
      print('Error: $error');
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
    print(timestamp.toDate());
    print('Timestamp stored successfully!');
    return timestampMillis;
  }

  Future<void> uploadCarAd() async {
    try {
      String documentId =
          adsCollection.doc().id; // Generate a custom document ID
      int timestampMillis = storeTimestamp(); // Get timestamp in milliseconds
      int timestamp2 = timestampMillis + (selectedDays * 24 * 60 * 60 * 1000);

      Map<String, dynamic> data = {
        // Create a map containing the data to be added to Firestore and the Realtime Database
        'title': titleURL,
        'brand': brand.text.toString(),
        'model': model.text.toString(),
        'year': int.tryParse(Year.text.toString()),
        'price': int.tryParse(price.text.toString()),
        'kms': int.tryParse(kms.text.toString()),
        'transmission': transmission.text.toString(),
        'pics': pictureUrls,
        'city': city.text.toString(),
        'id': documentId,
        'fuel': fuel.text.toString(),
        'description': description.text.toString(),
        'collectionValue': CollectionValue,
        'timestamp': timestampMillis, // Use Timestamp object
        'timestamp2': timestamp2
      };

      await adsCollection // Add data to Firestore
          .doc('Cars')
          .collection(CollectionValue)
          .doc(documentId) // Use the custom document ID
          .set(data);

      // Add data to the Realtime Database
      await FirebaseDatabase.instance
          .reference()
          .child('adsCollection')
          .child('Cars')
          .child(CollectionValue)
          .child(documentId)
          .set({
        ...data,
        'timestamp': timestampMillis, // Store timestamp as Timestamp object
      });

      print('Car ad added to Firestore and Realtime Database');
    } catch (error) {
      print('Failed to add car ad: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFutureComplete == false) {
      processImageData(widget.uploadImagesFuture);
    }

    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 255, 149, 163),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(builder: (context) {
              return IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              );
            }),
            Text(
              "Create Ad",
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_forward),
                color: Colors.white)
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 250, 250),
              Color.fromARGB(255, 255, 149, 163)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          scrollDirection: Axis.vertical,
          physics: const ScrollPhysics(),
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              ),
                            ],
                            borderRadius:
                                BorderRadius.circular(12), //original 36
                            color: Color.fromARGB(255, 255, 218, 223),
                          ),
                          child: Column(children: <Widget>[
                            LoginTextField(
                              textEditingController: brand,
                              hintText: "Brand",
                              obscureText: false,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                controller: description,
                                minLines: 1,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  labelText: "Product Description",
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    //fontWeight: FontWeight.bold,
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.pink,
                                      width: 3.0,
                                    ),
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.pink,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            LoginTextField(
                              textEditingController: model,
                              hintText: "Model",
                              obscureText: false,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 16, top: 8),
                              child: Row(
                                children: [
                                  Text(
                                    "Car Type",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  DropdownButton<String>(
                                    value: dropdownValue2,
                                    dropdownColor:
                                        Color.fromARGB(255, 255, 218, 223),
                                    borderRadius: BorderRadius.circular(12),
                                    padding: EdgeInsets.all(8),
                                    onChanged: (String? newValue2) {
                                      setState(() {
                                        dropdownValue2 = newValue2!;
                                        CollectionValue = newValue2;
                                      });
                                    },
                                    items: <String>[
                                      'Sedan',
                                      'SUVs',
                                      'Hatchbacks',
                                      'Motorbikes',
                                      'Hybrid',
                                      'Coupes',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value2) {
                                      return DropdownMenuItem<String>(
                                        value: value2,
                                        child: Text(value2),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 2,
                              color: Colors.pink,
                              indent: 16,
                              endIndent: 16,
                            ),
                            NumberField(
                              textEditingController: Year,
                              hintText: "Year",
                              obscureText: false,
                            ),
                            NumberField(
                              textEditingController: kms,
                              hintText: "KMs Driven",
                              obscureText: false,
                            ),
                            LoginTextField(
                              textEditingController: transmission,
                              hintText: "Transmission",
                              obscureText: false,
                            ),
                            LoginTextField(
                              textEditingController: fuel,
                              hintText: "Fuel",
                              obscureText: false,
                            ),
                            NumberField(
                              textEditingController: price,
                              hintText: "Starting Price",
                              obscureText: false,
                            ),
                            LoginTextField(
                              textEditingController: city,
                              hintText: "City",
                              obscureText: false,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 16, top: 8),
                              child: Row(
                                children: [
                                  Text(
                                    "Auction Time",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  DropdownButton<String>(
                                    value: dropdownValue,
                                    dropdownColor:
                                        Color.fromARGB(255, 255, 218, 223),
                                    borderRadius: BorderRadius.circular(12),
                                    padding: EdgeInsets.all(8),
                                    onChanged: (String? newValue2) {
                                      setState(() {
                                        dropdownValue = newValue2!;
                                        dropdownValue = newValue2;
                                        print(dropdownValue);

                                        switch (dropdownValue) {
                                          case '3 Days':
                                            selectedDays = 3;
                                            break;
                                          case '7 Days':
                                            selectedDays = 7;
                                            break;
                                          case '14 Days':
                                            selectedDays = 14;
                                            break;
                                          default:
                                            selectedDays =
                                                0; // Default value if none of the cases match
                                        }
                                        print(selectedDays);
                                      });
                                    },
                                    items: <String>[
                                      '3 Days',
                                      '7 Days',
                                      '14 Days',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 2,
                              color: Colors.pink,
                              indent: 16,
                              endIndent: 16,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                            padding: EdgeInsets.all(16.0),
                            child: isFutureComplete
                                ? FABcustom(
                                    onTap: () async {
                                      if (validateform()) {
                                        await uploadCarAd();
                                        Navigator.pushNamed(
                                            context, '/MainPage');
                                      }
                                    },
                                    text: "Publish Ad",
                                  )
                                : GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.pink,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 16, 8, 16),
                                        child: Center(
                                          child: Text(
                                            "Wait for Upload",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
