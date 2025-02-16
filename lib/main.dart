import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'admin.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  
  runApp(EmergencySignupApp(isFirstLaunch: isFirstLaunch));
}

class EmergencySignupApp extends StatelessWidget {
  final bool isFirstLaunch;
  
  const EmergencySignupApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Signup',
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: FutureBuilder<Map<String, bool>>(
        future: SharedPreferences.getInstance().then((prefs) => {
          'showOnboarding': prefs.getBool('isFirstLaunch') ?? true,
          'hasSubmitted': prefs.getBool('hasSubmitted') ?? false,
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final showOnboarding = snapshot.data!['showOnboarding']!;
          final hasSubmitted = snapshot.data!['hasSubmitted']!;
          
          if (hasSubmitted) {
            return const EmergencyScreen();
          }
          
          return showOnboarding
              ? OnboardingScreen(
                  onSkip: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isFirstLaunch', false);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const SignupPage()),
                    );
                  },
                )
              : const SignupPage();
        },
      ),


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

  Future<void> _nextPage() async {
    if (_formKey.currentState!.validate()) {
      if (_currentPage < 3) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSubmitted', true);
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
            _buildEmergencyContactsPage(),
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
          onPressed: _nextPage,
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
