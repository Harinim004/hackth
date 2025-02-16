import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class AdminLoginScreen extends StatefulWidget {
  final Function() onLoginSuccess;

  const AdminLoginScreen({required this.onLoginSuccess, super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  void _login() {
    if (_formKey.currentState!.validate()) {
      if (_usernameController.text == 'ADMIN' && 
          _passwordController.text == 'RAKSHA') {
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage = 'Invalid username or password';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(

        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MapMarker {
  final String name;
  final LatLng coordinates;
  final String details;

  MapMarker({
    required this.name,
    required this.coordinates,
    required this.details,
  });
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoggedIn = false;
  int _currentIndex = 0;

  final List<MapMarker> demoMarkers = [

    MapMarker(
      name: 'Location 1',
      coordinates: LatLng(8.5241, 76.9366),
      details: 'Sample location details 1',
    ),
    MapMarker(
      name: 'Location 2',
      coordinates: LatLng(8.5250, 76.9350),
      details: 'Sample location details 2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/admin_profile.png'),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text('Admin ID: 12345'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // TODO: Implement hamburger menu
              },
            ),
          ],
        ),
      ),
      body: _currentIndex == 0 ? _buildMapSection() : _buildMessageSection(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(8.5241, 76.9366),
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: demoMarkers.map((marker) {
                  return Marker(
                    point: marker.coordinates,
                    builder: (ctx) => IconButton(
                      icon: Icon(Icons.location_on, color: Colors.red),
                      onPressed: () {
                        _showLocationDetails(marker);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Center(
      child: Text('Messages section - To be implemented'),
    );
  }

  void _showLocationDetails(MapMarker marker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(marker.name),
        content: Text(marker.details),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
