import 'package:flutter/material.dart';
import 'profile.dart'; // Import the Profile Screen
import 'package:url_launcher/url_launcher.dart';
import 'admin.dart'; // Import the Admin Screen
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

Future<void> sendSMS(String phoneNumber, String message) async {
  final Uri smsUri = Uri.parse(
    'sms:$phoneNumber?body=${Uri.encodeComponent(message)}',
  );

  if (await canLaunchUrl(smsUri)) {
    await launchUrl(smsUri);
  } else {
    print('Could not launch SMS app');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: SharedPreferences.getInstance().then(
          (prefs) => prefs.getString('userName'),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return EmergencyScreen(userName: snapshot.data);
        },
      ),
    );
  }
}

class EmergencyScreen extends StatefulWidget {
  final String? userName;

  const EmergencyScreen({super.key, this.userName});

  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String selectedAddress = "Home";
  String selectedMessage = "Need Help";

  void triggerEmergencySMS() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getString('latitude') ?? 'Unknown';
    final lon = prefs.getString('longitude') ?? 'Unknown';
    final message =
        "${widget.userName ?? 'User'} is at $selectedAddress (Lat: $lat, Lon: $lon), is in a $selectedMessage situation.";

    sendSMS("6238952266", message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RAKSHA"),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Menu button with no navigation
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Icon with Navigation
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen()),
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.userName ?? 'User',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Dropdown for Current Address
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Current Address",
                border: OutlineInputBorder(),
              ),
              value: selectedAddress,
              items:
                  ["Home", "Office", "School"].map((address) {
                    return DropdownMenuItem(
                      value: address,
                      child: Text(address),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAddress = value!;
                });
              },
            ),
            SizedBox(height: 15),

            // Dropdown for Message
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Message",
                border: OutlineInputBorder(),
              ),
              value: selectedMessage,
              items:
                  ["Need Help", "Emergency", "Medical Assistance"].map((msg) {
                    return DropdownMenuItem(value: msg, child: Text(msg));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMessage = value!;
                });
              },
            ),
            SizedBox(height: 20),

            // Emergency Number Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                EmergencyButton(number: "100"),
                EmergencyButton(number: "108"),
              ],
            ),
            SizedBox(height: 30),

            // Alert Button
            GestureDetector(
              onLongPress: () {
                triggerEmergencySMS(); // Trigger emergency SMS on long press
              },
              onLongPressDown: (details) {
                Future.delayed(Duration(seconds: 4), () {
                  triggerEmergencySMS(); // Send SMS after 2 seconds of holding
                });
              },
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(50),
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Long press for 4 seconds to send an alert',
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 40, color: Colors.white),
                    Text(
                      "ALERT",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ""),
        ],
      ),
    );
  }
}

// Emergency Number Button Widget
class EmergencyButton extends StatelessWidget {
  final String number;

  EmergencyButton({required this.number});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        backgroundColor: Colors.redAccent,
      ),
      onPressed: () {},
      child: Text(
        number,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
