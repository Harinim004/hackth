import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'geolocation_screen.dart';
import 'admin.dart';
import 'onboarding_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

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
        future: SharedPreferences.getInstance().then(
          (prefs) => {
            'showOnboarding': prefs.getBool('isFirstLaunch') ?? true,
            'hasSubmitted': prefs.getBool('hasSubmitted') ?? false,
          },
        ),
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
  List<Map<String, String>> emergencyContacts = [
    {'name': '', 'phone': ''},
  ];

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
        await prefs.setString('userName', personalInfo['name'] ?? 'User');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GeolocationScreen()),
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
        title: const Text(
          'Raksha',
          style: TextStyle(
            color: Color.fromARGB(255, 209, 209, 209),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 216, 6, 48),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.admin_panel_settings,
              color: Color.fromARGB(255, 209, 209, 209),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AdminLoginScreen(
                        onLoginSuccess: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminScreen(),
                            ),
                          );
                        },
                      ),
                ),
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
        _buildTextField(
          'Name',
          'Enter your name',
          (value) => personalInfo['name'] = value,
        ),
        _buildTextField(
          'Phone Number',
          'Enter your phone number',
          (value) => personalInfo['phone'] = value,
        ),
        _buildTextField(
          'Alternative Number (Optional)',
          'Enter alternative number',
          (value) => personalInfo['altPhone'] = value,
          isOptional: true,
        ),
        _buildTextField(
          'Email',
          'Enter your email',
          (value) => personalInfo['email'] = value,
        ),
      ],
    );
  }

  Widget _buildAddressPage() {
    return _buildPage(
      title: 'Address Details',
      children: [
        _buildTextField(
          'House Number',
          'Enter house number',
          (value) => addressDetails['houseNumber'] = value,
        ),
        _buildTextField(
          'House Name',
          'Enter house name',
          (value) => addressDetails['houseName'] = value,
        ),
        _buildTextField(
          'House Identification',
          'Describe the house (color, floors, etc.)',
          (value) => addressDetails['houseIdentification'] = value,
        ),
        _buildTextField(
          'Ward Number',
          'Enter ward number',
          (value) => addressDetails['wardNumber'] = value,
        ),
        _buildTextField(
          'Panchayath',
          'Enter panchayath',
          (value) => addressDetails['panchayath'] = value,
        ),
        _buildTextField(
          'Pincode',
          'Enter pincode',
          (value) => addressDetails['pincode'] = value,
        ),
        _buildTextField(
          'District',
          'Enter district',
          (value) => addressDetails['district'] = value,
        ),
        _buildTextField(
          'State',
          'Enter state',
          (value) => addressDetails['state'] = value,
        ),
      ],
    );
  }

  Widget _buildHouseholdMembersPage() {
    return _buildPage(
      title: 'Household Members',
      children: [
        _buildTextField('Number of Members', 'Enter number of members', (
          value,
        ) {
          int numMembers = int.tryParse(value) ?? 0;
          setState(() {
            householdMembers = List.generate(
              numMembers,
              (_) => {'name': '', 'dob': '', 'medical': ''},
            );
          });
        }),
        ...householdMembers
            .map(
              (member) => Column(
                children: [
                  _buildTextField(
                    'Name',
                    'Enter name',
                    (value) => member['name'] = value,
                  ),
                  _buildTextField(
                    'DOB/Age',
                    'Enter DOB or Age',
                    (value) => member['dob'] = value,
                  ),
                  _buildTextField(
                    'Medical Issues',
                    'Enter medical details',
                    (value) => member['medical'] = value,
                  ),
                ],
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildEmergencyContactsPage() {
    return _buildPage(
      title: 'Emergency Contacts',
      children: [
        ...emergencyContacts
            .map(
              (contact) => Column(
                children: [
                  _buildTextField(
                    'Contact Name',
                    'Enter name',
                    (value) => contact['name'] = value,
                  ),
                  _buildTextField(
                    'Phone Number',
                    'Enter phone number',
                    (value) => contact['phone'] = value,
                  ),
                ],
              ),
            )
            .toList(),
        ElevatedButton(
          onPressed:
              () => setState(() {
                emergencyContacts.add({'name': '', 'phone': ''});
              }),
          child: const Text(
            'Add Contcts',
            style: TextStyle(color: Color.fromARGB(255, 202, 7, 30)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            // First, export the data to Excel
            await exportToExcel(
              personalInfo,
              addressDetails,
              householdMembers,
              emergencyContacts,
            );

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GeolocationScreen()),
            );

            // Then, execute _nextPage()
            await _nextPage();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 202, 7, 30),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(color: Color.fromARGB(255, 219, 219, 219)),
          ),
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
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...children,
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: _previousPage,
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: Color.fromARGB(255, 202, 7, 30),
                        ),
                      ),
                    ),
                  if (_currentPage < 3)
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 202, 7, 30),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Color.fromARGB(255, 219, 219, 219),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    Function(String) onChanged, {
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        validator:
            isOptional ? null : (value) => value!.isEmpty ? 'Required' : null,
        onChanged: onChanged,
      ),
    );
  }
}

Future<void> exportToExcel(
  Map<String, dynamic> personalInfo,
  Map<String, dynamic> addressDetails,
  List<Map<String, dynamic>> members,
  List<Map<String, dynamic>> contacts,
) async {
  var excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];

  // Add headers
  sheet.appendRow([
    TextCellValue("Name"),
    TextCellValue("Phone"),
    TextCellValue("Email"),
    TextCellValue("House No"),
    TextCellValue("House Name"),
    TextCellValue("Identification"),
    TextCellValue("Ward No"),
    TextCellValue("Panchayath"),
    TextCellValue("Pincode"),
    TextCellValue("District"),
    TextCellValue("State"),
    TextCellValue("Member Name"),
    TextCellValue("DOB"),
    TextCellValue("Medical Info"),
    TextCellValue("Contact Name"),
  ]);

  // Add data
  for (int i = 0; i < members.length; i++) {
    sheet.appendRow([
      TextCellValue(personalInfo['name']),
      TextCellValue(personalInfo['phone']),
      TextCellValue(personalInfo['email']),
      TextCellValue(addressDetails['houseNumber']),
      TextCellValue(addressDetails['houseName']),
      TextCellValue(addressDetails['houseIdentification']),
      TextCellValue(addressDetails['wardNumber']),
      TextCellValue(addressDetails['panchayath']),
      TextCellValue(addressDetails['pincode']),
      TextCellValue(addressDetails['district']),
      TextCellValue(addressDetails['state']),
      TextCellValue(members[i]['name']),
      TextCellValue(members[i]['dob']),
      TextCellValue(members[i]['medical']),
      contacts.isNotEmpty
          ? TextCellValue(contacts[i]['name'])
          : TextCellValue(""),
    ]);
  }

  // Save file
  Directory? directory = Directory("/storage/emulated/0/Documents/");
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  String path = "${directory!.path}database.xlsx";
  File file = File(path);
  await file.writeAsBytes(excel.encode()!);

  /*Save file
  Directory? directory = await getExternalStorageDirectory();
  String path = "${directory!.path}database.xlsx";
  File file = File(path);
  await file.writeAsBytes(excel.encode()!);

*/

  print("Excel file saved at $path");
}
