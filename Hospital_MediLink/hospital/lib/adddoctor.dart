import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

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

  final String _hintText = "Proof"; // Default hint text
  bool _showGenderOptions = false;

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
      allowMultiple: false, // Only single file upload
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
      final response = await supabase.from('tbl_hospitaldepartment').select("*, tbl_department(*)");
      setState(() {
        hospitaldepartmentlist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching hospitaldepartment: $e');
    }
  }

  Future<void> _signUp() async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email.text,
        password: password.text,
      );

      // if (response.user != null) {
      //   String fullName = fullname.text;
      //   String firstName = fullName.split(' ').first;
      //   await supabase.auth.updateUser(UserAttributes(
      //     data: {'display_name': firstName},
      //   ));
      // }

      final User? user = response.user;

      if (user == null) {
        print('Sign up error: $user');
      } else {
        final String userId = user.id;

        String? photoUrl;
        if (pickedImage != null) {
          photoUrl = await _uploadImage(userId,);
        }

        String? proofUrl;
        if (selectedFileBytes != null) {
          proofUrl = await _uploadproof(userId);
        }

        print("URL: $proofUrl");
        print("URL: $photoUrl");

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
          'hospitaldepartment_id':selectedDoctorDepartment,
        });
        

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created successfully')),
        );
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Loginpage(),
        //   ),
        // );
      }
    } catch (e) {
      print('Sign up failed: $e');
    }
  }

  Future<String?> _uploadImage(String userId) async {
    try {
      final bucketName = 'doctordoc'; // Replace with your bucket name
      final filePath = "$userId-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
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
      final imageUrl =
          supabase.storage.from('doctordoc').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  final _formKey = GlobalKey<FormState>();

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
                              // Left Section: Form Inputs
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title Section
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 1300),
                                                child: GestureDetector(
                                                  onTap: handleImageUpload,
                                                  child: AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blue.shade50,
                                                      image: pickedImage != null
                                                          ? DecorationImage(
                                                              image: MemoryImage(
                                                              Uint8List.fromList(
                                                                  pickedImage!
                                                                      .bytes!),
                                                            ))
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
                                          _buildInputField(fullname,
                                              'Full Name', Icons.person),
                                          _buildInputField(address, 'Address',
                                              Icons.location_on),
                                          _buildInputField(
                                              contact, 'Contact', Icons.phone),
                                          SizedBox(height: 14),
                                          _buildGenderSelection(),
                                          SizedBox(height: 14),
                                          _buildInputField(
                                              email, 'Email', Icons.email,
                                              keyboardType:
                                                  TextInputType.emailAddress),
                                          _buildInputField(
                                              password, 'Password', Icons.lock,
                                              obscureText: true),
                                          _buildInputField(dob, 'Date of Birth',
                                              Icons.calendar_today,
                                              onTap: _pickDate),
                                          SizedBox(height: 14),

                                           DropdownButtonFormField<String>(
                                            decoration: const InputDecoration(
                                              hintText: 'Department',
                                              prefixIcon: Icon(
                                                Icons.apartment,
                                              ),
                                              filled: true,
                                              fillColor: Color(0xFFF5F5F5),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        bottom:
                                                            Radius.elliptical(
                                                                20, 20)),
                                              ),
                                            ),
                                            value:
                                                selectedDoctorDepartment, //initilizee cheyunuu
                                            validator: (value) {
                                              if (value == "" ||
                                                  value!.isEmpty) {
                                                return "Enter the DoctorDepartment name";
                                              }
                                              return null;
                                            },
                                            hint: Text("Select the Department"),
                                            onChanged: (newValue) {
                                              //button click cheyubool text box ill select cheythaa valuee"newValue"leeku store cheyunuu
                                              setState(() {
                                                selectedDoctorDepartment =
                                                    newValue; //"newValue" ill ulla value "selectedDistrict"leeku store cheyunuu
                                                
                                              });
                                            },
                                            items: hospitaldepartmentlist.map((department) {
                                              return DropdownMenuItem<String>(
                                                value: department['hospitaldepartment_id']
                                                    .toString(),
                                                child: Text(
                                                    department["tbl_department"]['department_name']),
                                              );
                                            }).toList(),
                                          ),

                                          SizedBox(height: 14),

                                          DropdownButtonFormField<String>(
                                            decoration: const InputDecoration(
                                              hintText: 'District',
                                              prefixIcon: Icon(
                                                Icons.location_city,
                                              ),
                                              filled: true,
                                              fillColor: Color(0xFFF5F5F5),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        bottom:
                                                            Radius.elliptical(
                                                                20, 20)),
                                              ),
                                            ),
                                            value:
                                                selectedDistrict, //initilizee cheyunuu
                                            validator: (value) {
                                              if (value == "" ||
                                                  value!.isEmpty) {
                                                return "Enter the district name";
                                              }
                                              return null;
                                            },
                                            hint: Text("Select the District"),
                                            onChanged: (newValue) {
                                              //button click cheyubool text box ill select cheythaa valuee"newValue"leeku store cheyunuu
                                              setState(() {
                                                selectedDistrict =
                                                    newValue; //"newValue" ill ulla value "selectedDistrict"leeku store cheyunuu
                                                fetchPlace(selectedDistrict!);
                                              });
                                            },
                                            items: districtlist.map((district) {
                                              return DropdownMenuItem<String>(
                                                value: district['district_id']
                                                    .toString(),
                                                child: Text(
                                                    district['district_name']),
                                              );
                                            }).toList(),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          DropdownButtonFormField<String>(
                                            decoration: const InputDecoration(
                                              hintText: 'Place',
                                              prefixIcon: Icon(
                                                Icons.location_pin,
                                              ),
                                              filled: true,
                                              fillColor: Color(0xFFF5F5F5),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        bottom:
                                                            Radius.elliptical(
                                                                20, 20)),
                                              ),
                                            ),
                                            value:
                                                selectedPlace, //initilizee cheyunuu
                                            validator: (value) {
                                              if (value == "" ||
                                                  value!.isEmpty) {
                                                return "Enter the Place name";
                                              }
                                              return null;
                                            },
                                            hint: Text("Select the Place"),
                                            onChanged: (newValue) {
                                              //button click cheyubool text box ill select cheythaa valuee"newValue"leeku store cheyunuu
                                              setState(() {
                                                selectedPlace =
                                                    newValue; //"newValue" ill ulla value "selectedDistrict"leeku store cheyunuu
                                              });
                                            },
                                            items: placelist.map((place) {
                                              return DropdownMenuItem<String>(
                                                value: place['place_id']
                                                    .toString(),
                                                child:
                                                    Text(place['place_name']),
                                              );
                                            }).toList(),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          TextFormField(
                                            controller: fileController,
                                            onTap: () {
                                              pickFile();
                                            },
                                            readOnly:
                                                true, // Prevent manual text input
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.verified,
                                              ), // Dynamic icon color
                                              hintText:
                                                  _hintText, // Dynamic hintText
                                              filled: true,
                                              fillColor: Color(0xFFF5F5F5),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        bottom:
                                                            Radius.elliptical(
                                                                20, 20)),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 15),
                                            ),
                                          ),
                                          SizedBox(height: 40),
                                          Center(
                                            child: ElevatedButton(
                                              onPressed: _signUp,
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 40,
                                                    vertical: 15),
                                                backgroundColor: Color.fromARGB(
                                                    255, 37, 99, 160),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                elevation: 12,
                                                shadowColor: Color.fromARGB(
                                                    255, 37, 99, 160),
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
                                          // Right Section: Image Upload
                                          SizedBox(width: 20),
                                        ],
                                      ),
                                    ]),
                              ),
                            ]),
                      ))))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0277BD),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Action for the FAB
        },
      ),
    );
  }

  // Custom Input Field Widget with Floating Labels
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
          border: OutlineInputBorder(borderSide: BorderSide.none),
          filled: true,
          fillColor: Color.fromARGB(255, 241, 246, 246),
          labelText: label,
          labelStyle: TextStyle(
            // color: Color.fromARGB(255, 37, 99, 160),
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

        //border: Border.all(width: 0),
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
                Icon(
                  Icons.person,
                ),
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
