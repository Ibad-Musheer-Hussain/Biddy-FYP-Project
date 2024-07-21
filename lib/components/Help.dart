import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  final List<Map<String, dynamic>> guideSections = [
    {
      'title': 'Getting Started',
      'steps': [
        'Creating an Account',
        '1. Open Biddy and navigate to the Authentication page.',
        '2. Fill in the required details: Email and Password.',
        '3. If an account is not created for the entered email, then the sign-up button will appear.',
        '4. Tap on the sign-up button and proceed to the next page.',
        '5. Input your remaining details and tap on “Finalize Account” button to finish creating your account.',
      ],
    },
    {
      'title': 'Logging In',
      'steps': [
        '1. Open Biddy and navigate to the Authentication page.',
        '2. Enter your email and tap on the “Continue” button.',
        '3. If an account exists under the entered name, a log-in button will appear, input the correct password.',
        '4. Tap on "Log In" to access your account.',
      ],
    },
    {
      'title': 'Navigating the App',
      'steps': [
        'Home Screen',
        '• The home screen displays featured products and current auctions.',
        '• Use the navigation bar at the bottom to access different sections of the app.',
        'Menu Options',
        '• Tap the menu icon to access various options: Home, Favorite, Create Listing, Chats, and History.',
      ],
    },
    {
      'title': 'User Profile',
      'steps': [
        'Viewing Profile',
        '1. Tap on the avatar icon in the menu.',
        '2. Tap on “Your Profile”.',
        '3. You can now view your information.',
        'Favorite Section',
        '1. On the navigation bar in the main screen, Tap on the favorite icon.',
        '2. If any listing has been liked, it would show in the favorite section.',
      ],
    },
    {
      'title': 'Product Listing',
      'steps': [
        'Creating a New Listing',
        '1. Tap on the “Create” button on the main page.',
        '2. Choose the title image and add additional images.',
        '3. Fill in the product details.',
        '4. Click on “Get Insights” to get information from our ML Model.',
        '5. Click "Publish Ad" to create your listing.',
        'View Listings',
        '1. Navigate to the main page.',
        '2. On the right side of the bottom navigation bar, tap on the history button.',
        '3. You can now view your previous listings and bid history.',
      ],
    },
    {
      'title': 'Searching and Filtering',
      'steps': [
        'Using Search',
        '1. Tap the search bar on the main screen.',
        '2. Enter keywords related to the product you are looking for.',
        '3. View the search results.',
        'Applying Filters',
        '1. When typing on the search bar, the filters would automatically appear.',
        '2. Input filters such as year, price range, and KMs Driven.',
        '3. The filter would be automatically applied.',
      ],
    },
    {
      'title': 'Bidding Process',
      'steps': [
        'Placing a Bid',
        '1. Open the product page of the item you want to bid on.',
        '2. Tap on the “Bid” button.',
        '3. Select your bid amount in the bid box. It must be higher than the current bid.',
        '4. Click "Place Bid" to submit your bid.',
        'Viewing Bid History',
        '1. Access the main page.',
        '2. In the bottom navigation bar of the screen, tap on the history icon.',
      ],
    },
    {
      'title': 'In-App Messaging',
      'steps': [
        'Sending and Receiving Messages',
        '1. Go to "Messages" from the menu.',
        '2. Select a conversation you are a part of.',
        '3. Type your message and click "Send."',
      ],
    },
    {
      'title': 'Troubleshooting and Support',
      'steps': [
        'Common Issues',
        '• If you encounter any issues, check our Help section in the drawer to read the User Manual to answer FAQs.',
        'Sending Feedback',
        '• Your feedback is always appreciated, you can send your feedback in the “Send Feedback” menu in the drawer.',
      ],
    },
  ];

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
                  'User Guide',
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
      body: ListView.builder(
        itemCount: guideSections.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              guideSections[index]['title'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children:
                (guideSections[index]['steps'] as List<String>).map((step) {
              return ListTile(
                title: Text(step),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
