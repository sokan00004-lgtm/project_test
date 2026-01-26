import 'package:flutter/material.dart';
import 'package:project1/add_page.dart';
import 'package:project1/inventory_page.dart';
import 'package:project1/main.dart';
import 'package:project1/report_page.dart';
import 'package:project1/scan_page.dart';

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
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const ProfilePage(title: 'Profile'),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final logo = Image.asset('assets/logo.png');
  // ---------- EDIT MODE ----------
  bool isEditing = false;
  // Text Field Controller for input fields
  final nameController = TextEditingController();
  final genderController = TextEditingController();
  final idController = TextEditingController();
  final departmentController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    genderController.dispose();
    idController.dispose();
    departmentController.dispose();
    phoneController.dispose();
    emailController.dispose();
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

      //  -------------------------- Body ---------------------------------
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            // Hearder background
            Container(
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [Image.asset("assets/logo.png", height: 150)],
              ),
            ),
            SizedBox(height: 16),

            // Profile info
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage("assets/logo.png"),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameController.text,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      emailController.text,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            // ---------- FORM ----------
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: buildField("Full Name", nameController)),
                SizedBox(width: 12),
                Expanded(child: buildField("Gender", genderController)),
              ],
            ),
            SizedBox(height: 12),
            buildField("ID", idController),
            SizedBox(height: 12),
            buildField("Department", departmentController),
            SizedBox(height: 12),
            buildField("Phone Number", phoneController),
            SizedBox(height: 12),
            buildField("E-Mail", emailController),
            SizedBox(height: 24),

            // Update button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                });
                if (!isEditing) {
                  //SAVE TO FIREBASE HERE (later)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Profile updated successfully")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: Text(
                isEditing ? "Save" : "Update",
                style: TextStyle(fontSize: 16),
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
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanPage(title: 'Scan'),
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
                IconButton(onPressed: () {}, icon: Icon(Icons.person)),
                Text('Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- INPUT FIELD ----------
  Widget buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: isEditing,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.grey.shade200,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
