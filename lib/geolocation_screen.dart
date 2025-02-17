import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Import the Home Screen

class GeolocationScreen extends StatefulWidget {
  @override
  _GeolocationScreenState createState() => _GeolocationScreenState();
}

class _GeolocationScreenState extends State<GeolocationScreen> {
  String latitude = '';
  String longitude = '';

  Future<void> _autoFillLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, please enable them in app settings',
            ),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = position.latitude.toStringAsFixed(6);
        longitude = position.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    }
  }

  Future<void> _confirmLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('latitude', latitude);
    await prefs.setString('longitude', longitude);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyScreen(userName: 'User'),
      ), // Pass the userName if needed
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Geolocation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Latitude",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  latitude = value;
                });
              },
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: "Longitude",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  longitude = value;
                });
              },
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _autoFillLocation,
              child: Text("Auto Fill Location"),
            ),
            SizedBox(height: 15),
            ElevatedButton(onPressed: _confirmLocation, child: Text("Confirm")),
          ],
        ),
      ),
    );
  }
}
