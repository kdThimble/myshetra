import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:myshetra/Components/MyButton.dart';
import 'package:myshetra/Controller/loadingController.dart';
import 'package:myshetra/Pages/Editprofile.dart';
import 'package:myshetra/Pages/map_page.dart';
import 'package:myshetra/Services/Authservices.dart';
import 'package:myshetra/helpers/colors.dart';
import 'package:http/http.dart' as http;

class ManualPage extends StatefulWidget {
  const ManualPage({super.key});

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  bool _isLoading = false;
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

  Future<void> fetchRepresentatives({
    required String localDivisionId,
    required String subDistrictId,
    required String districtId,
  }) async {
    Get.find<LoadingController>().startLoading();
    var headers = {
      'Authorization':
          '${authService.token}', // Authorization header with the token
    };

    var formData = {
      'local_division_id': localDivisionId,
      'sub_district_id': subDistrictId,
      'district_id': districtId,
    };
    print("local_division_id: $localDivisionId");
    print("sub_district_id: $subDistrictId");
    print("district_id: $districtId");

    var request = http.MultipartRequest(
      'GET',
      Uri.parse(
          'https://seal-app-eq6ra.ondigitalocean.app/myshetra/users/getUserRepresentativesByLocationId'),
    );

    request.fields.addAll(formData);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    Get.find<LoadingController>().stopLoading();
    String responseBody = await response.stream.bytesToString();
    var jsonData = json.decode(responseBody);
    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      var representatives = jsonData['data']['representatives'];

      // Clear existing list and add new data
      _representatives.clear();
      _representatives.addAll(representatives);

      // Print or use _representatives as needed
      // Fluttertoast.showToast(
      //     msg: jsonData['message'] ?? "Server Error",
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     gravity: ToastGravity.TOP);
      print('Representatives: $_representatives');
    } else {
      print(response.reasonPhrase);
      Fluttertoast.showToast(
          msg: jsonData['message'] ?? "Server Error",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.TOP);
    }
  }

  Map<String, String> _localDivisionMap = {};
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

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/Group1.png",
                    fit: BoxFit.fitWidth,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                ),
                Expanded(
                    child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'choose_location_snackbar_enter_manually_text'
                                          .tr,
                                      style: TextStyle(
                                        fontSize: Get.width * 0.057,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'State',
                                      style: TextStyle(
                                        fontSize: Get.width * 0.037,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      focusColor: Colors.blue,

                                      // value: _selectedState,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedState = newValue!;
                                          _selectedState1 =
                                              _stateMap[newValue]!;
                                          _fetchDistrictsByState(
                                              _stateMap[newValue]!);
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
                                    Text(
                                      'Zone',
                                      style: TextStyle(
                                        fontSize: Get.width * 0.037,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      value: _selectedDistrict,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedDistrict = newValue!;
                                          _selectedDistrict1 =
                                              _districtMap[newValue]!;
                                          _fetchSubDistrictsByDistrict(
                                              _districtMap[newValue]!);
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
                                    Text(
                                      'Sub District',
                                      style: TextStyle(
                                        fontSize: Get.width * 0.037,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      value: _selectedSubDistrict,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedSubDistrict = newValue!;
                                          _selectedSubDistrict1 =
                                              _subDistrictMap[newValue]!;
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
                                    Text(
                                      'Local division',
                                      style: TextStyle(
                                        fontSize: Get.width * 0.037,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      value: _selectedLocalDivision,
                                      onChanged: (newValue) async {
                                        setState(() {
                                          _selectedLocalDivision = newValue!;
                                          _selectedLocalDivision1 =
                                              _localDivisionMap[newValue]!;
                                        });
                                        await fetchRepresentatives(
                                            localDivisionId:
                                                _selectedLocalDivision1,
                                            subDistrictId:
                                                _selectedSubDistrict1,
                                            districtId: _selectedDistrict1);
                                      },
                                      items:
                                          _localDivisions.map((localDivision) {
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
                                    MyButton(
                                        onTap: () async {
                                          if (_selectedLocalDivision1.isEmpty) {
                                            Fluttertoast.showToast(
                                                msg: 'Please select a location',
                                                backgroundColor: Colors.red,
                                                fontSize: 19,
                                                textColor: Colors.white,
                                                gravity: ToastGravity.TOP);

                                            return;
                                          }
                                          // Perform action on submit button press
                                          Get.to(MapPage(
                                            isRedirected: true,
                                            representatives: _representatives,
                                          )); // Refresh bottom sheet with new data
                                        },
                                        text:
                                            "choose_location_manually_snackbar_button_text"
                                                .tr),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
                  ),
                ))
              ],
            ),
    );
  }
}
