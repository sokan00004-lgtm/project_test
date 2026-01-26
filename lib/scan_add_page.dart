import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ScanAddPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ScanAddPage extends StatefulWidget {
  const ScanAddPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ScanAddPage> createState() => _ScanAddPageState();
}

class _ScanAddPageState extends State<ScanAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 239, 241),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Scan Barcode", style: TextStyle(color: Colors.black)),
        
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            SizedBox(
              height: 220,
              width: 220,
              child: MobileScanner(
                onDetect: (result) {
                  if (result.barcodes.isNotEmpty) {
                    String? bar_code = result.barcodes.first.rawValue;
                    Navigator.of(context).pop(bar_code ?? "");
                  }
                },
              ),
            ),
          ],
        ),
      ),

        );
  }
}
