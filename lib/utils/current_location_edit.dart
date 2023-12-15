import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

Future<void> showLocationOptions(BuildContext context, User? user) async {
  bool showLocation = true;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Location Options'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                CheckboxListTile(
                  title: const Text('Show Current Location'),
                  value: showLocation,
                  onChanged: (bool? value) {
                    setState(() {
                      showLocation = value ?? false;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await updateUserLocation(showLocation, user, context);
              Navigator.pushNamed(context, '/profile');
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


Future<void> updateUserLocation (bool showLocation, User? user, BuildContext context) async {
  try {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user?.uid);

    Position position = await getCurrentLocation();

    await userDocRef.update({
      'showLocation': showLocation,
      'lat': position.latitude,
      'lng': position.longitude,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location preferences updated successfully'),
      ),
    );
  } catch (error) {
    print('Error updating location preferences: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error updating location preferences'),
      ),
    );
  }
}

Future<Position> getCurrentLocation() async {
  try {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return position;
  } catch (error) {
    print('Error getting current location: $error');
    throw error;
  }
}
