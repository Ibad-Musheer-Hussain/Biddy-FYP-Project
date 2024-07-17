import 'package:flutter/material.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
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
                )),
            Container(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Center(
                child: Text(
                  'Add Cash',
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
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/creditcard');
                  },
                  leading: Icon(
                    Icons.credit_card,
                    size: 52,
                  ),
                  title: Text(
                    "Pay with",
                    style: TextStyle(color: Colors.black38, fontSize: 13),
                  ),
                  subtitle: Text(
                    "Credit/Debit Card",
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    size: 30,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/easypaisa');
                  },
                  leading: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10), // Adjust the value as needed
                    child: Image.asset(
                      "lib/images/images.jpg",
                      height: 70,
                    ),
                  ),
                  title: Text(
                    "Pay with",
                    style: TextStyle(color: Colors.black38, fontSize: 13),
                  ),
                  subtitle: Text(
                    "Easypaisa",
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    size: 30,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/jazzcash');
                  },
                  leading: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10), // Adjust the value as needed
                    child: Image.asset(
                      "lib/images/jazz.png",
                      height: 70,
                      width: 55,
                    ),
                  ),
                  title: Text(
                    "Pay with",
                    style: TextStyle(color: Colors.black38, fontSize: 13),
                  ),
                  subtitle: Text(
                    "JazzCash",
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    size: 30,
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
