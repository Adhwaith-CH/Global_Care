import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hospital/hospitallogin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController hospital_name = TextEditingController();
  final TextEditingController hospital_address = TextEditingController();
  final TextEditingController hospital_contact = TextEditingController();
  final TextEditingController hospital_email = TextEditingController();
  final TextEditingController hospital_password = TextEditingController();

  List<Map<String, dynamic>> districtlist = [];
  List<Map<String, dynamic>> placelist = [];

  final supabase = Supabase.instance.client;

  String? selectedDistrict;
  String? selectedPlace;

  PlatformFile? pickedImage;
  PlatformFile? pickedProof;

  String _hintText = "Proof"; // Default hint text
  Color _iconColor = Color(0xFF0D47A1); // Default icon color (blue)

  // Handle File Upload Process
  Future<void> handleImageUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<void> handleProofUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _hintText = result.files.first.name; // Update hintText with file name
        _iconColor = Colors.green; // Change icon color to green
      });
    }
  }

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
      final response = await supabase
          .from('tbl_place')
          .select()
          .eq('district_id', selectedDistrict);
      setState(() {
        placelist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching places: $e');
    }
  }

  Future<void> fetchdistrict() async {
    try {
      final response = await supabase
          .from('tbl_district')
          .select(); //database ill ninuu district enna table ill insert cheythaa value select cheyunuu
      setState(() {
        districtlist =
            response; //select cheythaa response "districtlist"leeku kodukunuu
      });
    } catch (e) {
      print('Exception during fetch:$e');
    }
  }

  Future<void> fetchplace(String selectedDistrict) async {
    try {
      final response =
          await supabase.from('tbl_place').select().eq('district_id', selectedDistrict);
          print(response);
      setState(() {
        placelist = response;
      });
      
    } catch (e) {
      print('Exception during fetch:$e');
    }
  }

  Future<void> _signUp() async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: hospital_email.text,
        password: hospital_password.text,
      );

      if (response.user != null) {
        String fullName = hospital_name.text;
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

        await supabase.from('tbl_hospital').insert({
          'hospital_id': userId,
          'hospital_name': hospital_name.text,
          'hospital_email': hospital_email.text,
          'hospital_password': hospital_password.text,
          'place_id': selectedPlace,
          'hospital_address': hospital_address.text,
          'hospital_contact': hospital_contact.text,
          // 'hospital_proof': hospital_proof.text,
        });

        if (pickedImage != null) {
          await photoUpload(userId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Hospitallogin(),
          ),
        );
      }
    } catch (e) {
      print('Sign up failed: $e');
    }
  }

  Future<void> photoUpload(String uid) async {
    try {
      final bucketName = 'hospital_docs'; // Replace with your bucket name
      final filePath = "$uid-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      await updateImage(uid, publicUrl);
    } catch (e) {
      print("Error photo upload: $e");
    }
  }

  Future<void> updateImage(String uid, String url) async {
    try {
      await supabase
          .from('tbl_hospital')
          .update({'hospital_photo': url, 'hospital_proof': url}).eq(
              'hospital_id', uid);
    } catch (e) {
      print("Error photo updating: $e");
    }
  }

  // Future<String?> _uploadImage(File image, String userId) async {
  //   try {
  //     final fileName = 'user_$userId';
  //     await supabase.storage.from('userdoc').upload(fileName, image);
  //     final imageUrl = supabase.storage.from('userdoc').getPublicUrl(fileName);
  //     return imageUrl;
  //   } catch (e) {
  //     print('Image upload failed: $e');
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Panel: Branding and Message
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF0D47A1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/medilink.png',
                    height: 300,
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Welcome to MediLink",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Your health, our priority. Register now to get started!",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Panel: Registration Form
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hospital Registration",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Fill out the form to register your hospital.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 800, top: 20),
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F1F1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 2),
                          ),
                          child: pickedImage == null
                              ? GestureDetector(
                                  onTap: handleImageUpload,
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: Color(0xFF0277BD),
                                    size: 50,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: pickedImage!.bytes != null
                                      ? Image.memory(
                                          Uint8List.fromList(
                                              pickedImage!.bytes!), // For web
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(pickedImage!
                                              .path!), // For mobile/desktop
                                          fit: BoxFit.cover,
                                        ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  _buildRegistrationForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(hospital_name, 'Hospital Name', Icons.local_hospital),
        SizedBox(height: 20),
        _buildInputField(hospital_address, 'Address', Icons.location_on),
        SizedBox(height: 20),
        _buildInputField(hospital_contact, 'Contact Number', Icons.phone),
        SizedBox(height: 20),
        _buildInputField(hospital_email, 'Email', Icons.email),
        SizedBox(height: 20),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
           
            hintText: 'District',
            prefixIcon: Icon(Icons.abc_outlined, color: Color(0xFF0D47A1)),
        
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
         
          borderSide: BorderSide.none,
        ),
            
          ),
          value: selectedDistrict, //initilizee cheyunuu
          validator: (value) {
            if (value == "" || value!.isEmpty) {
              return "Enter the district name";
            }
            return null;
          },
          hint: Text("select the district"),
          onChanged: (newValue) {
            //button click cheyubool text box ill select cheythaa valuee"newValue"leeku store cheyunuu
            setState(() {
              selectedDistrict =
                  newValue; //"newValue" ill ulla value "selectedDistrict"leeku store cheyunuu
                  fetchplace(selectedDistrict!);
            });
          },
          items: districtlist.map((district) {
            return DropdownMenuItem<String>(
              value: district['district_id'].toString(),
              child: Text(district['district_name']),
            );
          }).toList(),
        ),
        SizedBox(
          height: 20,
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            hintText: 'Place',
            fillColor: Color(0xFFF5F5F5),
            border: OutlineInputBorder(),
          ),
          value: selectedPlace, //initilizee cheyunuu
          validator: (value) {
            if (value == "" || value!.isEmpty) {
              return "Enter the Place name";
            }
            return null;
          },
          hint: Text("select the Place"),
          onChanged: (newValue) {
            //button click cheyubool text box ill select cheythaa valuee"newValue"leeku store cheyunuu
            setState(() {
              selectedPlace =
                  newValue; //"newValue" ill ulla value "selectedDistrict"leeku store cheyunuu
            });
          },
          items: placelist.map((place) {
            return DropdownMenuItem<String>(
              value: place['place_id'].toString(),
              child: Text(place['place_name']),
            );
          }).toList(),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          readOnly: true, // Prevent manual text input
          decoration: InputDecoration(
            prefixIcon:
                Icon(Icons.verified, color: _iconColor), // Dynamic icon color
            hintText: _hintText, // Dynamic hintText
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            suffixIcon: IconButton(
              icon: Icon(Icons.upload_file,
                  color: _iconColor), // Dynamic icon color
              onPressed: handleProofUpload, // Trigger file selection
            ),
          ),
          onTap:
              handleProofUpload, // Trigger file picker when user taps on the field
        ),
        SizedBox(height: 20),
        _buildInputField(hospital_password, 'Password', Icons.lock,
            obscureText: true),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              _signUp();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              backgroundColor: Color(0xFF0D47A1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Register',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 70, top: 20),
          child: Center(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 290),
                  child: Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Hospitallogin()),
                    );
                  },
                  child: Text(
                    "Sign in",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool obscureText = false,
    void Function()? onTap,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onTap: onTap,
      readOnly: onTap != null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF0D47A1)),
        hintText: hintText,
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
  }
}
