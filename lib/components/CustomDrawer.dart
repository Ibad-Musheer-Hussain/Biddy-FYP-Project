// ignore_for_file: file_names

import 'package:biddy/functions/signOut.dart' show signOut;
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomDrawer extends StatefulWidget {
  String name;
  int balance;
  final VoidCallback onBidHistoryTap;

  CustomDrawer({
    Key? key,
    required this.name,
    required this.balance,
    required this.onBidHistoryTap,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width / 1.2,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 149, 163),
            ),
            height: MediaQuery.of(context).size.height / 5.7, //5.7
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 38,
                    ),
                    Text(
                      "  Available balance",
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    Row(
                      children: [
                        Text(
                          "  Rs.${widget.balance}",
                          style: TextStyle(fontSize: 22, color: Colors.black87),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/payment');
                          },
                          label: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'Your Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.ad_units),
            title: const Text(
              'Your Ads',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/YourAds');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text(
              'Bid History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              widget.onBidHistoryTap();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text(
              'Help',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text(
              'Send Feedback',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          Expanded(
            child: Container(),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            onTap: () {
              signOut(context);
            },
          ),
          Container(
            height: 20,
          ),
        ],
      ),
    );
  }
}
