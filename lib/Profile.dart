import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  bool isEditing = false;
  bool isLoading = true;

  Future<void> getProfile() async {
    await Future.delayed(Duration(milliseconds: 800));
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    var data = doc.data() as Map<String, dynamic>;
    _nameController.text = data['name'];
    _addressController.text = data['address'];
    _contactController.text = data['contact'];
    _cnicController.text = data['cnic'];
    _uidController.text = user!.uid;

    // Update the loading state
    setState(() {
      isLoading = false;
    });
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });

    if (!isEditing) {
      FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'name': _nameController.text,
        'contact': _contactController.text,
        'address': _addressController.text
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getProfile();
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
                  'Your Profile',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isEditing ? Icons.check : Icons.edit,
                color: isEditing ? Colors.green : Colors.white,
              ),
              onPressed: _toggleEdit,
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
              padding: const EdgeInsets.all(32.0),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 300,
                        child: TextField(
                          controller: _nameController,
                          enabled: isEditing,
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.black54)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 300,
                        child: TextField(
                          controller: _contactController,
                          enabled: isEditing,
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: Colors.black54)),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 300,
                        child: TextField(
                          controller: _addressController,
                          enabled: isEditing,
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                              labelText: 'Address',
                              labelStyle: TextStyle(color: Colors.black54)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 300,
                        child: TextField(
                          controller: _cnicController,
                          enabled: false,
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                              labelText: 'CNIC Number',
                              labelStyle: TextStyle(color: Colors.black54)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 300,
                        child: TextField(
                          controller: _uidController,
                          enabled: false,
                          style: TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                              labelText: 'User ID',
                              labelStyle: TextStyle(color: Colors.black54)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
