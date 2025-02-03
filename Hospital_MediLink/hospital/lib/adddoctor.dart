import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Adddoctor extends StatefulWidget {
  const Adddoctor({super.key});

  @override
  State<Adddoctor> createState() => _AdddoctorState();
}

class _AdddoctorState extends State<Adddoctor> {
   final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  File? _image;

  // Function to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitDoctorDetails() {
    if (_formKey.currentState!.validate()) {
      // Handle the form submission logic
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Doctor details have been successfully added."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0277BD),
        title: Text(
          "Add Doctor",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,color: Colors.white),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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

                          // Name Input Field
                          _buildInputField(_nameController, 'Full Name', Icons.person),
                          SizedBox(height: 20),
                          
                          // Specialization Input Field
                          _buildInputField(_specializationController, 'Specialization', Icons.medical_services),
                          SizedBox(height: 20),
                          
                          // Contact Number Input Field
                          _buildInputField(_contactController, 'Contact Number', Icons.phone),
                          SizedBox(height: 20),
                          
                          // Email Input Field
                          _buildInputField(_emailController, 'Email', Icons.email),
                          SizedBox(height: 20),
                          
                          // Years of Experience Input Field
                          _buildInputField(_experienceController, 'Years of Experience', Icons.access_time),
                          SizedBox(height: 40),

                          // Submit Button with Hover Effect
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitDoctorDetails,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                backgroundColor: Color(0xFF0277BD), // Blue Button Color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 10,
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right Section: Image Upload
                    SizedBox(width: 20),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: _image == null
                          ? GestureDetector(
                              onTap: _pickImage,
                              child: Icon(
                                Icons.add_a_photo,
                                color: Color(0xFF0277BD),
                                size: 50,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
    String hintText,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF0277BD)),
        labelText: hintText,
        labelStyle: TextStyle(color: Color(0xFF0277BD)),
        filled: true,
        fillColor: Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF0277BD), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hintText is required';
        }
        return null;
      },
    );
  }
}