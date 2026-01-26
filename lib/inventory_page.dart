import 'package:flutter/material.dart';
import 'package:project1/add_page.dart';
import 'package:project1/firebase_options.dart';
import 'package:project1/main.dart';
import 'package:project1/profile_page.dart';
import 'package:project1/report_page.dart';
import 'package:project1/scan_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) {});
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const InventoryPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  
  String searchQuery = "";

  bool showAlertOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 210, 239),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title:  Text("Inventory", style: TextStyle(color: Colors.black)),
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

      body: Padding(
        padding:  EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔍 Search box (UI only)
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
                    searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search Product Name",
                  prefixIcon:  Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon:  Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              searchQuery = "";
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),
            //  Filter buttons
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showAlertOnly = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: !showAlertOnly
                        ? Colors.deepPurple
                        : Colors.transparent,
                    foregroundColor: !showAlertOnly
                        ? Colors.white
                        : Colors.deepPurple,
                  ),
                  child:  Text("All Items"),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showAlertOnly = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: showAlertOnly
                        ? Colors.deepPurple
                        : Colors.transparent,
                    foregroundColor: showAlertOnly
                        ? Colors.white
                        : Colors.deepPurple,
                  ),
                  child:  Text("Alert Items"),
                ),
              ],
            ),

             SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: showAlertOnly
                    ? db
                          .collection("Product")
                          .where("Quantity", isLessThan: 5)
                          .snapshots()
                    : db.collection("Product").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return  Center(child: Text("Error"));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  Center(child: CircularProgressIndicator());
                  }

                  // Convert docs to a local list for sorting
                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                  // Logic to move searched items to the top
                  if (searchQuery.isNotEmpty) {
                    docs.sort((a, b) {
                      String nameA = (a['Product Name'] ?? "")
                          .toString()
                          .toLowerCase();
                      String nameB = (b['Product Name'] ?? "")
                          .toString()
                          .toLowerCase();

                      bool matchA = nameA.contains(searchQuery);
                      bool matchB = nameB.contains(searchQuery);

                      if (matchA && !matchB) return -1; // A moves up
                      if (!matchA && matchB) return 1; // B moves up
                      return 0; // Keep original order if both or neither match
                    });
                  }

                  if (docs.isEmpty) {
                    return Center(child: Text("No products found"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      // Optional: Highlight matches or keep your existing Card UI
                      final String productName = data["Product Name"] ?? "";
                      final bool isMatch =
                          searchQuery.isNotEmpty &&
                          productName.toLowerCase().contains(searchQuery);

                      return Card(
                        // If it's a search match, you could give it a subtle border or background
                        color: Colors.grey.shade200,
                        shape: isMatch
                            ? RoundedRectangleBorder(
                                side: BorderSide(
                                  color: const Color.fromARGB(
                                    255,
                                    204,
                                    200,
                                    212,
                                  ),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              )
                            : null,
                        margin:  EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: ListTile(
                          // ... keep your existing ListTile code ...
                          leading: Icon(Icons.shopping_bag_outlined),
                          title: Text(
                            productName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Quantity: ${data["Quantity"]}"),
                          trailing: Text("Price: ${data["Cost Price"]}\$"),
                        ),
                      );
                    },
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
                        builder: (context) => MyHomePage(title: 'Scan Barcode'),
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
                IconButton(onPressed: () {}, icon: Icon(Icons.inventory)),
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
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanPage(title: 'Scan Barcode'),
                      ),
                    );
                  },
                  icon: Icon(Icons.qr_code_scanner_outlined),
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
