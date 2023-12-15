import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:threadtalk191521/screens/university_map_screen.dart';
import 'package:threadtalk191521/utils/location_map_view.dart';
import 'package:threadtalk191521/utils/menu_overlay.dart';
import 'package:threadtalk191521/utils/threadtalk_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import '../utils/current_location_edit.dart';


class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);


  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage>{
  bool isMenuOpen = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user;
  late DocumentSnapshot userDoc;
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    user = _auth.currentUser;
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();

    Map<String, dynamic>? userDataInner = userDocSnapshot.data() as Map<String, dynamic>?;

    if (userDataInner != null) {
      setState(() {
        userData = userDataInner;
      });
    }
  }

  Future<void> updateBio(String newBio) async {
    try {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user?.uid);
      await userDocRef.update({
        'bio': newBio,
      });

      setState(() {
        userData?['bio'] = newBio;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bio updated successfully'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating bio'),
        ),
      );
    }
  }

  Future<String> getUniversityName(String universityId) async {
    try {
      DocumentSnapshot universitySnapshot =
      await FirebaseFirestore.instance.collection('universities').doc(universityId).get();

      if (universitySnapshot.exists) {
        return universitySnapshot['name'];
      } else {
        return 'Unknown University';
      }
    } catch (e) {
      return 'Unknown University';
    }
  }

  Future<void> _showDatePickerOverlay() async {
    DateTime selectedDate = userData['birthDate'] ?? DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      await updateBirthDate(picked);
    }
  }

  Future<void> updateBirthDate(DateTime newDate) async {
    try {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user?.uid);
      await userDocRef.update({
        'birthDate': newDate,
      });

      setState(() {
        userData['birthDate'] = newDate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Birthdate updated successfully'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating birthdate'),
        ),
      );
    }
  }


  Future<void> _showEditBioOverlay() async {
    TextEditingController _bioController = TextEditingController();
    _bioController.text = userData['bio'] ?? '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Bio'),
          content: TextField(
            controller: _bioController,
            decoration: const InputDecoration(
              hintText: 'Enter your new bio',
            ),
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
                await updateBio(_bioController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Upload from Gallery'),
              onTap: () {
                _uploadFromGallery();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                _takePhoto();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Reference storageReference = FirebaseStorage.instance.ref().child('user_profile_photos/${user?.uid}.jpg');
      UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));

      await uploadTask.whenComplete(() async {
        String downloadURL = await storageReference.getDownloadURL();

        await _updateProfilePictureURL(downloadURL);
      });
    }
  }

  Future<void> _updateProfilePictureURL(String downloadURL) async {
    try {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user?.uid);
      await userDocRef.update({
        'profilePhoto': downloadURL,
      });

      setState(() {
        userData['profilePhoto'] = downloadURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating profile picture'),
        ),
      );
    }
  }


  Future<void> _takePhoto() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final ImagePicker imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image != null) {
      await _uploadPhoto(File(image.path));
    }
  }

  Future<void> _uploadPhoto(File photo) async {
    Reference storageReference = FirebaseStorage.instance.ref().child('user_profile_photos/${user?.uid}.jpg');
    UploadTask uploadTask = storageReference.putFile(photo);

    await uploadTask.whenComplete(() async {
      String downloadURL = await storageReference.getDownloadURL();

      await _updateProfilePictureURL(downloadURL);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: ThreadTalkBar(toggleMenu: () {
        setState(() {
          isMenuOpen = !isMenuOpen;
        });
      }
      ),
      body: Stack(
        children: [

            Positioned(
              left: 20.0,
              right: 20.0,
              top: 15.0,
              bottom: 15.0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2.0, color: Colors.black),
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (userData['profilePhoto'] != null && userData['profilePhoto'] != '')
                            ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(userData['profilePhoto']),
                        )
                            : IconButton(
                          icon: const Icon(Icons.person, size: 40),
                          onPressed: () {
                          },
                        ),
                        (userData['profilePhoto'] != null && userData['profilePhoto'] != '')
                            ?
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 30),
                          onPressed: () {
                            _showAddPhotoOptions();
                          },
                        ): IconButton(onPressed: (){_showAddPhotoOptions();}, icon: Icon(Icons.add, size: 30,))
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      userData?['displayName'] ?? 'No display name',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'BIO: '+(userData?['bio'] ?? 'No bio yet'),
                          style: const TextStyle(fontSize: 20),
                        ),
                        GestureDetector(
                          onTap: (){
                            _showEditBioOverlay();
                          },
                          child: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Birthdate: ' + (userData?['birthDate'] != null
                              ? DateFormat('dd/MM/yyyy').format((userData?['birthDate'] as Timestamp).toDate())
                              : 'No birthdate yet'),
                          style: const TextStyle(fontSize: 20),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showDatePickerOverlay();
                          },
                          child: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FutureBuilder<String>(
                          future: getUniversityName(userData?['education'] ?? 'Unknown University'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                'Education: ${snapshot.data ?? 'Unknown University'}',
                                style: const TextStyle(fontSize: 20),
                              );
                            }
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UniversityMapScreen(),
                              ),
                            );
                          },
                          child: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: (){
                              //TODO
                              if(userData['showLocation'] == false){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Location is not available'),
                                  ),
                                );
                              }
                              else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      LocationScreen(location: LatLng(
                                          userData['lat'], userData['lng']),
                                        showLocation: userData['showLocation'],)),
                                );
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFAFBE9)),
                            ),
                            child: Text('Check current location', style: TextStyle(color: Colors.black),),
                        ),
                        GestureDetector(
                          onTap: () {
                            //TODO
                            showLocationOptions(context, user);
                          },
                          child: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        //TODO
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFAFBE9)),
                      ),
                      child: Text('Friends (${userData['friends']?.length.toString() ?? '0'})', style: const TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              ),
            ),

          if(isMenuOpen)
          MenuOverlay(
            toggleMenu: () {
              setState(() {
                isMenuOpen = !isMenuOpen;
              });
            },
          )
          
        ],
      ),
    );

  }
}
