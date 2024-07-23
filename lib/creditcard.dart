import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CreditCardForm extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final User? user = FirebaseAuth.instance.currentUser;

  updatebalance(int num) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    print(user?.uid);
    if (doc.exists) {
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
                  'Credit / Debit Card',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.transparent,
              ),
            )
          ],
        ),
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FormBuilderTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    name: 'Name',
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: "Name as appears on card",
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
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Enter a Name',
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FormBuilderTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    name: 'Card',
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      hintText: "XXXX XXXX XXXXX XXXX",
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
                        errorText: 'Enter a valid card number',
                      ),
                      FormBuilderValidators.creditCard(),
                    ]),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'expiration_date',
                          decoration: const InputDecoration(
                            labelText: 'Expiration Date',
                            hintText: "XX/XX",
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
                          keyboardType: TextInputType.datetime,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'cvc',
                          decoration: const InputDecoration(
                            labelText: 'CVC',
                            hintText: "XXX",
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
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FormBuilderTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    name: 'Address',
                    decoration: const InputDecoration(
                      labelText: 'Billing Address',
                      hintText: "Full Address here",
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
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Enter a Name',
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'Amount',
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            hintText: "1000-99999",
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
                            FormBuilderValidators.required(),
                            FormBuilderValidators.match(
                              r'^\+?0?\d{3,5}$',
                              errorText: '100-99999',
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'city',
                          decoration: const InputDecoration(
                            labelText: 'City',
                            hintText: "Karachi",
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
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'email',
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: "john@gmail.com",
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
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.email()
                          ]),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'phone',
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            hintText: "0XXX-XXXXXXX",
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
                          keyboardType: TextInputType.phone,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.minLength(10),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.transparent,
          height: 50.0,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                final formData = _formKey.currentState?.value;
                print('Form data: $formData');
                updatebalance(
                    int.parse(_formKey.currentState?.fields['Amount']?.value));
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
