import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:myshetra/Pages/Editprofile.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:myshetra/helpers/colors.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  location.Location _locationController = location.Location();
  final authService = Get.find<AuthService>();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _currentP;
  String _currentAddress =
      'Block FB, Sector No. 80 \n Prahalad Garh, Rohini, \n North Delhi, Delhi';

  @override
  void initState() {
    super.initState();
    print(authService.token);
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
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
          "My Shetra",
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
          children: [
            const SizedBox(height: 0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose you sector location',
                style: TextStyle(
                    fontSize: width * 0.06, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Please Select your location',
                style: TextStyle(fontSize: 18, color: greyColor),
              ),
            ),
            GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: _currentP ?? LatLng(0, 0),
                zoom: 100, // Adjust the zoom level as needed
              ),
              markers: _currentP == null
                  ? {}
                  : {
                      Marker(
                        markerId: MarkerId("_currentLocation"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor
                                .hueAzure), // Set marker color to black
                        position: _currentP!,
                      ),
                    },
            ),
          ],
        ),
      ),
      bottomSheet: LocationDetailsBottomSheet(
        address: _currentAddress,
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
            _currentP =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            _cameraToPosition(_currentP!);
          });

          // Fetch address using geocoding
          await _getAddressFromCoordinates(_currentP);
        }
      },
    );
  }

  Future<void> _getAddressFromCoordinates(LatLng? coordinates) async {
    if (coordinates == null) {
      setState(() {
        _currentAddress = 'Fetching location...';
      });
      return;
    }

    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        geocoding.Placemark firstPlacemark = placemarks.first;
        setState(() {
          _currentAddress =
              '${firstPlacemark.subThoroughfare} ${firstPlacemark.thoroughfare}, ${firstPlacemark.locality}';
        });
      }
    } catch (e) {
      print('Error fetching address: $e');
      setState(() {
        _currentAddress =
            'Block FB, Sector No. 80 \n Prahalad Garh, Rohini, \n North Delhi, Delhi';
      });
    }
  }
}

void _showLocationSelectionBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Your LocationSelectionBottomSheet content
            LocationSelectionBottomSheet(
              onStateChanged: (String? value) {
                // Your logic here
              },
            ),

            // Circle-shaped black container with cross icon
            // Positioned(
            //   top: 0,
            //   child: Container(
            //     width: 40.0,  // Adjust the size according to your design
            //     height: 40.0,  // Adjust the size according to your design
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       color: Colors.black,
            //     ),
            //     child: Center(
            //       child: IconButton(
            //         icon: Icon(Icons.close, color: Colors.white),
            //         onPressed: () {
            //           Navigator.pop(context); // Close the modal
            //         },
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    },
  );
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
  String? _selectedState;
  String? _selected1;
  String? _selected2;
  String? _selected3;
  String address = 'Reliance Fresh, \n Block FB, Rohini Sec - 12';
  final List<Map<String, String>> states = [
    {"key": "1", "value": "Delhi"},
    {"key": "2", "value": "Haryana"},
    {"key": "3", "value": "Uttar Pradesh"},
    {"key": "4", "value": "Punjab"},
  ];

  final List<Map<String, String>> Zone = [
    {"key": "1", "value": "North Delhi"},
    {"key": "2", "value": "East Delhi"},
    {"key": "3", "value": "South Delhi"},
    {"key": "4", "value": "West Delhi"},
  ];

  final List<Map<String, String>> District = [
    {"key": "1", "value": "Shahadar"},
    {"key": "2", "value": "Rohini"},
    {"key": "3", "value": "Dwarka"},
    {"key": "4", "value": "Janakpuri"},
  ];
  final List<Map<String, String>> Sector = [
    {"key": "1", "value": "11"},
    {"key": "2", "value": "12"},
    {"key": "3", "value": "13"},
    {"key": "4", "value": "3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nearby locations',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Okra',
                      fontWeight: FontWeight.w500,
                      height: 0,
                      letterSpacing: -0.30,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            '135m',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          address,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            '135m',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          address,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            '135m',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          address,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.black12, // Use the color #3F1444
                          thickness: 1,
                        ),
                      ),
                      Center(
                        child: Text(
                          'Check Manually',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.black12, // Use the color #3F1444
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("State"),
                    )),
                _buildDropdown('Select State', states),
                SizedBox(
                  height: 8,
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Zone"),
                    )),
                _buildDropdown1('Select Zone ', Zone),
                SizedBox(
                  height: 8,
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("District"),
                    )),
                _buildDropdown2('Select District', District),
                SizedBox(
                  height: 8,
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Sector Number"),
                    )),
                _buildDropdown3('Select Sector Number', Sector),
                SizedBox(
                  height: 8,
                ),
                Container(
                  width: 303,
                  height: 43,
                  decoration: ShapeDecoration(
                    color: Color(0xFFFF5252),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Check Representatives',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Okra',
                        fontWeight: FontWeight.w500,
                        height: 0,
                        letterSpacing: -0.30,
                      ),
                    ),
                  ),
                )
                // Additional fields for Zone, District, Sector can be added here
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String hintText, List<Map<String, String>> items) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(hintText),
        value: _selectedState,
        items: items.map((Map<String, String> item) {
          return DropdownMenuItem<String>(
            value: item['key'],
            child: Text(item['value']!),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _selectedState = value;
          });
          widget.onStateChanged(value);
        },
      ),
    );
  }

  Widget _buildDropdown1(String hintText, List<Map<String, String>> items) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(hintText),
        value: _selected1,
        items: items.map((Map<String, String> item) {
          return DropdownMenuItem<String>(
            value: item['key'],
            child: Text(item['value']!),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _selected1 = value;
          });
          widget.onStateChanged(value);
        },
      ),
    );
  }

  Widget _buildDropdown2(String hintText, List<Map<String, String>> items) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(hintText),
        value: _selected2,
        items: items.map((Map<String, String> item) {
          return DropdownMenuItem<String>(
            value: item['key'],
            child: Text(item['value']!),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _selected2 = value;
          });
          widget.onStateChanged(value);
        },
      ),
    );
  }

  Widget _buildDropdown3(String hintText, List<Map<String, String>> items) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(hintText),
        value: _selected3,
        items: items.map((Map<String, String> item) {
          return DropdownMenuItem<String>(
            value: item['key'],
            child: Text(item['value']!),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _selected3 = value;
          });
          widget.onStateChanged(value);
        },
      ),
    );
  }
}

