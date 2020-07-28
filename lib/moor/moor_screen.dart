import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandbox_flutter/moor/moor_database.dart';
import 'package:sandbox_flutter/moor/moor_home.dart';

class MoorScreen extends StatefulWidget {
  @override
  _MoorScreenState createState() => _MoorScreenState();
}

class _MoorScreenState extends State<MoorScreen> {
  @override
  Widget build(BuildContext context) {
//    moorRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    return Provider(
      // eventually this initializing code should be in main func in main.dart
      create: (_) => AppDatabase(),
      dispose: (context, AppDatabase database) => database.close(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sandbox - Moor'),
        ),
        body: MoorHome(),
      ),
    );
  }
}
