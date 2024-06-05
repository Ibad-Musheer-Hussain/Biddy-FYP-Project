// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/streams.dart';

Stream<List<QuerySnapshot>> mergeStreams() {
    List<Stream<QuerySnapshot>> streams = [
      FirebaseFirestore.instance
      .collection('Ads')
      .doc('Cars')
      .collection('Motorbikes').snapshots(),
      FirebaseFirestore.instance
      .collection('Ads')
      .doc('Cars')
      .collection('Coupes').snapshots(),
      FirebaseFirestore.instance
      .collection('Ads')
      .doc('Cars')
      .collection('Hatchbacks').snapshots(),
      FirebaseFirestore.instance
      .collection('Ads')
      .doc('Cars')
      .collection('Sedan').snapshots(),
      FirebaseFirestore.instance
      .collection('Ads')
      .doc('Cars')
      .collection('SUVs').snapshots(),
    ];
    return CombineLatestStream.list(streams);
  }