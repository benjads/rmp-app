import 'package:flutter/material.dart';
import 'package:rmp_app/rmp_app.dart';

void main() {
  final String experimenterParameter = Uri.base.queryParameters['experimenter'];
  final bool experimenter = experimenterParameter == "true";
  runApp(RMPApp(experimenter));
}