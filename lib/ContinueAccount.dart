import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class Continueaccount extends StatefulWidget {
  const Continueaccount({super.key});

  @override
  State<Continueaccount> createState() => _ContinueaccountState();
}

class _ContinueaccountState extends State<Continueaccount> {
  final formKey = GlobalKey<FormBuilderState>();
  User? user = FirebaseAuth.instance.currentUser;

  updateinformation() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    if (doc.exists) {
      // Cast the data to a Map to access the fields
      try {
        FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
          'name': formKey.currentState?.fields['name']?.value,
          'contact': formKey.currentState?.fields['phone']?.value,
          'cnic': formKey.currentState?.fields['cnic']?.value,
          'address': formKey.currentState?.fields['address']?.value
        });
      } catch (e) {
        print(e);
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
                    'Finalize Account',
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
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FormBuilderTextField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            name: 'name',
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              hintText: 'Your Full Name',
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            name: 'phone',
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: "03XX-XXXXXXX",
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            name: 'cnic',
                            decoration: const InputDecoration(
                              labelText: 'CNIC Number',
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
                                errorText: 'Enter a valid CNIC Number',
                              ),
                              FormBuilderValidators.match(
                                r'^42\d{11}$',
                                errorText: 'Enter a valid CNIC Number',
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            name: 'address',
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              hintText: 'Permanent Address',
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
                                errorText: 'Enter a valid address',
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
              onPressed: () async {
                if (formKey.currentState?.saveAndValidate() ?? false) {
                  final formData = formKey.currentState?.value;
                  print('Form data: $formData');
                  await updateinformation();
                  Navigator.pushNamed(context, '/circleavatar');
                } else {
                  print('Validation failed');
                }
              },
              child: Text(
                'Continue',
                style: TextStyle(fontSize: 18.0),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Color.fromARGB(255, 255, 149, 163), // Background color
              ),
            ),
          ),
        ));
  }
}
