import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart'; // Import the home page
import 'admin.dart'; // Import the admin page


void main() {
  runApp(const EmergencySignupApp());
}

class EmergencySignupApp extends StatelessWidget {
  const EmergencySignupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Signup',
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;

  // Data storage
  Map<String, String> personalInfo = {};
  Map<String, String> addressDetails = {};
  List<Map<String, String>> householdMembers = [];
  List<Map<String, String>> emergencyContacts = [{'name': '', 'phone': ''}];

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      if (_currentPage < 3) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        // If it's the last page, navigate to HomePage after submission
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EmergencyScreen()),
        );
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Signup'),
        actions: [
            IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminLoginScreen(
                  onLoginSuccess: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminScreen()),
                    );
                  },
                )),
              );
            },
          ),

        ],
      ),

      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildPersonalInfoPage(),
            _buildAddressPage(),
            _buildHouseholdMembersPage(),
            _buildEmergencyContactsPage(), // Last page with Submit button
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return _buildPage(
      title: 'Personal Information',
      children: [
        _buildTextField('Name', 'Enter your name', (value) => personalInfo['name'] = value),
        _buildTextField('Phone Number', 'Enter your phone number', (value) => personalInfo['phone'] = value),
        _buildTextField('Alternative Number (Optional)', 'Enter alternative number',
                (value) => personalInfo['altPhone'] = value, isOptional: true),
        _buildTextField('Email', 'Enter your email', (value) => personalInfo['email'] = value),
      ],
    );
  }

  Widget _buildAddressPage() {
    return _buildPage(
      title: 'Address Details',
      children: [
        _buildTextField('House Number', 'Enter house number', (value) => addressDetails['houseNumber'] = value),
        _buildTextField('House Name', 'Enter house name', (value) => addressDetails['houseName'] = value),
        _buildTextField('House Identification', 'Describe the house (color, floors, etc.)', (value) => addressDetails['houseIdentification'] = value),
        _buildTextField('Ward Number', 'Enter ward number', (value) => addressDetails['wardNumber'] = value),
        _buildTextField('Panchayath', 'Enter panchayath', (value) => addressDetails['panchayath'] = value),
        _buildTextField('Pincode', 'Enter pincode', (value) => addressDetails['pincode'] = value),
        _buildTextField('District', 'Enter district', (value) => addressDetails['district'] = value),
        _buildTextField('State', 'Enter state', (value) => addressDetails['state'] = value),
      ],
    );
  }

  Widget _buildHouseholdMembersPage() {
    return _buildPage(
      title: 'Household Members',
      children: [
        _buildTextField('Number of Members', 'Enter number of members', (value) {
          int numMembers = int.tryParse(value) ?? 0;
          setState(() {
            householdMembers = List.generate(numMembers, (_) => {'name': '', 'dob': '', 'medical': ''});
          });
        }),
        ...householdMembers.map((member) => Column(
          children: [
            _buildTextField('Name', 'Enter name', (value) => member['name'] = value),
            _buildTextField('DOB/Age', 'Enter DOB or Age', (value) => member['dob'] = value),
            _buildTextField('Medical Issues', 'Enter medical details', (value) => member['medical'] = value),
          ],
        )).toList(),
      ],
    );
  }

  Widget _buildEmergencyContactsPage() {
    return _buildPage(
      title: 'Emergency Contacts',
      children: [
        ...emergencyContacts.map((contact) => Column(
          children: [
            _buildTextField('Contact Name', 'Enter name', (value) => contact['name'] = value),
            _buildTextField('Phone Number', 'Enter phone number', (value) => contact['phone'] = value),
          ],
        )).toList(),
        ElevatedButton(
          onPressed: () => setState(() {
            emergencyContacts.add({'name': '', 'phone': ''});
          }),
          child: const Text('Add Contact'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _nextPage, // This will navigate to HomePage after submission
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Submit', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPage({required String title, required List<Widget> children}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...children,
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(onPressed: _previousPage, child: const Text('Back')),
                  if (_currentPage < 3)
                    ElevatedButton(onPressed: _nextPage, child: const Text('Next')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onChanged, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        validator: isOptional ? null : (value) => value!.isEmpty ? 'Required' : null,
        onChanged: onChanged,
      ),
    );
  }
}
