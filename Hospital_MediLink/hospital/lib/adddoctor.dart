import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hospital/formvalidation.dart';

class Adddoctor extends StatefulWidget {
  const Adddoctor({super.key});

  @override
  State<Adddoctor> createState() => _AdddoctorState();
}

class _AdddoctorState extends State<Adddoctor> {
  final TextEditingController fullname = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController fileController = TextEditingController();

  List<Map<String, dynamic>> districtlist = [];
  List<Map<String, dynamic>> placelist = [];
  List<Map<String, dynamic>> hospitaldepartmentlist = [];

  final supabase = Supabase.instance.client;

  String? selectedGender;
  String? selectedDistrict;
  String? selectedPlace;
  String? selectedDoctorDepartment;
  PlatformFile? pickedImage;
  PlatformFile? pickedProof;

  final String _hintText = "Proof";
  bool _showGenderOptions = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    fetchDepartment();
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

  Future<void> handleImageUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Uint8List? selectedFileBytes;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFileBytes = result.files.first.bytes;
        fileController.text = result.files.first.name;
      });
    } else {
      print("No file selected");
    }
  }

  Future<void> fetchDepartment() async {
    try {
      final response = await supabase
          .from('tbl_hospitaldepartment')
          .select("*, tbl_department(*)");
      setState(() {
        hospitaldepartmentlist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching hospitaldepartment: $e');
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (pickedImage != null && selectedFileBytes != null) {
        try {
          final AuthResponse response = await supabase.auth.signUp(
            email: email.text,
            password: password.text,
          );

          final User? user = response.user;

          if (user == null) {
            print('Sign up error: $user');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign up failed: User not created')),
            );
          } else {
            final String userId = user.id;

            String? photoUrl = await _uploadImage(userId);
            String? proofUrl = await _uploadproof(userId);
            String? gid = await getGID();

            await supabase.from('tbl_doctor').insert({
              'doctor_id': userId,
              'doctor_name': fullname.text,
              'doctor_email': email.text,
              'doctor_photo': photoUrl,
              'doctor_proof': proofUrl,
              'doctor_password': password.text,
              'place_id': selectedPlace,
              'doctor_address': address.text,
              'doctor_gender': selectedGender,
              'doctor_dob': dob.text,
              'doctor_contact': contact.text,
              'hospitaldepartment_id': selectedDoctorDepartment,
              'doctor_gid': gid
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account Created successfully')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up failed: $e')),
          );
          print('Sign up failed: $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload both image and proof')),
        );
      }
    }
  }

  Future<String?> getGID() async {
    final lastUser = await supabase
        .from('tbl_doctor')
        .select('doctor_gid')
        .order('doctor_gid', ascending: false)
        .limit(1)
        .maybeSingle();

    String newGID = "GDOC1001";
    if (lastUser != null && lastUser['doctor_gid'] != null) {
      String? lastId = lastUser['doctor_gid'] as String?;
      if (lastId != null) {
        int gidNumber = int.parse(lastId.replaceAll(RegExp(r'[^0-9]'), ''));
        int newNumber = gidNumber + 1;
        newGID = "GDOC$newNumber";
      }
    }
    print("newGID: $newGID");
    return newGID;
  }

  Future<String?> _uploadImage(String userId) async {
    try {
      final bucketName = 'doctordoc';
      final filePath = "$userId-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!,
          );
      final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<String?> _uploadproof(String userId) async {
    try {
      final fileName = 'Proof-doctor_$userId';
      await supabase.storage.from('doctordoc').uploadBinary(
            fileName,
            selectedFileBytes!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      final imageUrl = supabase.storage.from('doctordoc').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0277BD),
        title: Text(
          "Add Doctor",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter Doctor's Details",
                            style: TextStyle(
                              color: Color(0xFF0277BD),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 1300),
                                    child: GestureDetector(
                                      onTap: handleImageUpload,
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          image: pickedImage != null
                                              ? DecorationImage(
                                                  image: MemoryImage(
                                                      Uint8List.fromList(
                                                          pickedImage!.bytes!)),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: pickedImage == null
                                            ? Icon(Icons.camera_alt,
                                                color: Color.fromARGB(
                                                    255, 37, 99, 160),
                                                size: 50)
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              _buildInputField(
                                fullname,
                                'Full Name',
                                Icons.person,
                                validator: FormValidation.validateName,
                              ),
                              _buildInputField(
                                address,
                                'Address',
                                Icons.location_on,
                                validator: FormValidation.validateAddress,
                              ),
                              _buildInputField(
                                contact,
                                'Contact',
                                Icons.phone,
                                validator: FormValidation.validateContact,
                              ),
                              SizedBox(height: 14),
                              _buildGenderSelection(),
                              SizedBox(height: 14),
                              _buildInputField(
                                email,
                                'Email',
                                Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: FormValidation.validateEmail,
                              ),
                              _buildInputField(
                                password,
                                'Password',
                                Icons.lock,
                                obscureText: true,
                                validator: FormValidation.validatePassword,
                              ),
                              _buildInputField(
                                dob,
                                'Date of Birth',
                                Icons.calendar_today,
                                onTap: _pickDate,
                                validator: FormValidation.validateDropdown,
                              ),
                              SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  hintText: 'Department',
                                  prefixIcon: Icon(Icons.apartment),
                                  filled: true,
                                  fillColor: Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.elliptical(20, 20)),
                                  ),
                                ),
                                value: selectedDoctorDepartment,
                                validator: FormValidation.validateDropdown,
                                hint: Text("Select the Department"),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedDoctorDepartment = newValue;
                                  });
                                },
                                items: hospitaldepartmentlist
                                    .map((department) {
                                      return DropdownMenuItem<String>(
                                        value: department[
                                                'hospitaldepartment_id']
                                            .toString(),
                                        child: Text(department["tbl_department"]
                                            ['department_name']),
                                      );
                                    })
                                    .toList(),
                              ),
                              SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  hintText: 'District',
                                  prefixIcon: Icon(Icons.location_city),
                                  filled: true,
                                  fillColor: Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.elliptical(20, 20)),
                                  ),
                                ),
                                value: selectedDistrict,
                                validator: FormValidation.validateDropdown,
                                hint: Text("Select the District"),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedDistrict = newValue;
                                    fetchPlace(selectedDistrict!);
                                  });
                                },
                                items: districtlist.map((district) {
                                  return DropdownMenuItem<String>(
                                    value: district['district_id'].toString(),
                                    child: Text(district['district_name']),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  hintText: 'Place',
                                  prefixIcon: Icon(Icons.location_pin),
                                  filled: true,
                                  fillColor: Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.elliptical(20, 20)),
                                  ),
                                ),
                                value: selectedPlace,
                                validator: FormValidation.validateDropdown,
                                hint: Text("Select the Place"),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedPlace = newValue;
                                  });
                                },
                                items: placelist.map((place) {
                                  return DropdownMenuItem<String>(
                                    value: place['place_id'].toString(),
                                    child: Text(place['place_name']),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: fileController,
                                onTap: () {
                                  pickFile();
                                },
                                readOnly: true,
                                validator: FormValidation.validateDropdown,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.verified),
                                  hintText: _hintText,
                                  filled: true,
                                  fillColor: Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.elliptical(20, 20)),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                ),
                              ),
                              SizedBox(height: 40),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _signUp,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 15),
                                    backgroundColor:
                                        Color.fromARGB(255, 37, 99, 160),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 12,
                                    shadowColor:
                                        Color.fromARGB(255, 37, 99, 160),
                                  ),
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderSide: BorderSide.none),
          filled: true,
          fillColor: Color.fromARGB(255, 241, 246, 246),
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 241, 246, 246),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showGenderOptions = !_showGenderOptions;
              });
            },
            child: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 10),
                Text(
                  "Gender",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Icon(
                  _showGenderOptions
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
          if (_showGenderOptions)
            Column(
              children: [
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
                      activeColor: Color.fromARGB(255, 37, 99, 160),
                    ),
                    Text("Male"),
                    SizedBox(width: 20),
                    Radio<String>(
                      value: "Female",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                      activeColor: Color.fromARGB(255, 37, 99, 160),
                    ),
                    Text("Female"),
                    SizedBox(width: 20),
                    Radio<String>(
                      value: "Other",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                      activeColor: Color.fromARGB(255, 37, 99, 160),
                    ),
                    Text("Other"),
                  ],
                ),
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