import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../utils/university.dart';

class UniversityMapScreen extends StatelessWidget {
  Future<List<University>> _loadUniversityData() async {
    return await loadUniversityData();
  }

  void _showUniversityDialog(BuildContext context, String universityName, LatLng location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UniversityInfoDialog(
          universityName: universityName,
          location: location,
          firestore: FirebaseFirestore.instance,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<University>>(
      future: loadUniversityData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<University> universities = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: const Text('University Map'),
              backgroundColor: Color(0xFF0DF099),
            ),
            body: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(43, 22),
                initialZoom: 6,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: universities
                      .map((university) => Marker(
                    width: 40.0,
                    height: 40.0,
                    point: university.location,
                    child: GestureDetector(
                      child: const Icon(
                        Icons.school,
                        color: Colors.blue,
                      ),
                      onTap: () {
                        _showUniversityDialog(context, university.name, university.location);
                      },
                    )
                  ))
                      .toList(),
                ),
              ],
            ),
          );
        }
      },
    );
  }


}


class UniversityInfoDialog extends StatelessWidget {
  final String universityName;
  final LatLng location;
  final FirebaseFirestore firestore;

  UniversityInfoDialog({
    required this.universityName,
    required this.location,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('University Information'),
      content: Column(
        children: [
          Text('Name: $universityName'),
          Text('Location: ${location.latitude}, ${location.longitude}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _saveUniversityInfo(universityName, location);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _saveUniversityInfo(String universityName, LatLng location) async {
    try {
      DocumentReference universityRef = await firestore.collection('universities').add({
        'name': universityName,
        'location': GeoPoint(location.latitude, location.longitude),
      });
      String universityId = universityRef.id;

      await firestore.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({
        'education': universityId,
      });
      print('University information saved successfully!');
    } catch (e) {
      print('Error saving university information: $e');
    }
  }
}
