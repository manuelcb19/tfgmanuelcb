import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class GeolocAdmin {

  final CollectionReference localizacionCollection =
  FirebaseFirestore.instance.collection('localizacion');



  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Position> registrarCambiosLoc() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    try {
      Position position = await Geolocator.getCurrentPosition();
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
      return position;
    } catch (e) {
      print('Error al obtener la posición: $e');
      throw Exception('Error al obtener la posición');
    }
  }
  Future<void> agregarUbicacionEnFirebase(GeoPoint ubicacion) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await localizacionCollection.doc(uid).set({
        'local': ubicacion,
        'idUser': uid,
      });
    } catch (e) {
      print('Error al agregar la ubicación en Firebase: $e');
      throw Exception('Error al agregar la ubicación en Firebase');
    }
  }

  Future<List<String>> obtenerUsuariosEnRango() async {
    List<String> usersInRange = [];

    try {

      Position userPosition = await Geolocator.getCurrentPosition();

      double radius = 5.0;
      GeoPoint center = GeoPoint(userPosition.latitude, userPosition.longitude);

      double latOffset = radius / 110.574;
      double lonOffset = radius / (111.32 * cos(center.latitude * pi / 180));

      QuerySnapshot result = await localizacionCollection
          .where('local', isGreaterThan: GeoPoint(center.latitude - latOffset, center.longitude - lonOffset))
          .where('local', isLessThan: GeoPoint(center.latitude + latOffset, center.longitude + lonOffset))
          .get();

      result.docs.forEach((doc) {
        usersInRange.add(doc['idUser']);
      });
    } catch (e) {
      print('Error al obtener usuarios en rango: $e');
    }

    return usersInRange;
  }
}