import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ChooseLocationPage extends StatefulWidget {
  ChooseLocationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ChooseLocationPageState createState() => _ChooseLocationPageState();
}

class _ChooseLocationPageState extends State<ChooseLocationPage> {
  GoogleMapController mapController;
  String searchAddress;
  List<Marker> markerList = [];
  LatLng location;
  Position currentPos;
  var _isLoading = false;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    getCurrentLocation();
    setState(() {
      _isLoading = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  // Gets the user's current position
  Future<void> getCurrentLocation() async {
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentPos = pos;
    });
  }

  // Set map controller
  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  // Find search location and set marker on map
  Future<void> searchAndSetLocation() async {
    List<Location> results = await locationFromAddress(searchAddress);

    // update location
    location = LatLng(results.first.latitude, results.first.longitude);

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(results.first.latitude, results.first.longitude),
          zoom: 16.0,
        ),
      ),
    );

    // set marker on screen
    markerList = [];
    setState(() {
      markerList.add(
        Marker(
          markerId: MarkerId('marker'),
          position: LatLng(results.first.latitude, results.first.longitude),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.90,
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: onMapCreated,
                        myLocationEnabled: true,
                        markers: Set.from(markerList),
                        initialCameraPosition: CameraPosition(
                          target:
                              LatLng(currentPos.latitude, currentPos.longitude),
                          zoom: 10.0,
                        ),
                      ),
                      Positioned(
                        top: 40.0,
                        right: 20.0,
                        left: 20.0,
                        child: Material(
                          elevation: 16.0,
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            height: 50.0,
                            width: MediaQuery.of(context).size.width * 0.90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white,
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter a city, state, or zip',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    left: 15.0, top: 15.0),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: searchAndSetLocation,
                                  iconSize: 30.0,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchAddress = value;
                                });
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: 40,
                  color: Colors.white,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    disabledColor: Colors.grey[400],
                    disabledTextColor: Colors.black54,
                    onPressed: markerList.isEmpty
                        ? null
                        : () {
                            print(
                                'lat: ${location.latitude}, lng: ${location.longitude}');
                          },
                    child: Text('Continue',
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                    color: Colors.red,
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
