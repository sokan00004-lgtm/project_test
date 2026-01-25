import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project1/add_page.dart';
import 'package:project1/firebase_options.dart';
import 'package:project1/inventory_page.dart';
import 'package:project1/main.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project1/profile_page.dart';
import 'package:project1/report_page.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) {
    // print("Firebase initialized");
  });
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
      home: const ScanPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Scan Barcode", style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReportPage(title: 'Report'),
                  ),
                );
              },
              icon: Icon(Icons.list_alt),
            ),
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            SizedBox(
              height: 220,
              width: 220,
              child: MobileScanner(
                onDetect: (capture) async {
                  if (capture.barcodes.isEmpty) return;

                  final String? barCode = capture.barcodes.first.rawValue;
                  if (barCode == null) return;

                  // Read product from Firestore using barcode
                  final query = await FirebaseFirestore.instance
                      .collection('Product')
                      .where('Bar Code', isEqualTo: barCode)
                      .limit(1)
                      .get();

                  if (!context.mounted) return;

                  if (query.docs.isEmpty) {
                    //  Product not found
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Not Found"),
                        content: Text(
                          "No product found for barcode:\n$barCode",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  // Product found
                  final data = query.docs.first.data();

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Product Information"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${data["Product Name"]}"),
                          Text("Quantity: 1"),

                          Text("Price: ${data["Cost Price"]}\$"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),

                        TextButton(
                          onPressed: () {
                            // Update data.Qnatity in Firestore decrement by 1
                            FirebaseFirestore.instance
                                .collection('Product')
                                .doc(query.docs.first.id)
                                .update({
                                  'Quantity': (data['Quantity'] as int) - 1,
                                });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Sold 1 ${data["Product Name"]}",
                                ),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MyHomePage(title: 'Home'),
                              ),
                            );
                          },
                          child: Text("Confirm"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        height: 84,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(title: 'Home'),
                      ),
                    );
                  },
                  icon: Icon(Icons.home_outlined),
                ),
                Text('Home'),
              ],
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InventoryPage(title: 'Inventory'),
                      ),
                    );
                  },
                  icon: Icon(Icons.inventory_2_outlined),
                ),
                Text('Inventory'),
              ],
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPage(title: 'Add'),
                      ),
                    );
                  },
                  icon: Icon(Icons.add_circle_outline),
                ),
                Text('Add'),
              ],
            ),
            Column(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.barcode_reader)),
                Text('Scan'),
              ],
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(title: 'Profile'),
                      ),
                    );
                  },
                  icon: Icon(Icons.person_outlined),
                ),
                Text('Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
