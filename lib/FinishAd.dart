// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_null_comparison
import 'package:biddy/CreateAd.dart';
import 'package:biddy/components/FABcustom.dart';
import 'package:biddy/functions/showCustomSnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class Continueadcombine extends StatefulWidget {
  const Continueadcombine({Key? key, required this.uploadImagesFuture})
      : super(key: key);
  final Future<AdData> uploadImagesFuture;
  @override
  State<Continueadcombine> createState() => _ContinueadcombineState();
}

class _ContinueadcombineState extends State<Continueadcombine> {
  final formKey = GlobalKey<FormBuilderState>();
  final description = TextEditingController();
  int _countHondaPristineSoldGreaterThanPoint1 = 0;
  int _countHondaPristineSoldEqualToZero = 0;
  int pricehigher = 0;
  int pricelower = 0;
  int selectedDays = 0;
  List<String> insights = [];
  List<String> positiveInsights = [];
  List<String> negativeInsights = [];
  List<String> neutralInsights = [];
  String titleURL = '';
  List<String> pictureUrls = [];
  String dropdownValue = '2 Min';
  String CollectionValue = 'Sedan';
  String ConditionValue2 = 'Pristine';
  String TransmissionValue = 'Automatic';
  String condition = "Pristine";
  String transmission = "Automatic";
  String fuel = "Petrol";
  String collection = "Sedan";
  bool isFutureComplete = false;
  Timestamp timestamp = Timestamp(0, 0);
  final User? auth = FirebaseAuth.instance.currentUser;
  final CollectionReference adsCollection =
      FirebaseFirestore.instance.collection('Ads');
  double probabilitySold = 0.0;
  String _csvContent = '';
  int timestamp2 = 0;

