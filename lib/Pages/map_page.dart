import 'dart:async';
import 'dart:convert';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Pages/Editprofile.dart';
import 'package:myshetra/Pages/ManualPage.dart';
import 'package:myshetra/Pages/Oranisation.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:get/get.dart';

import 'package:myshetra/helpers/colors.dart';

class MapPage extends StatefulWidget {
  final bool? isRedirected;
  final List<dynamic>? representatives;

  MapPage(
      {Key? key, this.isRedirected = false, this.representatives = const []})
      : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  location.Location _locationController = location.Location();
  final authService = Get.find<AuthService>();
  double? latitude;
  double? longitude;
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  LatLng? _currentP;
  String _currentAddress =
      'Block FB, Sector No. 80 \n Prahalad Garh, Rohini, \n North Delhi, Delhi';
  String _formattedCoordinates = "";
  late MapController controller;

  @override
  void initState() {
    super.initState();
    print(authService.token);
    getLocationUpdates();
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
        leading: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey), // Border color
                  shape: BoxShape.circle, // Rounded shape
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.arrow_back, // Back icon
                    color: Colors.black, // Icon color
                  ),
                ),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            Text(
              'Choose your sector location',
              style: TextStyle(
                  fontSize: width * 0.06, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 0),
            Text(
              'Please Select your location',
              style: TextStyle(fontSize: 18, color: greyColor),
            ),
            // Ensure the OSMFlutter widget is properly constrained
            Expanded(
              child: OSMFlutter(
                controller: controller,
                osmOption: OSMOption(
                  userTrackingOption: UserTrackingOption(
                    enableTracking: true,
                    unFollowUser: false,
                  ),
                  zoomOption: ZoomOption(
                    initZoom: 8,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                  ),
                  userLocationMarker: UserLocationMaker(
                    personMarker: MarkerIcon(
                      icon: Icon(
                        Icons.location_history_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    directionArrowMarker: MarkerIcon(
                      icon: Icon(
                        Icons.double_arrow,
                        size: 48,
                      ),
                    ),
                  ),
                  roadConfiguration: RoadOption(
                    roadColor: Colors.yellowAccent,
                  ),
                  markerOption: MarkerOption(
                    defaultMarker: MarkerIcon(
                      icon: Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 56,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        height: height * 0.55,
        child: LocationDetailsBottomSheet(
          address: _currentAddress,
          isRedirected: widget.isRedirected!,
          representatives: widget.representatives!,
        ),
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    _locationController.onLocationChanged.listen(
      (location.LocationData currentLocation) async {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(() {
            _formattedCoordinates = _convertToDMS(
                currentLocation.latitude!, currentLocation.longitude!);
          });
          print("_formattedCoordinates");
          print(_formattedCoordinates);

          // Parse the DMS coordinates to decimal degrees
          var coordinates = _parseCoordinates(_formattedCoordinates);
          setState(() {
            latitude = coordinates['latitude']!;
            longitude = coordinates['longitude']!;
            controller = MapController(
              initPosition: GeoPoint(
                latitude: latitude!,
                longitude: longitude!,
              ),
            );
          });

          print(latitude);
          print(longitude);
          // Update the map controller's position
          // controller.initPosition = GeoPoint(latitude: latitude, longitude: longitude);

          // Fetch address using geocoding
          await _getAddressFromCoordinates(LatLng(latitude!, longitude!));
        }
      },
    );
  }

  Map<String, double> _parseCoordinates(String dmsCoordinates) {
    final regex = RegExp(r'(\d+)°(\d+)' + "'" + r'(\d+)"([NSEW])');
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

    return "${degrees}°${minutes}'${seconds}\"";
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

  LocationSelectionBottomSheet({required this.onStateChanged});

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
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.add, color: Color(0xFF4A4A4A)),
                SizedBox(width: 8),
                Text(
                  'choose_location_snackbar_enter_manually_text'.tr,
                  style: TextStyle(
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
                    style: TextStyle(
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
  final String address;
  final bool isRedirected;
  final List<dynamic> representatives;
  LocationDetailsBottomSheet(
      {required this.address,
      required this.isRedirected,
      required this.representatives});

  @override
  State<LocationDetailsBottomSheet> createState() =>
      _LocationDetailsBottomSheetState();
}

class _LocationDetailsBottomSheetState
    extends State<LocationDetailsBottomSheet> {
  final authService = Get.find<AuthService>();
  List<dynamic> _representatives = [];
  String _selectedState = '';
  String _selectedDistrict = '';
  String _selectedSubDistrict = '';
  String _selectedLocalDivision = '';
  String _selectedState1 = '';
  String _selectedDistrict1 = '';
  String _selectedSubDistrict1 = '';
  String _selectedLocalDivision1 = '';

  List<String> _states = [];
  List<String> _districts = [];
  List<String> _subDistricts = [];
  List<String> _localDivisions = [];
  Map<String, String> _stateMap =
      {}; // Map to store state label and value pairs

  void fetchRepresentatives123() async {
    var headers = {'Authorization': '${authService.token}'};
    var url = Uri.parse(
        'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getUserRepresentativesByCoordinates?latitude=28°39\'17"N&longitude=77°07\'45"E');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Parse JSON response
      var jsonResponse = json.decode(response.body);

      // Extract representatives data
      var representatives = jsonResponse['data']['representatives'];

      // Clear existing list and add new data
      _representatives.clear();
      _representatives.addAll(representatives);

      // Print or use _representatives as needed
      print('Representatives: $_representatives');
    } else {
      Get.snackbar('Server Error', 'Failed to fetch representatives',
          backgroundColor: Colors.red, colorText: Colors.white);
      print('Request failed with status: ${response.statusCode}');
    }
  }

  void _fetchStates() async {
    var headers = {'Authorization': '${authService.token}'};
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
        _states = states.map((state) => state['label'] as String).toList();
        _stateMap = Map.fromIterable(states,
            key: (state) => state['label'] as String,
            value: (state) => state['value'] as String);
        _selectedState = _states.isNotEmpty
            ? _states[0]
            : ''; // Initialize with the first state if available
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Map<String, String> _districtMap =
      {}; // Map to store district label and value pairs

  void _fetchDistrictsByState(String stateId) async {
    var headers = {'Authorization': '${authService.token}'};
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
        _districts =
            districts.map((district) => district['label'] as String).toList();
        _districtMap = Map.fromIterable(districts,
            key: (district) => district['label'] as String,
            value: (district) => district['value'] as String);
        _selectedDistrict = _districts.isNotEmpty
            ? _districts[0]
            : ''; // Initialize with the first district if available
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Map<String, String> _subDistrictMap =
      {}; // Map to store sub-district label and value pairs

  void _fetchSubDistrictsByDistrict(String districtId) async {
    var headers = {'Authorization': '${authService.token}'};
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
            .map((subDistrict) => subDistrict['label'] as String)
            .toList();
        _subDistrictMap = Map.fromIterable(subDistricts,
            key: (subDistrict) => subDistrict['label'] as String,
            value: (subDistrict) => subDistrict['value'] as String);
        _selectedSubDistrict = _subDistricts.isNotEmpty
            ? _subDistricts[0]
            : ''; // Initialize with the first sub-district if available
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Map<String, String> _localDivisionMap =
      {}; // Map to store local division label and value pairs
  bool _isLoading = false;

  Future<void> fetchRepresentatives({
    required String localDivisionId,
    required String subDistrictId,
    required String districtId,
  }) async {
    var headers = {
      'Authorization':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtb2JpbGUiOiI3MDExODk5ODI2IiwidXNlcl9pZCI6IjY2Nzg1NDViNTdiMWE0YmE0ZDk4MTJjZiIsInVzZXJfdHlwZSI6ImdlbmVyYWxfdXNlciIsImV4cCI6MTcxOTI0ODM0N30.q6IyfAq1aagaUvA3xz-H39DApJrMdhL06DOdpp8mFLg'
    };

    var formData = {
      'local_division_id': localDivisionId,
      'sub_district_id': subDistrictId,
      'district_id': districtId,
    };

    var request = http.MultipartRequest(
      'GET',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getUserRepresentativesByLocationId'),
    );

    request.fields.addAll(formData);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  void _fetchLocalDivisionsBySubDistrict(String subDistrictId) async {
    var headers = {'Authorization': '${authService.token}'};
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
            .map((localDivision) => localDivision['label'] as String)
            .toList();
        _localDivisionMap = Map.fromIterable(localDivisions,
            key: (localDivision) => localDivision['label'] as String,
            value: (localDivision) => localDivision['value'] as String);
        _selectedLocalDivision = _localDivisions.isNotEmpty
            ? _localDivisions[0]
            : ''; // Initialize with the first local division if available
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  void _showLocationSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'choose_location_snackbar_enter_manually_text'.tr,
                      style: TextStyle(
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
                          _selectedState1 = _stateMap[newValue]!;
                          _fetchDistrictsByState(_stateMap[newValue]!);
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
                          _selectedDistrict1 = _districtMap[newValue]!;
                          _fetchSubDistrictsByDistrict(_districtMap[newValue]!);
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
                          _selectedSubDistrict1 = _subDistrictMap[newValue]!;
                          _fetchLocalDivisionsBySubDistrict(
                              _subDistrictMap[newValue]!);
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
                          _selectedLocalDivision1 =
                              _localDivisionMap[newValue]!;
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
                      onPressed: () async {
                        // Perform action on submit button press
                        await fetchRepresentatives(
                            localDivisionId: _selectedLocalDivision1,
                            subDistrictId: _selectedSubDistrict1,
                            districtId: _selectedDistrict1);
                        setState(() {}); // Refresh bottom sheet with new data
                      },
                      child: const Text('Submit'),
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : _representatives.isEmpty
                            ? const Text(
                                'No representatives found in your area.')
                            : RepresentativeWidget(
                                representatives: _representatives),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchRepresentatives123();
    _fetchStates();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // Divider(
                //   thickness: 2,
                // ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Your repair Sector',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                widget.isRedirected == true
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: widget.representatives.isEmpty
                            ? Column(
                                children: [
                                  SizedBox(height: Get.height * 0.05),
                                  Center(
                                      child: Text(
                                          "No representatives found in your area.",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor))),
                                  SizedBox(height: Get.height * 0.1),
                                ],
                              )
                            : Column(
                                children: _representatives.map((rep) {
                                  return Column(
                                    children: [
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
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.grey,
                                              ),
                                              child: Image.network(
                                                rep['org_symbol_url'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                      const SizedBox(width: 5),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    rep['division_name'],
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                              ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _representatives.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: _representatives.map((rep) {
                                  return Column(
                                    children: [
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
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.grey,
                                              ),
                                              child: Image.network(
                                                rep['org_symbol_url'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                      const SizedBox(width: 5),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    rep['division_name'],
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                              ),
                      ),

                const SizedBox(height: 0),
                const Text(
                  'Not your sector area?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Okra',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(ManualPage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: ShapeDecoration(
                        color: const Color.fromARGB(255, 220, 231, 240),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: primaryColor),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20),
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
                MyButton(
                    onTap: () {
                      // OrganizationProofScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrganizationProofScreen(),
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

  RepresentativeWidget({required this.representatives});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: representatives.isEmpty
          ? [const Text('No representatives found in your area.')]
          : representatives.map((rep) {
              return Column(
                children: [
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
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey,
                          ),
                          child: Image.network(
                            rep['org_symbol_url'],
                            fit: BoxFit.cover,
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
                              Text(
                                rep['division_name'],
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
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
