import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/formvalidator.dart';
import 'package:user/login.dart';

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
  List<Map<String, dynamic>> userlist = [];

  final supabase = Supabase.instance.client;

  String? selectedGender;
  String? selectedDistrict;
  String? selectedPlace;
  File? _image;
  File? _proof;
  final ImagePicker _picker = ImagePicker();

  String _hintText = "Proof"; // Default hint text
  Color _iconColor = Color.fromARGB(255, 0, 0, 0); // Default icon color (blue)
  bool _showGenderOptions = false;
  final formkey = GlobalKey<FormState>();

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

  Future<void> _pickImage() async {
    // if (await Permission.photos.request().isGranted) {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    // } else {
    //   // Show a message to the user
    // }
  }

  Future<String?> getGID() async {
    final lastUser = await supabase
        .from('tbl_user')
        .select('user_gid')
        .order('user_gid', ascending: false)
        .maybeSingle().limit(1);

    if (lastUser == null || lastUser.isEmpty) {
      return "GID1001"; // Default value
    }

    String lastId = lastUser['user_gid'];
    int gidNumber = int.parse(lastId.replaceAll(RegExp(r'[^0-9]'), ''));
    int newNumber = gidNumber + 1;
    return "GID${newNumber}";
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
        print('Sign up error: No user returned.');
        return;
      }

      if (user == null) {
        print('Sign up error: $user');
      } else {
        final String userId = user.id;

        String? photoUrl;
        if (_image != null) {
          photoUrl = await _uploadImage(_image!, userId, 'photo');
        }
        if (photoUrl == null) {
          print("Image upload failed.");
          return; // Stop execution if image upload failed
        }

        print("URL: $photoUrl");

        String? gid = await getGID();

        await supabase.from('tbl_user').insert({
          'user_id': userId,
          'user_name': fullname.text,
          'user_email': email.text,
          'user_photo': photoUrl,
          'user_password': password.text,
          'place_id': selectedPlace,
          'user_address': address.text,
          'user_gender': selectedGender,
          'user_dob': dob.text,
          'user_contact': contact.text,
          'user_gid': gid
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

  Future<String?> _uploadImage(File image, String userId, String type) async {
    try {
      final fileName = '$type user_$userId';
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueGrey.shade50,
                const Color.fromARGB(255, 93, 133, 153)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.3, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 93, 133, 153),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 93, 133, 153),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 93, 133, 153),
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
                      colors: [
                        const Color.fromARGB(255, 93, 133, 153),
                        const Color.fromARGB(255, 93, 133, 153)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 93, 133, 153),
                        blurRadius: 15,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 150, left: 220),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade50,
                      image: _image != null
                          ? DecorationImage(image: FileImage(_image!))
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 93, 133, 153),
                          blurRadius: 50,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _image == null
                        ? Icon(Icons.camera_alt,
                            color: const Color.fromARGB(255, 93, 133, 153),
                            size: 50)
                        : null,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Form(
                  key: formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 370),
                      _buildInputField(fullname, 'Full Name', Icons.person,
                          validator: FormValidation.validateName),
                      _buildInputField(address, 'Address', Icons.location_on,
                          validator: FormValidation.validateAddress),
                      _buildInputField(contact, 'Contact', Icons.phone,
                          validator: FormValidation.validateContact,
                          keyboardType: TextInputType.phone),
                      SizedBox(height: 14),
                      _buildGenderSelection(),
                      SizedBox(height: 14),
                      _buildInputField(email, 'Email', Icons.email,
                          validator: FormValidation.validateEmail,
                          keyboardType: TextInputType.emailAddress),
                      _buildInputField(password, 'Password', Icons.lock,
                          validator: FormValidation.validatePassword,
                          obscureText: true),
                      _buildInputField(
                          dob, 'Date of Birth', Icons.calendar_today,
                          validator: FormValidation.validateDate,
                          onTap: _pickDate),
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
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.elliptical(20, 20)),
                          ),
                        ),
                        value: selectedDistrict, //initilizee cheyunuu
                        validator: (value) =>
                            FormValidation.validateDropdown(value),
                        // validator: (value) {
                        //   if (value == "" || value!.isEmpty) {
                        //     return "Enter the district name";
                        //   }
                        //   return null;
                        // },
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
                          prefixIcon: Icon(
                            Icons.location_pin,
                          ),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.elliptical(20, 20)),
                          ),
                        ),
                        value: selectedPlace, //initilizee cheyunuu
                        validator: (value) =>
                            FormValidation.validateDropdown(value),
                        // validator: (value) {
                        //   if (value == "" || value!.isEmpty) {
                        //     return "Enter the Place name";
                        //   }
                        //   return null;
                        // },
                        hint: Text("Select the Place"),
                        onChanged: (newValue) {
                          //button click cheyubool text box ill select cheythaa valuee"newValue"leeku store cheyunuu
                          setState(() {
                            selectedPlace = newValue;
                            print(selectedPlace);
                            //"newValue" ill ulla value "selectedDistrict"leeku store cheyunuu
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

                      SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              if (_image != null) {
                                _signUp();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Upload photo")));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            backgroundColor:
                                const Color.fromARGB(255, 93, 133, 153),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 12,
                            shadowColor: Color.fromARGB(255, 0, 0, 0),
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

                      // SizedBox(height: 20), // Add some space between the button and the text
                      Padding(
                        padding: const EdgeInsets.only(left: 50, top: 20),
                        child: Center(
                          child: Row(
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      const Color.fromARGB(255, 227, 235, 234),
                                  // decoration: TextDecoration.underline,
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
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 226, 232, 232),
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    String? Function(String?)? validator, // New parameter for validation
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator, // ✅ Apply validation function
        decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromARGB(255, 241, 246, 246),
          labelText: label,
          labelStyle: TextStyle(
            // color:Color.fromARGB(255, 0, 0, 0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(20, 20)),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 0, 0, 0),
              width: 0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(20, 20)),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 0, 0, 0),
              width: 0,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return FormField<String>(
      validator: FormValidation.validateGender, // Applying validation
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height:
                  _showGenderOptions ? 150 : 60, // Adjust height dynamically
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 241, 246, 246),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.elliptical(20, 20)),
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
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        Icon(_showGenderOptions
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  if (_showGenderOptions)
                    Column(
                      children: [
                        SizedBox(height: 10), // Add some spacing
                        Row(
                          children: [
                            Radio<String>(
                              value: "Male",
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                  state.didChange(
                                      value); // Update validation state
                                });
                              },
                              activeColor: Color.fromARGB(255, 0, 0, 0),
                            ),
                            Text("Male"),
                            SizedBox(width: 20),
                            Radio<String>(
                              value: "Female",
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                  state.didChange(value);
                                });
                              },
                              activeColor: Color.fromARGB(255, 0, 0, 0),
                            ),
                            Text("Female"),
                            SizedBox(width: 20),
                            Radio<String>(
                              value: "Other",
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value!;
                                  state.didChange(value);
                                });
                              },
                              activeColor: Color.fromARGB(255, 0, 0, 0),
                            ),
                            Text("Other"),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (state.hasError) // Display validation error message
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 5.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dob.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }
}
