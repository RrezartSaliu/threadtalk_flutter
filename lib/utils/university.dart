import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class University {
  final String name;
  final LatLng location;

  University({required this.name, required this.location});
}

Future<List<University>> loadUniversityData() async {
  String csvFileURL = 'balkan_universities.csv';
  List<University> universities = [];

  try {
    await printAllFilesInStorage();
    final response = await firebase_storage.FirebaseStorage.instance
        .ref(csvFileURL)
        .getData();

    String csvString = String.fromCharCodes(response!);

    List<List<String>> csvTable = CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(csvString);
    print(csvTable.length);


    universities = csvTable
        .skip(1)
        .map((row) {
      print('CSV Row: $row');
      List<String> columns = row[0].split('\t');
      String name = columns[2].isEmpty ? 'blank name' : utf8.decode(columns[2].codeUnits);
      double latitude = 0.0;
      double longitude = 0.0;

      try {
        latitude = double.parse(columns[0].isNotEmpty ? columns[0].toString() : '0.0') ?? 0.0;
        longitude = double.parse(columns[1].isNotEmpty ? columns[1].toString() : '0.0') ?? 0.0;
      } catch (e) {
        print('Error parsing latitude or longitude for $name: $e');
      }

      return University(
        name: name,
        location: LatLng(latitude, longitude),
      );
    })
        .toList();



  } catch (error) {
    print('Error loading university data: $error');
  }

  print(universities[12].location.latitude);
  return universities;
}

Future<void> printAllFilesInStorage() async {
  try {
    final firebase_storage.ListResult result = await firebase_storage.FirebaseStorage.instance.ref().listAll();
    print('Files in Storage:');
    for (final item in result.items) {
      print('File: ${item.fullPath}');
    }
  } catch (error) {
    print('Error listing files in storage: $error');
  }
}