class LocationDetailsBottomSheet extends StatelessWidget {
  final String address;

  LocationDetailsBottomSheet({required this.address});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Container with the exact address and location icon
              Container(
                padding: EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.grey),
                //   borderRadius: BorderRadius.circular(8),
                // ),
                child: Row(
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          address,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Divider(
                thickness: 2,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Your repair experts',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Column with image and text
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey,
                        ),
                        // Replace with your image widget
                        child: Image.network(
                          'https://imgs.search.brave.com/5h0EbKGdF1fI4OII39XaDGZEj8LwR9Z1aHPL8u2pc7Q/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9zdDIu/ZGVwb3NpdHBob3Rv/cy5jb20vMTQzOTg4/OC85NDExL2kvNjAw/L2RlcG9zaXRwaG90/b3NfOTQxMTgyNDgt/c3RvY2stcGhvdG8t/ZmVtYWxlLXVzZXIt/YXZhdGFyLWljb24u/anBn',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Container with text
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Replace with your text
                            Row(
                              children: [
                                Text(
                                  'Manoj Bajaj',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                // Image.asset(
                                //     "assets/Bharatiya_Janata_Party_logo 1.png"),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Replace with your text
                            Text(
                              'Exterior Mechanic',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            // Image.asset("assets/Bharatiya_Janata_Party_logo 1.png"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey,
                        ),
                        // Replace with your image widget
                        child: Image.network(
                          'https://imgs.search.brave.com/5h0EbKGdF1fI4OII39XaDGZEj8LwR9Z1aHPL8u2pc7Q/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9zdDIu/ZGVwb3NpdHBob3Rv/cy5jb20vMTQzOTg4/OC85NDExL2kvNjAw/L2RlcG9zaXRwaG90/b3NfOTQxMTgyNDgt/c3RvY2stcGhvdG8t/ZmVtYWxlLXVzZXIt/YXZhdGFyLWljb24u/anBn',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Container with text
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Replace with your text
                            Row(
                              children: [
                                Text(
                                  'Manoj Bajaj',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                // Image.asset(
                                //     "assets/Bharatiya_Janata_Party_logo 1.png"),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Replace with your text
                            Text(
                              'Exterior Mechanic',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            // Image.asset("assets/Bharatiya_Janata_Party_logo 1.png"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.black12, // Use the color #3F1444
                        thickness: 1,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Not your sector area?',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.black12, // Use the color #3F1444
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _showLocationSelectionBottomSheet(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // width: 381,
                    // height: 31,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Color(0xFF4A4A4A)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Enter manually',
                          style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontSize: 16,
                            fontFamily: 'Okra',
                            fontWeight: FontWeight.w600,
                            height: 0,
                            letterSpacing: -0.30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF5252), // Background color
                  ),
                  onPressed: () {
                    // OrganizationProofScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(),
                      ),
                    );
                    // verifySignupOTP(
                    //   mobileNumber: mobileNumberController.text,
                    //   otp: otpcontroller.text,
                    //   name: nameController.text,
                    //   gender: gender,
                    //   dateOfBirth: dateOfBirthController.text,
                    // );
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
              ),
              // Repeat the above structure for the second item if needed
            ],
          ),
        ),
      ],
    );
  }
}