  Future<void> _downloadCsv() async {
    try {
      // Get a reference to the CSV file
      final ref = FirebaseStorage.instance
          .ref()
          .child('cars_with_sold_probabilities2.csv');

      // Get the download URL
      final url = await ref.getDownloadURL();

      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _csvContent = response.body;
        });
      } else {
        throw Exception('Failed to load CSV file');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _parseCsv(String csvContent) {
    final csvData = const CsvToListConverter().convert(csvContent, eol: '\n');

    int countSoldGreaterThanPoint1 = 0;
    int countSoldEqualToZero = 0;

    csvData.skip(1).forEach((row) {
      final _brand = row[0].toString().trim().toLowerCase();
      final _condition = row[1].toString().trim().toLowerCase();
      final _model = row[4].toString().trim().toLowerCase();
      final price = double.parse(row[5].toString().trim().toLowerCase());
      pricelower =
          int.tryParse(formKey.currentState?.fields['Starting Price']?.value)! -
              250000;
      pricehigher =
          int.tryParse(formKey.currentState?.fields['Starting Price']?.value)! +
              250000;
      final soldProbability =
          double.parse(row[8].toString().trim().toLowerCase());

      if (_brand ==
              (formKey.currentState?.fields['Brand']?.value)
                  .toString()
                  .toLowerCase() &&
          _condition == condition.toLowerCase() &&
          price > pricelower &&
          price < pricehigher &&
          _model ==
              (formKey.currentState?.fields['Model']?.value)
                  .toString()
                  .toLowerCase()) {
        if (soldProbability > 0.1) {
          countSoldGreaterThanPoint1++;
        } else if (soldProbability == 0) {
          countSoldEqualToZero++;
        }
      }
    });

    setState(() {
      _countHondaPristineSoldGreaterThanPoint1 = countSoldGreaterThanPoint1;
      _countHondaPristineSoldEqualToZero = countSoldEqualToZero;
    });

    if (countSoldGreaterThanPoint1 == 0 && countSoldEqualToZero == 0) {
      _showAlertDialog(context, "Biddy Insights",
          "This model is not present at this price range in our data set");
    } else {
      _showAlertDialog(
        context,
        "Data Insights",
        "${formKey.currentState?.fields['Brand']?.value} ${formKey.currentState?.fields['Model']?.value} ${condition} condition from price range $pricelower - $pricehigher\nSold: $_countHondaPristineSoldGreaterThanPoint1\nUnsold: $_countHondaPristineSoldEqualToZero",
      );
    }
  }

  void _showAlertDialog(BuildContext context, String title, String content) {
    final Color positiveColor = Colors.green[100]!;
    final Color negativeColor = Colors.red[100]!;
    final Color neutralColor = Colors.grey[100]!;

    final Icon positiveIcon =
        Icon(Icons.thumb_up, color: Colors.green, size: 20);
    final Icon negativeIcon =
        Icon(Icons.thumb_down, color: Colors.red, size: 20);
    final Icon neutralIcon = Icon(Icons.info, color: Colors.grey, size: 20);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.info,
                color: Colors.blue,
                size: 40,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(content, style: TextStyle(fontSize: 14)),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Insights',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...positiveInsights.map((insight) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: positiveColor,
                                child: positiveIcon,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(insight,
                                      style: TextStyle(
                                          fontSize: 14.0, color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                    ...negativeInsights.map((insight) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: negativeColor,
                                child: negativeIcon,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(insight,
                                      style: TextStyle(
                                          fontSize: 14.0, color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
                    ...neutralInsights.map((insight) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: neutralColor,
                                child: neutralIcon,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(insight,
                                      style: TextStyle(
                                          fontSize: 14.0, color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8), // Gap after each neutral insight
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void createinsights() {
    positiveInsights.clear();
    negativeInsights.clear();
    neutralInsights.clear();

    var yearValue = formKey.currentState?.fields['Year']?.value;
    var kmsDrivenValue = formKey.currentState?.fields['KMs Driven']?.value;
    int kmsDriven = int.parse(kmsDrivenValue);
    var startingPriceValue =
        formKey.currentState?.fields['Starting Price']?.value;
    int startingPrice = int.parse(startingPriceValue);
    if (startingPrice < 400000 && collection != "Motorbikes") {
      negativeInsights.add(
          "Your starting price is quite low. Ensure it reflects the value of the item.");
      probabilitySold = probabilitySold * 0.98;
    } else if (startingPrice >= 15000000) {
      negativeInsights.add(
          "Your starting price is quite high. Higher initial prices may scare buyers.");
      probabilitySold = probabilitySold * 0.98;
    }

    if (condition == "Fair" || condition == "Poor") {
      neutralInsights.add(
          "Vehicles with a fair or poor condition may have harder time being sold.");
      probabilitySold = probabilitySold * 0.8;
    } else {
      positiveInsights.add(
          "Vehicles with a Pristine or Good condition may have an easier time being sold.");
    }

    if (description.text.length < 40) {
      negativeInsights.add(
          "Empty descriptions can lose user trust. Provide a detailed description.");
      probabilitySold = probabilitySold * 0.95;
    } else if (description.text.length > 100) {
      neutralInsights.add(
          "Consider summarizing your description for clarity. Long descriptions can be overwhelming.");
      probabilitySold = probabilitySold * 0.97;
    }

    if (kmsDriven > 150000) {
      negativeInsights
          .add("More driven vehicles have a harder time being sold.");
    }

    if (titleURL.isEmpty) {
      negativeInsights.add(
          "An empty title image may result in lower customer interactions.");
      probabilitySold = probabilitySold * 0.9;
    }

    if (int.parse(yearValue) < 2010) {
      negativeInsights.add("Older vehicles have a lower chance of selling.");
      probabilitySold = probabilitySold * 0.9;
    }

    if (pictureUrls.length <= 2) {
      negativeInsights.add("Add more pictures to enhance your listing.");
    }

    if (pictureUrls.length > 2 && pictureUrls.length < 5) {
      neutralInsights.add("Add more pictures to enhance your listing.");
    }

    if (probabilitySold >= 0.65) {
      positiveInsights.add(
          "Your ad listing is in excellent shape and may require small adjustments.");
    } else if (probabilitySold >= 0.40 && probabilitySold < 0.65) {
      positiveInsights
          .add("Your ad listing is fair but still could use some adjustments.");
    } else if (probabilitySold <= 0.20) {
      negativeInsights
          .add("Your ad listing needs some adjustments to interest buyers.");
      negativeInsights
          .add("Check if you have entered the correct information.");
    }

    insights.addAll(positiveInsights);
    insights.addAll(negativeInsights);
    insights.addAll(neutralInsights);
  }

  Future<void> downloadModelAndPredict() async {
        createinsights();
    }
  

  List<double> createInput() {
    String Brand =
        (formKey.currentState?.fields['Brand']?.value).toString().toLowerCase();
    String Model =
        (formKey.currentState?.fields['Model']?.value).toString().toLowerCase();
    bool Brand_Honda;
    bool Brand_Suzuki;
    bool Brand_Toyota;
    bool Model_City;
    bool Model_Civic;
    bool Model_Corolla;
    bool Model_Mehran;

    switch (Brand) {
      case "honda":
        Brand_Honda = true;
        Brand_Suzuki = false;
        Brand_Toyota = false;
        break;
      case "suzuki":
        Brand_Honda = false;
        Brand_Suzuki = true;
        Brand_Toyota = false;
        break;
      case "toyota":
        Brand_Honda = false;
        Brand_Suzuki = false;
        Brand_Toyota = true;
        break;
      default:
        Brand_Honda = false;
        Brand_Suzuki = false;
        Brand_Toyota = false;
        print("default activated");
    }

    switch (Model) {
      case "city":
        Model_City = true;
        Model_Mehran = false;
        Model_Corolla = false;
        Model_Civic = false;
        break;
      case "civic":
        Model_City = false;
        Model_Mehran = false;
        Model_Corolla = false;
        Model_Civic = true;
        break;
      case "corolla":
        Model_City = false;
        Model_Mehran = false;
        Model_Corolla = true;
        Model_Civic = false;
        break;
      case "mehran":
        Model_City = false;
        Model_Mehran = true;
        Model_Corolla = false;
        Model_Civic = false;
        break;
      default:
        Model_City = false;
        Model_Mehran = false;
        Model_Corolla = false;
        Model_Civic = false;
        print("default activated");
    }

    late Map<String, Object> data;
    try {
      data = {
        'KMs Driven':
            double.parse(formKey.currentState?.fields['KMs Driven']?.value),
        'Price':
            double.parse(formKey.currentState?.fields['Starting Price']?.value),
        'Year': double.parse(formKey.currentState?.fields['Year']?.value),
        'Brand_Honda': Brand_Honda,
        'Brand_Suzuki': Brand_Suzuki,
        'Brand_Toyota': Brand_Toyota,
        'Condition_Fair': false,
        'Condition_Good': false,
        'Condition_Poor': true,
        'Condition_Pristine': false,
        'Fuel_CNG': false,
        'Fuel_Petrol': true,
        'Model_City': Model_City,
        'Model_Civic': Model_Civic,
        'Model_Corolla': Model_Corolla,
        'Model_Mehran': Model_Mehran,
        'Registered City_Islamabad': false,
        'Registered City_Karachi': false,
        'Registered City_Lahore': true,
      };
      print(data);
    } catch (e) {
      showCustomSnackBar(context, "Invalid or Empty Data");
      return [0.0];
    }

    return data.values.map((value) {
      if (value is bool) {
        return value ? 1.0 : 0.0;
      } else if (value is num) {
        return value.toDouble();
      } else {
        throw ArgumentError('Unsupported data type: ${value.runtimeType}');
      }
    }).toList();
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

  Future<void> PredictandParse(
    String csvContent,
  ) async {
    _parseCsv(csvContent);
    downloadModelAndPredict();
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

  void updatebalance(User user, BuildContext context) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    var data = doc.data() as Map<String, dynamic>;
    int balance = data['balance'];
    print(balance);

    if (balance > 10000) {
      balance = balance - 10000;
    } else {
      showCustomSnackBar(context, "Insufficient Balance");
      Navigator.pushNamed(context, '/MainPage');
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'balance': balance});
  }

  Future<void> uploadCarAd() async {
    try {
      String documentId =
          adsCollection.doc().id; // Generate a custom document ID
      int timestampMillis = storeTimestamp(); // Get timestamp in milliseconds
      print("$selectedDays selected Days\n");
      if (selectedDays == 0) {
        timestamp2 = (timestampMillis + 120000);
        print("$selectedDays selected Days\n");
        print("$selectedDays selected Days\n");
        print("$selectedDays selected Days\n");
      } else {
        timestamp2 = timestampMillis + (selectedDays * 24 * 60 * 60 * 1000);
      }

      Map<String, dynamic> data = {
        // Create a map containing the data to be added to Firestore and the Realtime Database
        'title': titleURL,
        'brand': formKey.currentState?.fields['Brand']?.value,
        'model': formKey.currentState?.fields['Model']?.value,
        'year': int.tryParse(formKey.currentState?.fields['Year']?.value),
        'price':
            int.tryParse(formKey.currentState?.fields['Starting Price']?.value),
        'kms': int.tryParse(formKey.currentState?.fields['KMs Driven']?.value),
        'transmission': transmission,
        'pics': pictureUrls,
        'city': formKey.currentState?.fields['City']?.value,
        'id': documentId,
        'winningid': '',
        'creatorID': auth?.uid,
        'fuel': fuel,
        'description': description.text.toString(),
        'collectionValue': collection,
        'timestamp': timestampMillis, // Use Timestamp object
        'timestamp2': timestamp2
      };

      await adsCollection // Add data to Firestore
          .doc('Cars')
          .collection(collection)
          .doc(documentId) // Use the custom document ID
          .set(data);

      await FirebaseDatabase.instance
          .reference()
          .child('adsCollection')
          .child('Cars')
          .child(collection)
          .child(documentId)
          .set({
        ...data,
        'timestamp': timestampMillis, // Store timestamp as Timestamp object
      });

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(auth?.uid);

      // Get the current favorites list
      DocumentSnapshot userSnapshot = await userRef.get();

      List<String> history = List<String>.from(
          (userSnapshot.data() as Map<String, dynamic>)['history']);

      List<String> Userads = List<String>.from(
          (userSnapshot.data() as Map<String, dynamic>)['Userads']);

      history.add(documentId);
      Userads.add(documentId);
      await userRef.update({
        'Userads': Userads,
      });

      print('Car ad added to Firestore and Realtime Database');
    } catch (error) {
      print('Failed to add car ad: $error');
    }
    updatebalance(auth!, context);
  }

  @override
  void initState() {
    super.initState();
    _downloadCsv();
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
        scrolledUnderElevation:
            0.0, //for disabling changing of color when scrolling app
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
              "Create Your Ad",
              style: TextStyle(color: Colors.white),
            ),
            Text(""),
            Text("")
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
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Center(
                    child: FormBuilder(
                      key: formKey,
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
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderTextField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  name: 'Brand',
                                  decoration: const InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                        width: 3.0,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                        width: 2.0,
                                      ),
                                    ),
                                    labelText: 'Brand',
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText: "Brand cannot be empty"),
                                  ]),
                                ),
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
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderTextField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  name: 'Model',
                                  decoration: const InputDecoration(
                                      labelText: 'Model',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 3.0,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      )),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText: "Model cannot be empty"),
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderDropdown<String>(
                                  name: "Car Type",
                                  decoration: const InputDecoration(
                                      labelText: 'Car Type',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 3.0,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      )),
                                  dropdownColor:
                                      Color.fromARGB(255, 255, 218, 223),
                                  initialValue: "Sedan",
                                  borderRadius: BorderRadius.circular(12),
                                  items: [
                                    'Sedan',
                                    'SUVs',
                                    'Hatchbacks',
                                    'Motorbikes',
                                    'Hybrid',
                                    'Coupes'
                                  ]
                                      .map(
                                          (Collectionvalue) => DropdownMenuItem(
                                                value: Collectionvalue,
                                                child: Text(Collectionvalue),
                                                onTap: () {
                                                  setState(() {
                                                    collection =
                                                        Collectionvalue;
                                                    print(collection);
                                                  });
                                                },
                                              ))
                                      .toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderDropdown<String>(
                                  name: "Car Fuel",
                                  decoration: const InputDecoration(
                                      labelText: 'Car Fuel',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 3.0,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      )),
                                  dropdownColor:
                                      Color.fromARGB(255, 255, 218, 223),
                                  initialValue: "Petrol",
                                  borderRadius: BorderRadius.circular(12),
                                  items: [
                                    'Petrol',
                                    'Diesel',
                                    'Electric',
                                    'PHEV'
                                  ]
                                      .map(
                                          (Collectionvalue) => DropdownMenuItem(
                                                value: Collectionvalue,
                                                child: Text(Collectionvalue),
                                                onTap: () {
                                                  setState(() {
                                                    fuel = Collectionvalue;
                                                    print(fuel);
                                                  });
                                                },
                                              ))
                                      .toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderDropdown<String>(
                                  name: "Car Condition",
                                  decoration: const InputDecoration(
                                      labelText: 'Car Condition',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 3.0,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      )),
                                  dropdownColor:
                                      Color.fromARGB(255, 255, 218, 223),
                                  initialValue: "Pristine",
                                  borderRadius: BorderRadius.circular(12),
                                  items: [
                                    'Pristine',
                                    'Good',
                                    'Fair',
                                    'Poor',
                                  ]
                                      .map((Conditionvalue) => DropdownMenuItem(
                                            value: Conditionvalue,
                                            child: Text(Conditionvalue),
                                            onTap: () {
                                              setState(() {
                                                Conditionvalue = Conditionvalue;
                                                condition = Conditionvalue;
                                                print(condition);
                                                print(condition);
                                              });
                                            },
                                          ))
                                      .toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderDropdown<String>(
                                  name: "Transmission",
                                  decoration: const InputDecoration(
                                      labelText: 'Transmission',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 3.0,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      )),
                                  dropdownColor:
                                      Color.fromARGB(255, 255, 218, 223),
                                  initialValue: "Automatic",
                                  borderRadius: BorderRadius.circular(12),
                                  items: [
                                    'Automatic',
                                    'Manual',
                                  ]
                                      .map((TransmissionValue) =>
                                          DropdownMenuItem(
                                            value: TransmissionValue,
                                            child: Text(TransmissionValue),
                                            onTap: () {
                                              setState(() {
                                                transmission =
                                                    TransmissionValue;
                                                print(transmission);
                                              });
                                            },
                                          ))
                                      .toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.number,
                                  name: "Year",
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: const InputDecoration(
                                      labelText: 'Year',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 3.0,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      )),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText: "Year cannot be empty"),
                                    FormBuilderValidators.numeric(),
                                    FormBuilderValidators.max(2024,
                                        errorText:
                                            "Price should be equal or lesser than 2024"),
                                    FormBuilderValidators.min(1990,
                                        errorText:
                                            "Price should be equal or greater than 1990")
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.number,
                                  name: "KMs Driven",
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: const InputDecoration(
                                      labelText: 'KMs Driven',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 3.0,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      )),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText:
                                            "KMs Driven cannot be empty"),
                                    FormBuilderValidators.numeric()
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderTextField(
                                  keyboardType: TextInputType.number,
                                  name: "Starting Price",
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: const InputDecoration(
                                      labelText: 'Starting Price',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 3.0,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      )),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText: "Price cannot be empty"),
                                    FormBuilderValidators.numeric(),
                                    FormBuilderValidators.max(20000000,
                                        errorText:
                                            "Price should be equal or lesser than 20000000"),
                                    FormBuilderValidators.min(100000,
                                        errorText:
                                            "Price should be equal or greater than 100000")
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderTextField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  name: 'City',
                                  decoration: const InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                        width: 3.0,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pink,
                                        width: 2.0,
                                      ),
                                    ),
                                    labelText: 'City',
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText: "City cannot be empty"),
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FormBuilderDropdown<String>(
                                  onChanged: (value) {
                                    switch (value) {
                                      case "2 Min":
                                        print(selectedDays);
                                        selectedDays = 0;
                                        break;

                                      case "3 Days":
                                        selectedDays = 3;
                                        break;
                                      case "7 Days":
                                        selectedDays = 7;
                                        break;
                                      case "14 Days":
                                        selectedDays = 14;
                                        break;
                                      default:
                                    }
                                  },
                                  name: "Auction Time",
                                  decoration: const InputDecoration(
                                      labelText: 'Auction Time',
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 3.0,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.pink,
                                          width: 2.0,
                                        ),
                                      )),
                                  dropdownColor:
                                      Color.fromARGB(255, 255, 218, 223),
                                  initialValue: "2 Min",
                                  borderRadius: BorderRadius.circular(12),
                                  items: [
                                    '2 Min',
                                    '3 Days',
                                    '7 Days',
                                    '14 Days'
                                  ]
                                      .map((dropdownValue) => DropdownMenuItem(
                                            value: dropdownValue,
                                            child: Text(dropdownValue),
                                          ))
                                      .toList(),
                                ),
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
                            child: FABcustom(
                                onTap: () {
                                  if (_csvContent != '') {
                                    try {
                                      //_parseCsv(_csvContent);
                                      PredictandParse(_csvContent);
                                    } catch (e) {
                                      showCustomSnackBar(
                                          context, "Invalid or Empty Data");
                                    }
                                  } else {
                                    showCustomSnackBar(context,
                                        "Please wait while we gather insights");
                                  }
                                },
                                text: "Get Insights"),
                          ),
                          Container(
                              padding: EdgeInsets.all(16.0),
                              child: isFutureComplete
                                  ? FABcustom(
                                      onTap: () async {
                                        if (formKey.currentState
                                                ?.saveAndValidate() ??
                                            false) {
                                          // If all validators pass
                                          final formData =
                                              formKey.currentState?.value;
                                          print('Form data: $formData');
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.grey,
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
            ),
          ],
        ),
      ),
    );
  }
}
