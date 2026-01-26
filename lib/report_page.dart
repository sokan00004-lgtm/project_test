import 'package:flutter/material.dart';

import 'package:project1/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        colorScheme: .fromSeed(seedColor: Color.fromARGB(255, 248, 247, 251)),
      ),
      home: const ReportPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.title});
  final String title;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String filter = "All"; // All | In | Out

  @override
  Widget build(BuildContext context) {
    Query query = db.collection("Report");

    if (filter != "All") {
      query = query.where("In", isEqualTo: filter);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 210, 239),
      appBar: AppBar(
        title: Text("Report", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: Column(
        children: [
          /// FILTER BUTTONS
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton("All"),
                _filterButton("In"),
                _filterButton("Out"),
              ],
            ),
          ),

          ///  REPORT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return  Center(child: Text("No records found"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final isIn = data["In"] == "In";

                    return Card(
                      color: const Color.fromARGB(255, 242, 238, 238),
                      margin:  EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          data["Product Name"] ?? "",
                          style:  TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Price: ${data["Cost Price"]}\$"),
                            Text("Date: ${data["Date"]}"),
                            Text("Time: ${data["Time"]}"),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            data["In"],
                            style:  TextStyle(color: Colors.white),
                          ),
                          backgroundColor: isIn ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// FILTER BUTTON WIDGET
  Widget _filterButton(String value) {
    return ElevatedButton(
      onPressed: () {
        setState(() => filter = value);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: filter == value
            ? const Color.fromARGB(255, 172, 173, 229)
            : const Color.fromARGB(255, 238, 236, 236),
      ),
      child: Text(value),
    );
  }
}
