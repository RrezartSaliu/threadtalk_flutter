import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/location_map_view.dart';
import '../utils/menu_overlay.dart';
import '../utils/threadtalk_bar.dart';
import 'package:latlong2/latlong.dart';

class ProfilePage extends StatefulWidget{
  final String userId;
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>{
  bool isMenuOpen = false;
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserData();
  }

  Future<DocumentSnapshot<Object?>?> getUniversityData(String? universityId) async {
    try {
      if (universityId == null) {
        return null;
      }

      return await FirebaseFirestore.instance.collection('universities').doc(universityId).get();
    } catch (e) {
      print('Error fetching university information: $e');
      return null;
    }
  }

  Future<void> _getUserData() async {
    DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

    Map<String, dynamic>? userDataInner = userDocSnapshot.data() as Map<String, dynamic>?;

    if (userDataInner != null) {
      setState(() {
        userData = userDataInner;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                        icon: const Icon(Icons.person, size: 60),
                        onPressed: () {
                        },
                      ),
                      const SizedBox(width: 10,)
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userData?['displayName'] ?? 'No display name',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'BIO: '+(userData?['bio'] ?? 'No bio yet'),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Birthdate: ' + (userData?['birthDate'] != null
                        ? DateFormat('dd/MM/yyyy').format((userData?['birthDate'] as Timestamp).toDate())
                        : 'No birthdate yet'),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FutureBuilder<DocumentSnapshot<Object?>?>(
                        future:getUniversityData(userData['education']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            DocumentSnapshot<Object?>? universitySnapshot = snapshot.data;

                            String universityName = universitySnapshot?['name'] ?? 'Unknown University';

                            return Text(
                              'Education: $universityName',
                              style: const TextStyle(fontSize: 20),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: (){
                      //TODO
                      if(userData['showLocation'] == false){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User\'s location is private'),
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
                  ElevatedButton(
                    onPressed: () {
                      //TODO
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFAFBE9)),
                    ),
                    child: Text('Friends (${userData?['friends']?.length.toString() ?? '0'})', style: const TextStyle(color: Colors.black),),
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