import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class Easypaisa extends StatefulWidget {
  const Easypaisa({super.key});

  @override
  State<Easypaisa> createState() => _EasypaisaState();
}

class _EasypaisaState extends State<Easypaisa> {
  final formKey2 = GlobalKey<FormBuilderState>();
  final User? user = FirebaseAuth.instance.currentUser;

  updatebalance(int num) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    print(user?.uid);
    if (doc.exists) {
      // Cast the data to a Map to access the fields
      var data = doc.data() as Map<String, dynamic>;
      try {
        int balance = data['balance'];
        int currentBalance = balance;
        currentBalance = currentBalance + num;
        FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .update({'balance': currentBalance});
      } catch (e) {
        print("catch");
        print(e);
        FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .update({'balance': num});
      }
      print("done");
    } else {
      print('Document does not exist');
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
                  'Easypaisa',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.transparent,
              ),
            )
          ],
        ),
      ),
      body: Container(
        color: Colors.black12,
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            FormBuilder(
              key: formKey2,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FormBuilderTextField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          name: 'Phone',
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
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
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Enter a valid phone number',
                            ),
                            FormBuilderValidators.match(
                              r'^\+?0?\d{11,13}$',
                              errorText: 'Enter a valid phone number',
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FormBuilderTextField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          name: 'Amount',
                          decoration: const InputDecoration(
                            labelText: 'Amount',
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
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Enter a valid amount',
                            ),
                            FormBuilderValidators.match(
                              r'^\+?0?\d{3,5}$',
                              errorText: '100-99999',
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FormBuilderTextField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          name: 'MPIN',
                          decoration: const InputDecoration(
                            labelText: 'Easypaisa MPIN',
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
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Enter a valid MPIN',
                            ),
                            FormBuilderValidators.match(
                              r'^\+?0?\d{5}$',
                              errorText: 'Enter a valid MPIN',
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.transparent,
          height: 50.0, // Set the height of the button
          width: double.infinity, // Make sure the button spans the full width
          child: ElevatedButton(
            onPressed: () {
              if (formKey2.currentState?.saveAndValidate() ?? false) {
                final formData = formKey2.currentState?.value;
                print('Form data: $formData');
                updatebalance(
                    int.parse(formKey2.currentState?.fields['Amount']?.value));
                Navigator.pushNamed(context, '/MainPage');
              } else {
                print('Validation failed');
              }
            },
            child: Text(
              'Recharge Amount',
              style: TextStyle(fontSize: 18.0),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
                  Color.fromARGB(255, 255, 149, 163), // Background color
            ),
          ),
        ),
      ),
    );
  }
}
