import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project1/firebase_options.dart';
import 'package:project1/inventory_page.dart';
import 'package:project1/main.dart';
import 'package:project1/profile_page.dart';
import 'package:project1/report_page.dart';
import 'package:project1/scan_add_page.dart';


import 'package:project1/scan_page.dart';

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
      home: const AddPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class AddPage extends StatefulWidget {
  const AddPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController controller_product_name = TextEditingController();

  TextEditingController controller_code_product = TextEditingController();

  TextEditingController controller_category = TextEditingController();

  TextEditingController controller_cost_price = TextEditingController();

  TextEditingController controller_quantity = TextEditingController();

  TextEditingController controller_unit = TextEditingController();

  TextEditingController controller_bar_code = TextEditingController();

  TextEditingController controller_description = TextEditingController();

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: label,
          hintText: hintText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 210, 239),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Add Product", style: TextStyle(color: Colors.black)),
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

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            SizedBox(height: 10),

            _textField(
              label: 'Product Name',
              controller: controller_product_name,
              hintText: 'Enter product name',
            ),
            _textField(
              label: 'Code Product',
              controller: controller_code_product,
              hintText: 'Enter code product',
            ),

            Row(
              children: [
                Expanded(
                  child: _textField(
                    label: 'Bar Code',
                    controller: controller_bar_code,
                    hintText: 'Enter bar code',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ScanAddPage(title: 'Barcode Scanner'),
                      ),
                    ).then((value) {
                      controller_bar_code.text = value ?? "";
                    });
                  },
                ),
                SizedBox(width: 8),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _textField(
                    label: 'Category',
                    controller: controller_category,
                    hintText: 'Enter category',
                  ),
                ),
                Expanded(
                  child: _textField(
                    label: 'Cost Price',
                    controller: controller_cost_price,
                    hintText: 'Enter cost price',
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _textField(
                    label: 'Quantity',
                    controller: controller_quantity,
                    hintText: 'Enter quantity',
                  ),
                ),
                Expanded(
                  child: _textField(
                    label: 'Unit',
                    controller: controller_unit,
                    hintText: 'Enter unit',
                  ),
                ),
              ],
            ),

            _textField(
              label: 'Description',
              controller: controller_description,
              hintText: 'Enter description',
            ),

            SizedBox(height: 25),
            FilledButton(
              onPressed: () async {
                if (controller_product_name.text.isEmpty ||
                    controller_code_product.text.isEmpty ||
                    controller_category.text.isEmpty ||
                    controller_cost_price.text.isEmpty ||
                    controller_quantity.text.isEmpty ||
                    controller_unit.text.isEmpty ||
                    controller_bar_code.text.isEmpty ||
                    controller_description.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill in all fields.")),
                  );
                  return;
                } else {
                  await db.collection("Product").add({
                    "Product Name": controller_product_name.text,
                    // convert to Quantity to int
                    "Quantity": int.parse(controller_quantity.text),
                    // "Quantity": controller_quantity.text,
                    "Category": controller_category.text,
                    "Code Product": controller_code_product.text,
                    "Cost Price": controller_cost_price.text,
                    "Unit": controller_unit.text,
                    "Bar Code": controller_bar_code.text,
                    "Description": controller_description.text,
                    
                    
                  });

                  await db.collection("Report").add({
                    "Product Name": controller_product_name.text,
                    "Cost Price": controller_cost_price.text,
                    "In": "In",
                    "Date": DateTime.now().toString().substring(0, 10),
                    "Time" : TimeOfDay.now().format(context),
                  });
                  // Clear text fields
                  controller_product_name.clear();
                  controller_code_product.clear();
                  controller_category.clear();
                  controller_cost_price.clear();
                  controller_quantity.clear();
                  controller_unit.clear();
                  controller_bar_code.clear();
                  controller_description.clear();

                  // Show SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("The product is added successfully."),
                    ),
                  );

                  setState(() {});
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InventoryPage(title: 'Inventory'),
                  ),
                );
              },
              child: Text('Add Product'),
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
                IconButton(onPressed: () {}, icon: Icon(Icons.add_circle)),
                Text('Add'),
              ],
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanPage(title: 'Scan Barcode'),
                      ),
                    );
                  },
                  icon: Icon(Icons.qr_code_scanner),
                ),
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
