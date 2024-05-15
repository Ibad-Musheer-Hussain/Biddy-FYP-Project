// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

void openFullSizeImage(String image, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor:
            Colors.transparent, // Set background color to transparent
        child: PhotoView(
          imageProvider: NetworkImage(image),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered,
          backgroundDecoration: BoxDecoration(
              color: Colors
                  .transparent), // Set background decoration color to transparent
        ),
      );
    },
  );
}
