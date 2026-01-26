import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:project1/add_page.dart';
import 'package:project1/firebase_options.dart';
import 'package:project1/inventory_page.dart';
import 'package:project1/profile_page.dart';
import 'package:project1/report_page.dart';
import 'package:project1/scan_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Widget infoCard({
  required IconData icon,
  required String title,
  required Widget value,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 30),
        const SizedBox(height: 8),
        Text(title),
        const SizedBox(height: 4),
        value,
      ],
    ),
  );
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 210, 239),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Home", style: TextStyle(color: Colors.black)),
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Bar
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search Product Name",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = "";
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 20),

            //  SEARCH RESULTS
            if (_searchQuery.isNotEmpty) ...[
              Text(
                "Search Results",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Product")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final pName = (data['Product Name'] ?? "").toString();

                      if (!pName.toLowerCase().contains(_searchQuery)) {
                        return SizedBox.shrink();
                      }

                      return Card(
                        color: Colors.grey.shade100,
                        child: ListTile(
                          leading: Icon(Icons.shopping_bag_outlined),
                          title: Text(
                            pName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Quantity: ${data['Quantity']}"),
                          trailing: Text(
                            "Price: ${data['Cost Price']}\$",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20),
            ],

            //  INFO CARDS (ALWAYS VISIBLE)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InventoryPage(title: 'Inventory'),
                        ),
                      );
                    },
                    child: infoCard(
                      icon: Icons.inventory_2,
                      title: 'Total Inventory',
                      value: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("Product")
                            .snapshots(),
                        builder: (context, snapshot) {
                          final count = snapshot.hasData
                              ? snapshot.data!.docs.length
                              : 0;
                          return Text(
                            '$count Items',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: infoCard(
                    icon: Icons.credit_card,
                    title: 'Total Money',
                    value: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("Product")
                          .snapshots(),
                      builder: (context, snapshot) {
                        double total = 0;
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final price =
                                double.tryParse(doc['Cost Price'].toString()) ??
                                0;
                            final qty =
                                int.tryParse(doc['Quantity'].toString()) ?? 0;
                            total += price * qty;
                          }
                        }
                        return Text(
                          '${total.toStringAsFixed(2)} \$',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: infoCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Alert',
                    value: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("Product")
                          .where("Quantity", isLessThan: 5)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final count = snapshot.hasData
                            ? snapshot.data!.docs.length
                            : 0;
                        return Text(
                          '$count Items Low',
                          style: TextStyle(
                            color: count > 0 ? Colors.red : Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
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
            navItem(icon: Icons.home, label: 'Home', onTap: () {}),
            navItem(
              icon: Icons.inventory_2_outlined,
              label: 'Inventory',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventoryPage(title: 'Inventory'),
                  ),
                );
              },
            ),
            navItem(
              icon: Icons.add_circle_outline,
              label: 'Add',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AddPage(title: 'Add')),
                );
              },
            ),
            navItem(
              icon: Icons.qr_code_scanner,
              label: 'Scan',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanPage(title: 'Scan Barcode'),
                  ),
                );
              },
            ),
            navItem(
              icon: Icons.person_outlined,
              label: 'Profile',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(title: 'Profile'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget navItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Column(
    children: [
      IconButton(onPressed: onTap, icon: Icon(icon)),
      Text(label),
    ],
  );
}
