import 'package:flutter/material.dart';
import 'package:test_demo/app.dart';
import 'package:provider/provider.dart';
import 'package:test_demo/providers/home_provider.dart';

void main() {
  // setUrlWithoutHashTag();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
      ],
      child: MyApp(),
    ),
  );
}
