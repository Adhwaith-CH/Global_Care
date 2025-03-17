import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // For animations
import 'package:supabase_flutter/supabase_flutter.dart';

class HospitalProfile extends StatefulWidget {
  const HospitalProfile({super.key});

  @override
  State<HospitalProfile> createState() => _HospitalProfileState();
}

class _HospitalProfileState extends State<HospitalProfile> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? hospitalData;
  String districtName = "N/A";
  String placeName = "N/A";

  @override
  void initState() {
    super.initState();
    fetchHospitalDetails();
  }

  Future<void> fetchHospitalDetails() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('tbl_hospital')
          .select()
          .eq('hospital_id', user.id)
          .single();

      if (response == null) {
        print("No hospital data found.");
        return;
      }

      setState(() {
        hospitalData = response;

        // Handling Null and Type Issues
        hospitalData!['hospital_name'] = hospitalData!['hospital_name'] ?? 'N/A';
        hospitalData!['hospital_email'] = hospitalData!['hospital_email'] ?? 'N/A';
        hospitalData!['hospital_contact'] = hospitalData!['hospital_contact'].toString() ?? 'N/A';
        hospitalData!['hospital_address'] = hospitalData!['hospital_address'] ?? 'N/A';
        hospitalData!['hospital_proof'] = hospitalData!['hospital_proof'] ?? '';
        hospitalData!['hospital_photo'] = hospitalData!['hospital_photo'] ?? '';

        // Convert district_id and place_id to String
        hospitalData!['district_id'] = hospitalData!['district_id']?.toString() ?? '';
        hospitalData!['place_id'] = hospitalData!['place_id']?.toString() ?? '';
      });

      fetchDistrictName(hospitalData!['district_id']);
      fetchPlaceName(hospitalData!['place_id']);
    } catch (e) {
      print('Error fetching hospital details: $e');
    }
  }

  Future<void> fetchDistrictName(String districtId) async {
    if (districtId.isEmpty) return;
    try {
      final response = await supabase
          .from('tbl_district')
          .select('district_name')
          .eq('district_id', districtId)
          .maybeSingle();

      setState(() {
        districtName = response?['district_name'] ?? 'N/A';
      });
    } catch (e) {
      print('Error fetching district name: $e');
    }
  }

  Future<void> fetchPlaceName(String placeId) async {
    if (placeId.isEmpty) return;
    try {
      final response = await supabase
          .from('tbl_place')
          .select('place_name')
          .eq('place_id', placeId)
          .maybeSingle();

      setState(() {
        placeName = response?['place_name'] ?? 'N/A';
      });
    } catch (e) {
      print('Error fetching place name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text('Hospital Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF0277BD),
        elevation: 4,
      ),
      body: hospitalData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sidebar Profile Section with Gradient
                  Expanded(
                    flex: 1,
                    child: FadeInLeft( // Animated Sidebar
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0277BD), Color(0xFF1976D2)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: hospitalData!['hospital_photo']!.isNotEmpty
                                  ? NetworkImage(hospitalData!['hospital_photo'])
                                  : AssetImage('assets/default_hospital.png') as ImageProvider,
                            ),
                            SizedBox(height: 15),
                            Text(
                              hospitalData!['hospital_name'],
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5),
                            Text(
                              hospitalData!['hospital_email'],
                              style: TextStyle(fontSize: 16, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to edit profile page (to be implemented)
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF0277BD),
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 4,
                              ),
                              child: Text('Edit Profile', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 20),

                  // Right Content Section with Animated Cards
                  Expanded(
                    flex: 2,
                    child: FadeInRight( // Animated Details Section
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildDetailRow(Icons.phone, 'Contact', hospitalData!['hospital_contact']),
                              buildDetailRow(Icons.location_on, 'Address', hospitalData!['hospital_address']),
                              buildDetailRow(Icons.location_city, 'District', districtName),
                              buildDetailRow(Icons.place, 'Place', placeName),
                              buildDetailRow(Icons.lock, 'Password', '********'),
                              buildDetailRow(Icons.file_copy, 'Proof Document', hospitalData!['hospital_proof']!.isNotEmpty ? 'Uploaded' : 'Not Uploaded'),
                              SizedBox(height: 20),

                              // Portrait-Style Proof Image
                              hospitalData!['hospital_proof']!.isNotEmpty
                                  ? Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          hospitalData!['hospital_proof'],
                                          height: 300, // Portrait style
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'No Proof Uploaded',
                                        style: TextStyle(color: Colors.red, fontSize: 16),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Custom Widget for Profile Details
  Widget buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF0277BD), size: 28),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
