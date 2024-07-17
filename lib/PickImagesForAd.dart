// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, sized_box_for_whitespace, prefer_const_constructors, avoid_print, unnecessary_brace_in_string_interps, annotate_overrides, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'dart:io';
import 'dart:typed_data';
//import 'package:biddy/ContinueAd.dart';
import 'package:biddy/ContinueAdBetter.dart';
import 'package:biddy/components/FABcustom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AdData {
  final String titleURL;
  final List<String> pictureUrls;

  AdData({required this.titleURL, required this.pictureUrls});
}

class CreateAd extends StatefulWidget {
  const CreateAd({super.key});

  @override
  State<CreateAd> createState() => _CreateAdState();
}

class _CreateAdState extends State<CreateAd> {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = []; // List to store selected images
  List<File> _resizedImages = []; // List to store resized images
  List<String> uploadedImageUrls = []; // List to store uploaded image URLs
  String titleURL = "";
  String dropdownValue = '3 Days';
  File? _image;
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference adsCollection =
      FirebaseFirestore.instance.collection('Ads');

  void _openFullSizeImage(File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: Image.file(
              image,
              fit: BoxFit.fill,
            ),
          ),
        );
      },
    );
  }

  void _deleteImage(List<File> _images, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.15,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('Delete photo'),
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteAllImages(List<File> _images, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.15,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('Delete all images'),
                onTap: () {
                  setState(() {
                    _images.clear();
                    Navigator.pop(context);
                  });
                },
              ),
              ListTile(
                title: Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadCarAd(List<String> pictureUrls, String titleURL) {
    // Generate an auto-ID for the document
    return adsCollection
        .doc('Cars') // Nest under "Cars" subcollection
        .collection('SUVs') // Nest under "Sedan" subcollection
        .add({
          'title': titleURL,
          'brand': email.text.toString(),
          'model': pass.text.toString(),
          'year': 2022,
          'pics': pictureUrls
          // Add other fields as needed
        })
        .then((value) => print('Car ad added with ID: ${value.id}'))
        .catchError((error) => print('Failed to add car ad: $error'));
  }

  Future<void> resizeImages() async {
    List<File> resizedImages = [];
    for (File image in _images) {
      Uint8List? imageBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        minHeight: 800, // Set desired height
        minWidth: 600, // Set desired width
      );

      // Check if imageBytes is not null
      // Convert Uint8List to List<int>
      List<int> bytes = imageBytes!.toList();

      // Save the compressed image
      File compressedImage = await image.writeAsBytes(bytes);
      resizedImages.add(compressedImage);
      print("compressed");
    }
    setState(() {
      _resizedImages = resizedImages;
      _images = _resizedImages; // Assigning _resizedImages to _images
    });
  }

  Future<void> _getImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 70);
      setState(() {
        if (pickedFiles.isNotEmpty) {
          _images
              .addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
        }
        resizeImages();
      });
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<AdData> _uploadImages() async {
    try {
      // Upload title image
      Reference titleStorageReference = FirebaseStorage.instance
          .ref()
          .child('Ad Pics/${DateTime.now()}_${_image}.png');
      UploadTask titleUploadTask = titleStorageReference.putFile(_image!);

      await titleUploadTask.whenComplete(() {
        titleStorageReference.getDownloadURL().then((url) {
          titleURL = url;
          print('Title image URL: $titleURL');
        });
      });

      for (File image in _images) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('Ad Pics/${DateTime.now()}_${_images.indexOf(image)}.png');
        UploadTask uploadTask = storageReference.putFile(image);

        await uploadTask.whenComplete(() {
          print('Image uploaded successfully');
          // Get the download URL of the uploaded image
          storageReference.getDownloadURL().then((url) {
            uploadedImageUrls.add(url);
          });
        });
      }
    } catch (e) {
      print('Error uploading images: $e');
    }
    return handleUploadCompletion();
  }

  AdData handleUploadCompletion() {
    AdData ad = AdData(titleURL: titleURL, pictureUrls: uploadedImageUrls);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Images uploaded',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.pink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      duration: Duration(seconds: 4), // SnackBar duration
    ));
    return ad;
    // You can do further processing with the uploaded data here
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker2 = ImagePicker();
    final pickedImage2 = await picker2.pickImage(source: source);

    if (pickedImage2 != null) {
      setState(() {
        _image = File(pickedImage2.path);
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 255, 149, 163),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(builder: (context) {
              return IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
              );
            }),
            Text(
              "Create An Ad",
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_forward),
                color: Colors.white)
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 250, 250),
              Color.fromARGB(255, 255, 149, 163),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 1),
              ),
            ],
            borderRadius: BorderRadius.circular(12), //original 36
            color: Color.fromARGB(255, 255, 218, 223),
          ),
          child: ListView(
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            children: [
              SizedBox(
                height: 38,
              ),
              Center(
                  child: Text(
                "Choose Title Image",
                style: TextStyle(fontSize: 24),
              )),
              Center(
                child: _image == null
                    ? GestureDetector(
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                        },
                        child: Image.asset(
                          'lib/images/download.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.fill,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _openFullSizeImage(_image!);
                        },
                        onLongPress: () {
                          _pickImage(ImageSource.gallery);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.file(
                            _image!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )),
              ),
              Divider(
                thickness: 3, // Adjust thickness as needed
                color: Colors.white, // Set color according to your design
              ),
              SizedBox(
                height: 38,
              ),
              Center(
                  child: Text(
                "Add More Images",
                style: TextStyle(fontSize: 24),
              )),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: _images.isEmpty
                          ? Center(
                              child: Container(
                                child: GestureDetector(
                                  onTap: _getImages,
                                  child: Image.asset(
                                    'lib/images/download.png',
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _images.length +
                                  1, // Adding 1 for the additional GestureDetector
                              itemBuilder: (context, index) {
                                if (index == _images.length) {
                                  return GestureDetector(
                                    onTap: () {
                                      _getImages();
                                    },
                                    onLongPress: () {
                                      _deleteAllImages(_images, index);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 150,
                                        height: 200,
                                        child: Image.asset(
                                          'lib/images/download.png', // Replace with your placeholder image asset path
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      _openFullSizeImage(_images[index]);
                                    },
                                    onLongPress: () {
                                      _deleteImage(_images, index);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Image.file(
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                              width: 150,
                                              height: 200,
                                              color: Colors.red,
                                              child: Center(
                                                child: Text(
                                                  'Error loading image. Please try again',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ));
                                        },
                                        _images[index],
                                        width: 150,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }
                              },
                            )),
                ],
              ),
              Divider(
                thickness: 3, // Adjust thickness as needed
                color: Colors.white, // Set color according to your design
              ),
              SizedBox(
                height: 38,
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: FABcustom(
                    onTap: () {
                      Future<AdData> uploadImagesFuture =
                          _uploadImages(); // Get the future
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContinueAdBetter(
                              uploadImagesFuture: uploadImagesFuture),
                        ),
                      );
                    },
                    text: "Next",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
