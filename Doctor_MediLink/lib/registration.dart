import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loginpage/loginpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController fullname = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController dob = TextEditingController();

  List<Map<String, dynamic>> districtlist = [];
  List<Map<String, dynamic>> placelist = [];

  final supabase = Supabase.instance.client;

  String? selectedGender;
  String? selectedDistrict;
  String? selectedPlace;
  File? _image;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchDistricts();
  }

  Future<void> fetchDistricts() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        districtlist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching districts: $e');
    }
  }

  Future<void> fetchPlace(String selectedDistrict) async {
    try {
      final response = await supabase.from('tbl_place').select().eq('district_id', selectedDistrict);
      setState(() {
        placelist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching places: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUp() async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email.text,
        password: password.text,
      );

      if (response.user != null) {
        String fullName = fullname.text;
        String firstName = fullName.split(' ').first;
        await supabase.auth.updateUser(UserAttributes(
          data: {'display_name': firstName},
        ));
      }

      final User? user = response.user;

      if (user == null) {
        print('Sign up error: $user');
      } else {
        final String userId = user.id;

        String? photoUrl;
        if (_image != null) {
          photoUrl = await _uploadImage(_image!, userId);
        }

        await supabase.from('tbl_user').insert({
          'user_id': userId,
          'user_name': fullname.text,
          'user_email': email.text,
          'user_photo': photoUrl,
          'user_password': password.text,
          'user_place': selectedPlace,
          'user_address': address.text,
          'user_gender': selectedGender,
          'user_dob': dob.text,
          'user_contact': contact.text
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Loginpage(),
          ),
        );
      }
    } catch (e) {
      print('Sign up failed: $e');
    }
  }

  Future<String?> _uploadImage(File image, String userId) async {
    try {
      final fileName = 'user_$userId';
      await supabase.storage.from('userdoc').upload(fileName, image);
      final imageUrl = supabase.storage.from('userdoc').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        
        child: Stack(
          children: [
            Container(
              height: 1100,
              width: 500,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color.fromARGB(255, 76, 171, 161), Colors.teal.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.3, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: AnimatedPositioned(
                duration: Duration(seconds: 5),
                left: -110,
                top: -100,
                child: Container(
                  width: 1000,
                  height: 5000,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal.shade700.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.shade700.withOpacity(0.8),
                        blurRadius: 30,
                        offset: Offset(20, 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.shade700.withOpacity(0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.shade700.withOpacity(0.8),
                      blurRadius: 20,
                      offset: Offset(10, 10),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -200,
              right: -300,
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade900, Color.fromARGB(255, 36, 181, 167)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.shade700.withOpacity(0.5),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 100,
              child: Text(
                "Create Your Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 150, left: 220),
              child: GestureDetector(
                onTap: pickImage,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 31, 111, 111),
                    image: _image != null ? DecorationImage(image: FileImage(_image!)) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.shade800.withOpacity(0.5),
                        blurRadius: 50,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _image == null
                      ? Icon(Icons.camera_alt, color: Colors.white, size: 50)
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 300),
                  _buildInputField(fullname, 'Full Name', Icons.person),
                  _buildInputField(address, 'Address', Icons.location_on),
                  _buildInputField(contact, 'Contact', Icons.phone, keyboardType: TextInputType.phone),
                  _buildGenderSelection(),
                  _buildInputField(email, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                  _buildInputField(password, 'Password', Icons.lock, obscureText: true),
                  _buildInputField(dob, 'Date of Birth', Icons.calendar_today, onTap: _pickDate),
                   SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 12,
                        shadowColor: Colors.teal.shade900,
                      ),
                      
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                      
                      ),
                    ),
                  ),
                  
// SizedBox(height: 20), // Add some space between the button and the text
      Padding(
        padding: const EdgeInsets.only(left: 50,top: 20),
        child: Center(
          child: Row(
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 227, 235, 234),
                  decoration: TextDecoration.underline,
                ),
              ),
              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Loginpage()),
                                  );
                                },
                                child: Text(
                                  "Sign in",
                                  style: TextStyle(color: const Color.fromARGB(255, 226, 232, 232),fontSize: 16),
                                ),
                              ),
                              
            ],
          ),
        ),
      ),


                ],
              ),
            ),
          ],
        ),
        
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromARGB(255, 241, 246, 246),
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.teal.shade800,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: Colors.teal.shade900,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: Colors.teal.shade900,
              width: 3.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: Colors.red,
              width: 2.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: Colors.redAccent,
              width: 3.0,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 241, 246, 246),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.teal.shade700,
          width: 2.0,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gender",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 13, 2, 2),
            ),
          ),
          Row(
            children: [
              Radio<String>(
                value: "Male",
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                activeColor: Colors.teal.shade900,
              ),
              Text("Male", style: TextStyle(color: Color.fromARGB(255, 75, 59, 59))),
              SizedBox(width: 15),
              Radio<String>(
                value: "Female",
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                activeColor: Colors.teal.shade900,
              ),
              Text("Female", style: TextStyle(color: Color.fromARGB(255, 75, 59, 59))),
              SizedBox(width: 15),
              Radio<String>(
                value: "Other",
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                activeColor: Colors.teal.shade900,
              ),
              Text("Other", style: TextStyle(color: Color.fromARGB(255, 75, 59, 59))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );

    if (pickedDate != null) {
      setState(() {
        dob.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }
}
