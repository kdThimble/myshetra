// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Pages/AuthPage.dart';
import 'package:myshetra/Pages/Editprofile.dart';
import 'package:myshetra/Pages/HomePage.dart';
import 'package:myshetra/Pages/ManualPage.dart';
import 'package:myshetra/Pages/Oranisation.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:get/get.dart';

import 'package:myshetra/helpers/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MapPage extends StatefulWidget {
  final bool? isRedirected;
  final List<dynamic>? representatives;
  final bool? ishomescreen;
  const MapPage(
      {Key? key,
      this.isRedirected = false,
      this.ishomescreen = false,
      this.representatives = const []})
      : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final location.Location _locationController = location.Location();
  final authService = Get.find<AuthService>();
  double? latitude;
  double? longitude;
  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  final List<dynamic>? representatives123 = [];
  final location.Location _locationService = location.Location();
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> refreshAuthToken() async {
    print("swxaL:${authService.refreshToken}");
    print("tokem:${authService.token}");

    var headers = {
      'Refresh-Token':
          '${authService.refreshToken}', // Authorization header with the token
    };

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/auth/refreshToken'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();
    var jsonData = json.decode(responseBody);
    print("Response code: $jsonData");

    // Get.find<LoadingController>().stopLoading();

    if (response.statusCode == 200) {
      // final authResponse = AuthResponse.fromJson(jsonData['data']);
      final token = jsonData['data']['token'];
      print(responseBody);
      if (token != null) {
        // Save the tokens to secure storage or a state management solution
        // Provider.of<AuthProvider>(context, listen: false)
        //     .setAuthResponse(authResponse);
        Get.find<AuthService>().saveToken(token);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        print("authResponse.token:$token");
        await prefs.setString('token', token);
        print("getxlocation");
        print(locationController.latitudeString.value);
        // if (locationController.latitudeString.isNotEmpty && locationController.longitudeString.isNotEmpty) {
        //   fetchRepresentatives123(locationController.latitudeString.value, locationController.longitudeString.value);
        // }
      } else {
        // Get.snackbar('Error', 'Failed to authenticate');
        print('Failed to authenticate');
        // if (locationController.latitudeString.isNotEmpty && locationController.longitudeString.isNotEmpty) {
        //   fetchRepresentatives123(locationController.latitudeString.value, locationController.longitudeString.value);
        // }
      }
    } else if (response.statusCode == 500) {
      Get.find<AuthService>().clearAuthResponse();
      Get.to(const AuthPage());
    } else {
      print('Failed to refresh token: ${response.reasonPhrase}');
      print("getxlocation");
      print(locationController.latitudeString.value);
      // if (locationController.latitudeString.isNotEmpty && locationController.longitudeString.isNotEmpty) {
      //   fetchRepresentatives123(locationController.latitudeString.value, locationController.longitudeString.value);
      // }      // Handle the error
    }
  }

  // final Completer<GoogleMapController> _mapController =
  //     Completer<GoogleMapController>();
  LatLng? _currentP;
  final String _currentAddress =
      'Block FB, Sector No. 80 \n Prahalad Garh, Rohini, \n North Delhi, Delhi';
  String _formattedCoordinates = "";
  MapController? controller;
  bool _isPositionInitialized = false;
  String latitudeString = '';
  String longitudeString = '';
  bool isLocationUpdated = false;

  @override
  void initState() {
    super.initState();
    print(authService.token);
    _requestLocationPermission();
    _getLocationUpdates();
    refreshAuthToken();
    initfunc();
    // print("initcoordinates");
    // print(latitudeString);
    // print(longitudeString);
  }


  void initfunc() async {
    while (true) {
      if (latitudeString != '' && longitudeString != '') {
        await fetchRepresentatives123(latitudeString, longitudeString);
        break; // Break the loop once the fetch method is called
      }
      await Future.delayed(Duration(milliseconds: 100)); // Small delay to prevent tight loop
    }
  }
  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _getLocationUpdates();
  }
  final LocationController locationController = Get.put(LocationController());

  Future<void> _getLocationUpdates() async {
    _locationService.onLocationChanged.listen(
          (location.LocationData currentLocation) async {
        if (currentLocation.latitude != null && currentLocation.longitude != null) {
          if (mounted && !isLocationUpdated) {
            setState(() {
              _formattedCoordinates = _convertToDMS(currentLocation.latitude!, currentLocation.longitude!);
            });
            print("_formattedCoordinates");
            print(_formattedCoordinates);

            var coordinates = _parseCoordinates(_formattedCoordinates);
            setState(() {
              latitudeString = _formattedCoordinates.split(',')[0];
              longitudeString = _formattedCoordinates.split(',')[1];
              locationController.setLatitudeString(_formattedCoordinates.split(',')[0]);
              locationController.setLongitudeString(_formattedCoordinates.split(',')[1]);
              print("_formattedCoordinates124");
              print(latitudeString);
              print(longitudeString);
              _currentPosition = LatLng(coordinates['latitude']!, coordinates['longitude']!);
              _updateMapPosition(_currentPosition!);
              _updateMarkers(_currentPosition!);
              _isPositionInitialized = true;
            // Mark location as updated to prevent further updates
            });
          }
        }
      },
    );
  }

  void _updateMapPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
  }

  void _updateMarkers(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: position,
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      };
    });
  }

  var representatives;

  Future<void> fetchRepresentatives123(String latitude, String longitude) async {
    var headers = {'Authorization': '${authService.token}'};

    var request = http.MultipartRequest(
      'GET',
      Uri.parse('https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getUserRepresentativesByCoordinates'),
    );

    request.fields.addAll({'latitude': latitude, 'longitude': longitude});
    print("fetchcalling");
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      setState(() {
         representatives = jsonResponse['data']['location_details']['formatted_address'];
        var representative = jsonResponse['data']['representatives'];
        representatives123!.clear();
        representatives123!.addAll(representative);
        print("address");
        print(representatives);
        Future.delayed(Duration(milliseconds: 1500),(){
          isLocationUpdated = true;
        });

      });
    } else {
      print("ERROR");
      print(response.reasonPhrase);
      var responseBody = await response.stream.bytesToString();
      var jsonData = json.decode(responseBody);
      setState(() {
        isLocationUpdated = true;
      });
      if (jsonData.containsKey('message')) {
        String message = jsonData['message'];
        print("Message $message");
      } else {
        Fluttertoast.showToast(
          msg: "An unknown error occurred.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    print("_formattedCoordinates:$_formattedCoordinates");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          "app_header_title".tr,
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.07,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            // Padding(
            //   padding: const EdgeInsets.only(left: 8.0),
            //   child: Text(
            //     'choose_location_title'.tr,
            //     style: TextStyle(
            //         fontSize: width * 0.06,
            //         fontWeight: FontWeight.bold,
            //         fontFamily: "Okra"),
            //   ),
            // ),
            // const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'choose_location_sub_title'.tr,
                style: TextStyle(fontSize: 18, color: greyColor),
              ),
            ),
            const SizedBox(height: 10),
            // Ensure the OSMFlutter widget is properly constrained
            _isPositionInitialized
                ? Stack(
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition,
                              zoom: 11.0,
                            ),
                            markers: _markers,
                          ),
                        ),
                      ),
                      widget.isRedirected!
                          ? Container()
                          : Positioned(
                              top:
                                  50, // Adjust this value to position the label as needed
                              left:
                                  130, // Adjust this value to position the label as needed
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.white,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      maxWidth:
                                          200), // Set a max width to constrain the text
                                  child: Text(
                                    representatives ?? 'No location found ',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 10),
                                    maxLines: null, // Allow unlimited lines
                                    overflow: TextOverflow
                                        .visible, // Ensure text is visible
                                  ),
                                ),
                              ),
                            ),
                    ],
                  )
                : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 0),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: width * 0.6,
                              height: width * 0.06,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: width * 0.8,
                              height: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
      bottomSheet: _isPositionInitialized
          ? Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              height: height * 0.57,
              child: LocationDetailsBottomSheet(
                address: _formattedCoordinates,
                isRedirected: widget.isRedirected!,
                ishomescreen: widget.ishomescreen!,
                representatives: widget.isRedirected == true
                    ? widget.representatives!
                    : representatives123!,
              ),
            )
          : Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        width: width * 0.6,
                        height: width * 0.06,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        width: width * 0.8,
                        height: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Future<void> _cameraToPosition(LatLng pos) async {
  //   final GoogleMapController controller = await _mapController.future;
  //   CameraPosition _newCameraPosition = CameraPosition(
  //     target: pos,
  //     zoom: 13,
  //   );
  //   await controller.animateCamera(
  //     CameraUpdate.newCameraPosition(_newCameraPosition),
  //   );
  // }

  Map<String, double> _parseCoordinates(String dmsCoordinates) {
    final regex = RegExp(r'(\d+)°(\d+)' "'" r'(\d+)"([NSEW])');
    final matches = regex.allMatches(dmsCoordinates);

    double parseDMS(int degrees, int minutes, int seconds, String direction) {
      double decimal = degrees + (minutes / 60) + (seconds / 3600);
      if (direction == 'S' || direction == 'W') {
        decimal = -decimal;
      }
      return decimal;
    }

    double latitude = 0;
    double longitude = 0;

    for (final match in matches) {
      int degrees = int.parse(match.group(1)!);
      int minutes = int.parse(match.group(2)!);
      int seconds = int.parse(match.group(3)!);
      String direction = match.group(4)!;

      if (direction == 'N' || direction == 'S') {
        latitude = parseDMS(degrees, minutes, seconds, direction);
      } else {
        longitude = parseDMS(degrees, minutes, seconds, direction);
      }
    }

    return {'latitude': latitude, 'longitude': longitude};
  }

  String _convertToDMS(double latitude, double longitude) {
    String latDirection = latitude >= 0 ? "N" : "S";
    String lonDirection = longitude >= 0 ? "E" : "W";

    String latDMS = _convertToDMSHelper(latitude.abs());
    String lonDMS = _convertToDMSHelper(longitude.abs());

    return "$latDMS$latDirection, $lonDMS$lonDirection";
  }

  String _convertToDMSHelper(double coordinate) {
    int degrees = coordinate.floor();
    double minutesDecimal = (coordinate - degrees) * 60;
    int minutes = minutesDecimal.floor();
    int seconds = ((minutesDecimal - minutes) * 60).round();

    // Adjust minutes and degrees if seconds are 60
    if (seconds == 60) {
      seconds = 0;
      minutes += 1;
    }
    if (minutes == 60) {
      minutes = 0;
      degrees += 1;
    }

    return "$degrees°$minutes'$seconds\"";
  }

  Future<void> _getAddressFromCoordinates(LatLng? coordinates) async {
    if (coordinates != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          // Update address or other details if needed
        });
      }
    }
  }

  // Future<void> _getAddressFromCoordinates(LatLng? coordinates) async {
  //   if (coordinates == null) {
  //     setState(() {
  //       _currentAddress = 'Fetching location...';
  //     });
  //     return;
  //   }
  //
  //   try {
  //     List<geocoding.Placemark> placemarks =
  //         await geocoding.placemarkFromCoordinates(
  //       coordinates.latitude,
  //       coordinates.longitude,
  //     );
  //
  //     if (placemarks.isNotEmpty) {
  //       geocoding.Placemark firstPlacemark = placemarks.first;
  //       setState(() {
  //         _currentAddress =
  //             '${firstPlacemark.subThoroughfare} ${firstPlacemark.thoroughfare}, ${firstPlacemark.locality}';
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching address: $e');
  //     setState(() {
  //       _currentAddress =
  //           'Block FB, Sector No. 80 \n Prahalad Garh, Rohini, \n North Delhi, Delhi';
  //     });
  //   }
  // }
}

