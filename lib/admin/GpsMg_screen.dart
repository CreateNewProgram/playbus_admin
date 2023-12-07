import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/drawerMg.dart';

class GPSScreen extends StatefulWidget {
  @override
  _GPSScreenState createState() => _GPSScreenState();
}

class _GPSScreenState extends State<GPSScreen> {
  Position? _currentPosition;
  late Timer _timer;
  late StreamSubscription<DocumentSnapshot> _subscription;
  double _zoomLevel = 18.9;
  late GoogleMapController _mapController;
  bool isGpsConnected = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _subscribeToLocationChanges();
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: MyDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨기기
        title: Text('현재 버스 위치'),
        centerTitle: true,
        backgroundColor: Colors.grey[700],
      ),
      body: Stack(
        children: [
          _buildMap(),
          Positioned(
            left: 8,
            bottom: 22,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _goToCurrentLocation,
              child: Icon(Icons.my_location),
            ),
          ),
          Positioned(
            right: 16,
            top: 11,
            child: ElevatedButton(
              onPressed: _toggleGpsConnection,
              style: ElevatedButton.styleFrom(primary: Colors.white),
              child: Text(
                isGpsConnected ? 'GPS 끊기' : 'GPS 연결',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_currentPosition != null) {
      final initialCameraPosition = CameraPosition(
        target: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        zoom: _zoomLevel,
      );
      return GoogleMap(
        initialCameraPosition: initialCameraPosition,
        onMapCreated: (controller) {
          _mapController = controller;
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              _zoomLevel,
            ),
          );
        },
        markers: _buildMarkers(),
        onCameraMove: (position) {
          _zoomLevel = position.zoom;
        },
        onCameraIdle: () {
          _updateMapCamera();
        },
      );
    } else {
      return isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(child: Text('현재 GPS가 꺼졌습니다.'));
    }
  }

  void _updateMapCamera() async {
    if (_currentPosition != null && _mapController != null) {
      final LatLng currentLatLng = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      final screenCoordinate = await _mapController.getScreenCoordinate(currentLatLng);
      final updatedLatLng = await _mapController.getLatLng(screenCoordinate);

      if (updatedLatLng != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLng(updatedLatLng),
        );
      }
    }
  }

  Set<Marker> _buildMarkers() {
    if (_currentPosition != null) {
      return Set<Marker>.from([
        Marker(
          markerId: MarkerId('location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
        ),
      ]);
    }
    return {};
  }

  void _startLocationUpdates() {
    const duration = Duration(seconds: 5);
    _timer = Timer.periodic(duration, (Timer timer) {
      _getLocation();
    });
  }

  void _getLocation() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      Position? position = await Geolocator.getCurrentPosition();
      setState(() {
        isLoading = false;
        if (position != null) {
          _currentPosition = position;
          _saveLocationToFirestore(_currentPosition!);
          print(
              '현재 위치: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
        }
      });
    }
  }

  void _saveLocationToFirestore(Position position) {
    FirebaseFirestore.instance
        .collection('bus_locations')
        .doc('current_location')
        .set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'altitude': position.altitude,
      'timestamp': position.timestamp?.millisecondsSinceEpoch,
      'accuracy': position.accuracy,
      'speed': position.speed,
      'speedAccuracy': position.speedAccuracy,
      'heading': position.heading,
    });
  }

  void _subscribeToLocationChanges() {
    _subscription = FirebaseFirestore.instance
        .collection('bus_locations')
        .doc('current_location')
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          double latitude = snapshot['latitude'];
          double longitude = snapshot['longitude'];
          double altitude = snapshot['altitude'];
          int timestamp = snapshot['timestamp'];
          double accuracy = snapshot['accuracy'];
          double speed = snapshot['speed'];
          double speedAccuracy = snapshot['speedAccuracy'];
          double heading = snapshot['heading'];
          _currentPosition = Position(
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
            accuracy: accuracy,
            speed: speed,
            speedAccuracy: speedAccuracy,
            heading: heading,
          );
        });
      }
    });
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition != null && _mapController != null) {
      final LatLng currentLatLng = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLng(currentLatLng),
      );
    }
  }

  void _toggleGpsConnection() {
    if (isGpsConnected) {
      _stopLocationUpdates();
      setState(() {
        _currentPosition = null;
      });
    } else {
      _startLocationUpdates();
      _getLocation();
    }

    setState(() {
      isGpsConnected = !isGpsConnected;
    });
  }

  void _stopLocationUpdates() {
    _timer.cancel();
  }
}
