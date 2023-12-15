import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  final LatLng location;
  final bool showLocation;
  LocationScreen({required this.location, required this.showLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Screen'),
        backgroundColor: Color(0xFF0DF099),
      ),
      body: LocationMapView(
        showLocation: showLocation,
        location: location,
      ),
    );
  }
}


class LocationMapView extends StatelessWidget {
  final bool showLocation;
  final LatLng location;

  LocationMapView({required this.showLocation, required this.location});

  @override
  Widget build(BuildContext context) {
    if (showLocation) {
      LatLng userLocation = location;

      return FlutterMap(
        options: MapOptions(
          initialCenter: userLocation,
          initialZoom: 7.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: userLocation,
                child: const Icon(
                  Icons.location_on,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is not available'),
        ),
      );
      return const SizedBox.shrink();
    }
  }
}
