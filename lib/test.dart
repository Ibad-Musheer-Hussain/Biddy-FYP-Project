import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  int _countHondaPristineSoldGreaterThanPoint1 = 0;
  int _countHondaPristineSoldEqualToZero = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndParseCsv();
  }

  Future<void> _downloadAndParseCsv() async {
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
        // Decode the CSV file
        final csvData =
            const CsvToListConverter().convert(response.body, eol: '\n');

        int countSoldGreaterThanPoint1 = 0;
        int countSoldEqualToZero = 0;

        // Analyze data to count Honda Pristine sold > 0.1 and sold == 0
        csvData.skip(1).forEach((row) {
          final brand = row[0].toString().trim(); // Brand column
          final condition = row[1].toString().trim(); // Condition column
          final model = row[4].toString().trim();
          final soldProbability =
              double.parse(row[8].toString().trim()); // Sold column

          if (brand == 'Honda' && condition == 'Pristine' && model == 'City') {
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
      } else {
        throw Exception('Failed to load CSV file');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Data'),
      ),
      body: Center(
        child: _countHondaPristineSoldGreaterThanPoint1 == 0 &&
                _countHondaPristineSoldEqualToZero == 0
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'Number of Honda City cars in Pristine condition with sold probability > 0.1: $_countHondaPristineSoldGreaterThanPoint1'),
                  Text(
                      'Number of Honda cars in Pristine condition with sold probability == 0: $_countHondaPristineSoldEqualToZero'),
                ],
              ),
      ),
    );
  }
}
