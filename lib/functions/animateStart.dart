// ignore_for_file: file_names, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

Offset animateStart(int index, int selectedIndex, int previousIndex,
    AnimationController controller) {
  Offset offset;
  if (selectedIndex < previousIndex) {
    offset = const Offset(1, 0);
  } else if (selectedIndex > previousIndex) {
    offset = const Offset(-1, 0);
  } else
    offset = const Offset(0, 0);
  controller.reset();
  controller.forward();
  return offset;
}
