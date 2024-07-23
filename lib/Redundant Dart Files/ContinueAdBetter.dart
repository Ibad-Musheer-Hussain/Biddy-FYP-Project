// ignore_for_file: file_names
import 'dart:io';
import 'package:biddy/PickImagesForAd.dart';
import 'package:biddy/components/FABcustom.dart';
import 'package:biddy/functions/showCustomSnackBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ContinueAdBetter extends StatefulWidget {
  const ContinueAdBetter({Key? key, required this.uploadImagesFuture})
      : super(key: key);
  final Future<AdData> uploadImagesFuture;
  @override
  State<ContinueAdBetter> createState() => _ContinueAdBetterState();
}

class _ContinueAdBetterState extends State<ContinueAdBetter> {
  final formKey = GlobalKey<FormBuilderState>();
  final description = TextEditingController();
  int _countHondaPristineSoldGreaterThanPoint1 = 0;
  int _countHondaPristineSoldEqualToZero = 0;
  int pricehigher = 0;
  int pricelower = 0;
  int selectedDays = 3;
  String titleURL = '';
  List<String> pictureUrls = [];
  String dropdownValue = '3 Days';
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
  double? probabilitySold;
  String _csvContent = '';

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
              500000;
      pricehigher =
          int.tryParse(formKey.currentState?.fields['Starting Price']?.value)! +
              500000;
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
      _showAlertDialog(context, "Count Results",
          "This model is not present at this price range in our data set");
    } else {
      _showAlertDialog(
        context,
        "Count Results",
        "${formKey.currentState?.fields['Brand']?.value} with Condition ${condition} Sold from price range $pricelower - $pricehigher ${formKey.currentState?.fields['Model']?.value}: $_countHondaPristineSoldGreaterThanPoint1\n${formKey.currentState?.fields['Brand']?.value} ${formKey.currentState?.fields['Model']?.value} not Sold: $_countHondaPristineSoldEqualToZero",
      );
    }
  }

  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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

  Future<void> downloadModelAndPredict() async {
    FirebaseModelDownloader modelDownloader = FirebaseModelDownloader.instance;
    FirebaseCustomModel customModel = await modelDownloader.getModel(
      'BiddyModel',
      FirebaseModelDownloadType.localModelUpdateInBackground,
    );
    final modelPath = customModel.file;
    // ignore: unnecessary_null_comparison
    if (modelPath != null) {
      final result = await predictWithModel(modelPath.path);
      setState(() {
        probabilitySold = result;
        print("final result:");
        showCustomSnackBar(context, "Final result $probabilitySold");
        print(probabilitySold);
      });
    }
  }

  Future<double> predictWithModel(String modelPath) async {
    final interpreter = await Interpreter.fromFile(File(modelPath));
    final input = createInput();
    final output = List.filled(1, 0).reshape([1, 1]);
    interpreter.run(input, output);

    return output[0][0].toDouble();
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
                                  initialValue: "3 Days",
                                  borderRadius: BorderRadius.circular(12),
                                  items: ['3 Days', '7 Days', '14 Days']
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
                                  if (formKey.currentState?.saveAndValidate() ??
                                      false) {
                                    downloadModelAndPredict();
                                  } else {
                                    showCustomSnackBar(context, "Invalid Data");
                                  }
                                },
                                text: "Predict"),
                          ),
                          Container(
                            padding: EdgeInsets.all(16.0),
                            child: FABcustom(
                                onTap: () {
                                  if (_csvContent != '') {
                                    try {
                                      _parseCsv(_csvContent);
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
