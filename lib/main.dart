import 'package:flutter/material.dart';
import 'package:sandbox_flutter/empty/empty_screen.dart';
import 'package:sandbox_flutter/moor/moor_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Flutter SandBox'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _navButton(context, 'moor', MoorScreen()),
            _navButton(context, 'empty', EmptyScreen()),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _navButton(BuildContext context, String title, Widget screenWidget) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: FlatButton(
        color: Colors.blue,
        child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screenWidget));
        },
      ),
    );
  }
}
