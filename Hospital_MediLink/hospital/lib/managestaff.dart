import 'package:flutter/material.dart';

class HospitalStaffManagementPage extends StatefulWidget {
  const HospitalStaffManagementPage({super.key});

  @override
  _HospitalStaffManagementPageState createState() =>
      _HospitalStaffManagementPageState();
}

class Staff {
  String id;
  String name;
  String role;
  String department;
  String email;
  String phone;
  String schedule; // Staff schedule or shift info

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.schedule,
  });
}

class _HospitalStaffManagementPageState
    extends State<HospitalStaffManagementPage> {
  // Sample hospital staff list
  final List<Staff> _staffList = [
    Staff(
      id: "001",
      name: "Dr. John Doe",
      role: "Doctor",
      department: "Cardiology",
      email: "johndoe@example.com",
      phone: "123-456-7890",
      schedule: "Monday to Friday, 9:00 AM - 5:00 PM",
    ),
    Staff(
      id: "002",
      name: "Jane Smith",
      role: "Nurse",
      department: "Emergency",
      email: "janesmith@example.com",
      phone: "987-654-3210",
      schedule: "Monday to Saturday, 8:00 AM - 4:00 PM",
    ),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();

  void _addStaff() {
    setState(() {
      _staffList.add(Staff(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        name: _nameController.text,
        role: _roleController.text,
        department: _departmentController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        schedule: _scheduleController.text,
      ));
      _clearFields();
    });
  }

  void _editStaff(int index) {
    _nameController.text = _staffList[index].name;
    _roleController.text = _staffList[index].role;
    _departmentController.text = _staffList[index].department;
    _emailController.text = _staffList[index].email;
    _phoneController.text = _staffList[index].phone;
    _scheduleController.text = _staffList[index].schedule;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Staff Member"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_nameController, "Name"),
                _buildTextField(_roleController, "Role"),
                _buildTextField(_departmentController, "Department"),
                _buildTextField(_emailController, "Email"),
                _buildTextField(_phoneController, "Phone"),
                _buildTextField(_scheduleController, "Schedule"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _staffList[index] = Staff(
                    id: _staffList[index].id,
                    name: _nameController.text,
                    role: _roleController.text,
                    department: _departmentController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    schedule: _scheduleController.text,
                  );
                });
                Navigator.pop(context);
                _clearFields();
              },
              child: Text("Save Changes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearFields();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _deleteStaff(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Staff Member"),
          content: Text("Are you sure you want to delete this staff member?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _staffList.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    _nameController.clear();
    _roleController.clear();
    _departmentController.clear();
    _emailController.clear();
    _phoneController.clear();
    _scheduleController.clear();
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hospital Staff Management"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input fields for adding new staff
            _buildTextField(_nameController, "Name"),
            _buildTextField(_roleController, "Role"),
            _buildTextField(_departmentController, "Department"),
            _buildTextField(_emailController, "Email"),
            _buildTextField(_phoneController, "Phone"),
            _buildTextField(_scheduleController, "Schedule"),
            ElevatedButton(
              onPressed: _addStaff,
              child: Text("Add Staff"),
            ),
            SizedBox(height: 16),
            // ListView of existing staff members
            Expanded(
              child: ListView.builder(
                itemCount: _staffList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(_staffList[index].name),
                      subtitle: Text(
                          "${_staffList[index].role} | ${_staffList[index].department}\n${_staffList[index].phone}"),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editStaff(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteStaff(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
