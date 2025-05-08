// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class InitialController extends GetxController {
  final Location _location = Location();
  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    _initLocationService();
  }

  void _initLocationService() async {
    bool permissionGranted = await requestLocationPermissions();
    if (!permissionGranted) {
      print('Location permissions not granted');
      return;
    }

    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }
    _location.changeSettings(accuracy: LocationAccuracy.high);


    // get location periodically whatever you set a min
    _timer = Timer.periodic(Duration(minutes: 1), (timer) async {
      try {
        LocationData locationData = await _location.getLocation();
        double lat = locationData.latitude!;
        double lng = locationData.longitude!;
        print('-----Lat: $lat, Lng: $lng------');

        _sendLocationToApi(lat, lng);
      } catch (e) {
        print('Failed to fetch location: $e');
      }
    });

    try {
      LocationData locationData = await _location.getLocation();
      double lat = locationData.latitude!;
      double lng = locationData.longitude!;
      print('***********Initial Location - Lat: $lat, Lng: $lng');

      _sendLocationToApi(lat, lng);
    } catch (e) {
      print('**************Failed to fetch initial location: $e');
    }
  }

  void _sendLocationToApi(double lat, double lng) async {
    final url = Uri.parse(
      'https://demo.mannlowe.com/api/method/fi_support.api.engineer.locate_current_location',
    );

    final body = {
      'engineer_id': 'sudeep.kulkarni@mannlowe.com',
      'location': 'LatLng(lat: $lat, lng: $lng)',
    };

    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        print('****Location sent successfully!****');
        print('Response: ${response.body}');
      } else {
        print(
          '******Failed to send location*******. Status: ${response.statusCode}',
        );
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('********Error sending location********: $e');
    }
  }

    Future<bool> requestLocationPermissions() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      var backgroundStatus = await Permission.locationAlways.request();
      if (backgroundStatus.isGranted) {
        return true;
      }
    }

    return false;
  }


  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}



//  bool _serviceEnabled = await _location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await _location.requestService();
//       if (!_serviceEnabled) return;
//     }

//     PermissionStatus _permissionGranted = await _location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await _location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) return;
//     }
















// class LocationController extends GetxController {
//   final Location _location = Location();
//   late StreamSubscription<LocationData> _locationSubscription;
//   late Timer _timer; // Timer to trigger API call every 15 minutes
//   double? _lastLat;
//   double? _lastLng;

//   @override
//   void onInit() {
//     super.onInit();
//     _initLocationService();
//   }

//   void _initLocationService() async {
//     bool _serviceEnabled = await _location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await _location.requestService();
//       if (!_serviceEnabled) return;
//     }

//     PermissionStatus _permissionGranted = await _location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await _location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) return;
//     }

//     _location.changeSettings(
//       interval: 1000, // Collect location every 1 second, but only send every 15 mins
//       accuracy: LocationAccuracy.high,
//     );

//     // Listen for location changes
//     _locationSubscription = _location.onLocationChanged.listen((locationData) {
//       double lat = locationData.latitude!;
//       double lng = locationData.longitude!;
//       print('Latitude: $lat, Longitude: $lng');

//       // Save the latest location (for use later)
//       _lastLat = lat;
//       _lastLng = lng;
//     });

//     // Set up the timer to send the location to the API every 15 minutes (900 seconds)
//     _timer = Timer.periodic(Duration(minutes: 1), (timer) {
//       if (_lastLat != null && _lastLng != null) {
//         _sendLocationToApi(_lastLat!, _lastLng!);
//       }
//     });
//   }

//   void _sendLocationToApi(double lat, double lng) async {
//     final url = Uri.parse('https://demo.mannlowe.com/api/method/fi_support.api.engineer.locate_current_location');

//     final body = {
//       'engineer_id': 'sudeep.kulkarni@mannlowe.com',
//       'location': 'LatLng(lat: $lat, lng: $lng)'
//     };

//     try {
//       final response = await http.post(url, body: body);

//       if (response.statusCode == 200) {
//         print('Location sent successfully!');
//         print('Response: ${response.body}');
//       } else {
//         print('Failed to send location. Status: ${response.statusCode}');
//         print('Response: ${response.body}');
//       }
//     } catch (e) {
//       print('Error sending location: $e');
//     }
//   }

//   @override
//   void onClose() {
//     _locationSubscription.cancel();
//     _timer.cancel(); // Cancel the timer when the controller is closed
//     super.onClose();
//   }
// }
