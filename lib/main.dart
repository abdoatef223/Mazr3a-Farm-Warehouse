import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mazr3a/core/di/injection.dart';
import 'package:mazr3a/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}
