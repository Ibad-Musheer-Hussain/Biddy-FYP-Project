import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = "1.0.0";
    _contactController.text = "1.1.0";
    _addressController.text = '12';
    _cnicController.text = '24';
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
                  'Settings',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.transparent,
              ),
              onPressed: () {},
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  width: 300,
                  child: TextField(
                    controller: _nameController,
                    enabled: false,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        labelText: 'Client Version',
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
                    enabled: false,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        labelText: 'Server Version',
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
                    controller: _addressController,
                    enabled: false,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        labelText: 'Font Size',
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
                        labelText: 'Header Font Size',
                        labelStyle: TextStyle(color: Colors.black54)),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
