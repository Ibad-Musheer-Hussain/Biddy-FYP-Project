// ignore_for_file: file_names

import 'package:biddy/functions/signOut.dart' show signOut;
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width / 1.2,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 149, 163),
              /*borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),*/
            ),
            height: MediaQuery.of(context).size.height / 7.8,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    "  User Last Name",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.ad_units),
            title: const Text(
              'Your Ads',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text(
              'Bid History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text(
              'Help',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {},
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
            child: Container(), // Empty container to fill remaining space
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
          )
        ],
      ),
    );
  }
}