class LocationSelectionBottomSheet extends StatefulWidget {
  final ValueChanged<String?> onStateChanged;

  const LocationSelectionBottomSheet({super.key, required this.onStateChanged});

  @override
  State<LocationSelectionBottomSheet> createState() =>
      _LocationSelectionBottomSheetState();
}

class _LocationSelectionBottomSheetState
    extends State<LocationSelectionBottomSheet> {
  String _selectedState = '';
  String _selectedDistrict = '';
  String _selectedSubDistrict = '';
  String _selectedLocalDivision = '';

  List<String> _states = [];
  List<String> _districts = [];
  List<String> _subDistricts = [];
  List<String> _localDivisions = [];

  void _fetchStates() async {
    var headers = {
      'Authorization': 'your_auth_token_here',
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/data/getAllStates'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic> states = responseData['data']['states'];
      setState(() {
        _states = states.map((state) => state['label']).cast<String>().toList();
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  void _fetchDistrictsByState(String stateId) async {
    var headers = {
      'Authorization': 'your_auth_token_here',
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/data/getDistrictsByState?state_id=$stateId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic> districts = responseData['data']['districts'];
      setState(() {
        _districts = districts
            .map((district) => district['label'])
            .cast<String>()
            .toList();
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  void _fetchSubDistrictsByDistrict(String districtId) async {
    var headers = {
      'Authorization': 'your_auth_token_here',
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/data/getSubDistrictsByDistrict?district_id=$districtId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic> subDistricts = responseData['data']['sub_districts'];
      setState(() {
        _subDistricts = subDistricts
            .map((subDistrict) => subDistrict['label'])
            .cast<String>()
            .toList();
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  final authService = Get.find<AuthService>();

  void _fetchLocalDivisionsBySubDistrict(String subDistrictId) async {
    var headers = {
      'Authorization': 'your_auth_token_here',
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://seal-app-eq6ra.ondigitalocean.app/myshetra/data/getLocalDivisionsBySubDistrict?sub_district_id=$subDistrictId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic> localDivisions = responseData['data']['local_divisions'];
      setState(() {
        _localDivisions = localDivisions
            .map((localDivision) => localDivision['label'])
            .cast<String>()
            .toList();
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showLocationSelectionBottomSheet(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFF4A4A4A)),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.add, color: Color(0xFF4A4A4A)),
                const SizedBox(width: 8),
                Text(
                  'choose_location_snackbar_enter_manually_text'.tr,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 16,
                    fontFamily: 'Okra',
                    fontWeight: FontWeight.w600,
                    height: 0,
                    letterSpacing: -0.30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLocationSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'choose_location_snackbar_enter_manually_text'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedState = newValue!;
                        _fetchDistrictsByState(newValue);
                      });
                    },
                    items: _states.map((state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDistrict = newValue!;
                        _fetchSubDistrictsByDistrict(newValue);
                      });
                    },
                    items: _districts.map((district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select District',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSubDistrict,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSubDistrict = newValue!;
                        _fetchLocalDivisionsBySubDistrict(newValue);
                      });
                    },
                    items: _subDistricts.map((subDistrict) {
                      return DropdownMenuItem<String>(
                        value: subDistrict,
                        child: Text(subDistrict),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select Sub District',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLocalDivision,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLocalDivision = newValue!;
                      });
                    },
                    items: _localDivisions.map((localDivision) {
                      return DropdownMenuItem<String>(
                        value: localDivision,
                        child: Text(localDivision),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select Local Division',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Perform action on submit button press
                      Navigator.of(context).pop();
                      // Optionally, you can pass the selected values back to the calling widget
                      // or perform further actions with them.
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class LocationDetailsBottomSheet extends StatefulWidget {
  String address;
  final bool isRedirected;
  final bool ishomescreen;
  final List<dynamic> representatives;
  LocationDetailsBottomSheet(
      {super.key,
      required this.address,
      required this.isRedirected,
      required this.ishomescreen,
      required this.representatives});

  @override
  State<LocationDetailsBottomSheet> createState() =>
      _LocationDetailsBottomSheetState();
}

class _LocationDetailsBottomSheetState
    extends State<LocationDetailsBottomSheet> {
  final authService = Get.find<AuthService>();
  final List<dynamic> _representatives = [];

  // bool _isLoading = false;

  // Map to store state label and value pairs

  // Future<void> fetchRepresentatives123(String latitude, String longitude) async {
  //   var headers = {'Authorization': '${authService.token}'};
  //
  //   var request = http.MultipartRequest(
  //     'GET',
  //     Uri.parse(
  //         'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getUserRepresentativesByCoordinates'),
  //   );
  //
  //   request.fields.addAll({'latitude': latitude, 'longitude': longitude});
  //   print("fetchcalling");
  //   request.headers.addAll(headers);
  //
  //   http.StreamedResponse response = await request.send();
  //
  //   if (response.statusCode == 200) {
  //     var responseBody = await response.stream.bytesToString();
  //     var jsonResponse = json.decode(responseBody);
  //
  //     // Extract representatives data
  //     var representatives = jsonResponse['data']['representatives'];
  //
  //     // Clear existing list and add new data
  //     _representatives.clear();
  //     _representatives.addAll(representatives);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     // Print or use _representatives as needed
  //     print('Representatives: $_representatives');
  //   } else {
  //     print("ERROR");
  //     print(response.reasonPhrase);
  //     setState(() {
  //       isLoading = false;
  //     });
  //     var responseBody = await response.stream.bytesToString();
  //     var jsonData = json.decode(responseBody);
  //
  //     if (jsonData.containsKey('message')) {
  //       String message = jsonData['message'];
  //       Fluttertoast.showToast(
  //           msg: message,
  //           toastLength: Toast.LENGTH_LONG,
  //           gravity: ToastGravity.TOP,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.red,
  //           textColor: Colors.white,
  //           fontSize: 16.0);
  //       setState(() {
  //         _isLoading = false;
  //         print("Is loading getting false");
  //       });
  //       setState(() {
  //         _isLoading = false;
  //         print("Is loading getting false");
  //       });
  //     } else {
  //       Fluttertoast.showToast(
  //           msg: "An unknown error occurred.",
  //           toastLength: Toast.LENGTH_LONG,
  //           gravity: ToastGravity.TOP,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.red,
  //           textColor: Colors.white,
  //           fontSize: 16.0);
  //     }
  //   }
  // }

  // Map to store local division label and value pairs

  // void _showLocationSelectionBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return Container(
  //             padding: const EdgeInsets.all(16),
  //             child: SingleChildScrollView(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text(
  //                     'choose_location_snackbar_enter_manually_text'.tr,
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   DropdownButtonFormField<String>(
  //                     value: _selectedState,
  //                     onChanged: (newValue) {
  //                       setState(() {
  //                         _selectedState = newValue!;
  //                         _selectedState1 = _stateMap[newValue]!;
  //                         _fetchDistrictsByState(_stateMap[newValue]!);
  //                       });
  //                     },
  //                     items: _states.map((state) {
  //                       return DropdownMenuItem<String>(
  //                         value: state,
  //                         child: Text(state),
  //                       );
  //                     }).toList(),
  //                     decoration: const InputDecoration(
  //                       labelText: 'Select State',
  //                       border: OutlineInputBorder(),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   DropdownButtonFormField<String>(
  //                     value: _selectedDistrict,
  //                     onChanged: (newValue) {
  //                       setState(() {
  //                         _selectedDistrict = newValue!;
  //                         _selectedDistrict1 = _districtMap[newValue]!;
  //                         _fetchSubDistrictsByDistrict(_districtMap[newValue]!);
  //                       });
  //                     },
  //                     items: _districts.map((district) {
  //                       return DropdownMenuItem<String>(
  //                         value: district,
  //                         child: Text(district),
  //                       );
  //                     }).toList(),
  //                     decoration: const InputDecoration(
  //                       labelText: 'Select District',
  //                       border: OutlineInputBorder(),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   DropdownButtonFormField<String>(
  //                     value: _selectedSubDistrict,
  //                     onChanged: (newValue) {
  //                       setState(() {
  //                         _selectedSubDistrict = newValue!;
  //                         _selectedSubDistrict1 = _subDistrictMap[newValue]!;
  //                         _fetchLocalDivisionsBySubDistrict(
  //                             _subDistrictMap[newValue]!);
  //                       });
  //                     },
  //                     items: _subDistricts.map((subDistrict) {
  //                       return DropdownMenuItem<String>(
  //                         value: subDistrict,
  //                         child: Text(subDistrict),
  //                       );
  //                     }).toList(),
  //                     decoration: const InputDecoration(
  //                       labelText: 'Select Sub District',
  //                       border: OutlineInputBorder(),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   DropdownButtonFormField<String>(
  //                     value: _selectedLocalDivision,
  //                     onChanged: (newValue) {
  //                       setState(() {
  //                         _selectedLocalDivision = newValue!;
  //                         _selectedLocalDivision1 =
  //                             _localDivisionMap[newValue]!;
  //                       });
  //                     },
  //                     items: _localDivisions.map((localDivision) {
  //                       return DropdownMenuItem<String>(
  //                         value: localDivision,
  //                         child: Text(localDivision),
  //                       );
  //                     }).toList(),
  //                     decoration: const InputDecoration(
  //                       labelText: 'Select Local Division',
  //                       border: OutlineInputBorder(),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   ElevatedButton(
  //                     onPressed: () async {
  //                       // Perform action on submit button press
  //                       await fetchRepresentatives(
  //                           localDivisionId: _selectedLocalDivision1,
  //                           subDistrictId: _selectedSubDistrict1,
  //                           districtId: _selectedDistrict1);
  //                       setState(() {}); // Refresh bottom sheet with new data
  //                     },
  //                     child: const Text('Submit'),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   _isLoading
  //                       ? const CircularProgressIndicator()
  //                       : _representatives.isEmpty
  //                           ? const Text(
  //                               'No representatives found in your area.')
  //                           : RepresentativeWidget(
  //                               representatives: _representatives),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  final String _formattedCoordinates = "";
  String _convertToDMSHelper(double coordinate) {
    int degrees = coordinate.floor();
    double minutesDecimal = (coordinate - degrees) * 60;
    int minutes = minutesDecimal.floor();
    int seconds = ((minutesDecimal - minutes) * 60).round();

    // Adjust minutes and degrees if seconds are 60
    if (seconds == 60) {
      seconds = 0;
      minutes += 1;
    }
    if (minutes == 60) {
      minutes = 0;
      degrees += 1;
    }

    return "$degrees°$minutes'$seconds\"";
  }

  String _convertToDMS(double latitude, double longitude) {
    String latDirection = latitude >= 0 ? "N" : "S";
    String lonDirection = longitude >= 0 ? "E" : "W";

    String latDMS = _convertToDMSHelper(latitude.abs());
    String lonDMS = _convertToDMSHelper(longitude.abs());

    return "$latDMS$latDirection, $lonDMS$lonDirection";
  }

  String latitudeString = "";
  String longitudeString = "";
  bool isLoading = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   Future.delayed(Duration(seconds: 2), () {
  //     setState(() {
  //       latitudeString = widget.address.split(',')[0];
  //       longitudeString = widget.address.split(',')[1];
  //     });

  //     print("lattitudeinit");
  //     print(widget.address);
  //     print(latitudeString);
  //     print(longitudeString);

  //     fetchRepresentatives123(latitudeString, longitudeString);
  //     // _fetchStates();
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  @override
  void initState() {
    // setState(() {
    //   _isLoading = true;
    // });
    // TODO: implement initState
    Future.delayed(const Duration(seconds: 2), () {
      // _isLoading = false;
      print("lattitudeinit");
      print(widget.address);
      print(latitudeString);
      print(longitudeString);
      // if (widget.isRedirected == true) {
      //   setState(() {
      //     _isLoading = false;
      //     print("Is loading getting false");
      //   });
      // }
      // else {
      //   fetchRepresentatives123(latitudeString, longitudeString);
      // }

      // fetchRepresentatives123(latitudeString, longitudeString);

      // setState(() {
      //   _isLoading = false;
      //   print("Is loading getting false");
      // });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    print("lattitudebuild");
    print(latitudeString);
    print(longitudeString);
    print(authService.token);
    print(widget.representatives);
    print(widget.isRedirected);
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                // Divider(
                //   thickness: 2,
                // ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'choose_location_snackbar_title'.tr,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // const SizedBox(height: 5),
                widget.isRedirected == true
                    ? Padding(
                  padding: const EdgeInsets.all(8.0),
                        child: widget.representatives.isEmpty
                            ? Column(
                                children: [
                                  SizedBox(height: Get.height * 0.08),
                                  Center(
                                      child: Text(
                                          "choose_location_snackbar_no_representative_text"
                                              .tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor))),
                                  SizedBox(height: Get.height * 0.1),
                                ],
                              )
                            : Column(
                                children: widget.representatives.map((rep) {
                                  print("rep is ${rep.toString()}");
                                  return Column(
                                    children: [
                                      Container(
                                        // margin: EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Image.network(
                                                      rep['image_url'] ??
                                                          "https://cdn1.iconfinder.com/data/icons/project-management-8/500/worker-512.png",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            rep['name'],
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Container(
                                                        width: width * 0.48,
                                                        child: Text(
                                                          rep['user_role_label'] +
                                                              " " +
                                                              rep['division_name'],

                                                          style: const TextStyle(
                                                            overflow: TextOverflow.ellipsis,
                                                              fontSize: 14,
                                                              color: Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Image.network(
                                                  rep['org_symbol_url'],
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                }).toList(),
                              ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: widget.representatives.isEmpty
                            ? SizedBox(
                                height: Get.height * 0.2,
                                child: Center(
                                    child: Text(
                                  "choose_location_snackbar_no_representative_text"
                                      .tr,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                              )
                            : Column(
                                children: widget.representatives.map((rep) {
                                  print("rep is ${rep.toString()}");
                                  return Column(
                                    children: [
                                      SizedBox(height: 10,),
                                      Container(
                                        // margin: EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Image.network(
                                                      rep['image_url'] ??
                                                          "https://cdn1.iconfinder.com/data/icons/project-management-8/500/worker-512.png",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            rep['name'],
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Container(
                                                        width: width * 0.48,
                                                        child: Text(
                                                          rep['user_role_label'] +
                                                              " " +
                                                              rep['division_name'],

                                                          style: const TextStyle(
                                                              overflow: TextOverflow.ellipsis,
                                                              fontSize: 14,
                                                              color: Colors.grey,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Image.network(
                                                  rep['org_symbol_url'],
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // const SizedBox(height: 10),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'choose_location_snackbar_not_your_representatives_text'.tr,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Okra',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Get.to(const ManualPage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                    child: Container(
                      decoration: ShapeDecoration(
                        color: const Color.fromARGB(255, 220, 231, 240),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 30),
                        child: Row(
                          children: [
                            Icon(Icons.add, color: primaryColor, weight: 26),
                            const SizedBox(width: 8),
                            Text(
                              'choose_location_snackbar_enter_manually_text'.tr,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18,
                                fontFamily: 'Okra',
                                fontWeight: FontWeight.w600,
                                height: 0,
                                letterSpacing: -0.30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                MyButton(
                    onTap: () {
                      // OrganizationProofScreen
                      widget.ishomescreen
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            )
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OrganizationProofScreen(),
                              ),
                            );
                    },
                    text: "choose_location_snackbar_button_text".tr),

                // Repeat the above structure for the second item if needed
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RepresentativeWidget extends StatelessWidget {
  final List<dynamic> representatives;

  const RepresentativeWidget({super.key, required this.representatives});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: representatives.isEmpty
          ? [
              SizedBox(
                  height: 200,
                  child: Center(
                      child: Text(
                          'choose_location_snackbar_no_representative_text'
                              .tr)))
            ]
          : representatives.map((rep) {
              return Column(
                children: [
                  SizedBox(height:10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey,
                          ),
                          child: Image.network(
                            rep['org_symbol_url'],
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rep['name'],
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: width * 0.48,
                                child: Text(
                                  rep['user_role_label'] +
                                      " " +
                                      rep['division_name'],

                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight:
                                      FontWeight
                                          .bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
    );
  }
}


class LocationController extends GetxController {
  var latitudeString = ''.obs;
  var longitudeString = ''.obs;

  void setLatitudeString(String value) {
    latitudeString.value = value;
  }

  void setLongitudeString(String value) {
    longitudeString.value = value;
  }
}