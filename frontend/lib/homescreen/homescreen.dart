import 'package:coronasafe/resultscreen/resultscreen.dart';
import 'package:coronasafe/resultscreen/stategraphscreen.dart';
import 'package:coronasafe/resultscreen/usmapscreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:coronasafe/utils/place.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder2/geocoder2.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // with AfterLayoutMixin<MyHomePage> {
  final FixedExtentScrollController scrollController =
      FixedExtentScrollController();
  bool test = true;
  TextEditingController searchController = TextEditingController();
  List<Place> _suggestions = [];
  bool toggle = false;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void populateList(String query) async {
    var listylist = [];
    List<Place> newList = [];

    if (query.isEmpty) {
      _suggestions = newList;
    } else {
      Location location = Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();
      var locationDataString = _locationData.latitude.toString() +
          '%2C' +
          _locationData.longitude.toString();
      Dio _dio = Dio();
      var queryParameters = {'query': query, 'location': locationDataString};
      var data = await _dio.get(
          'https://coronasafe-flask-app.herokuapp.com/getPlaces',
          queryParameters: queryParameters);
      String fullString = data.toString();
      listylist = fullString.split('","');

      var listyListAccess = listylist.asMap();

      for (int i = 0; i < listyListAccess.length; i++) {
        var transitionString = listyListAccess[i].toString();

        var tempArray = transitionString.split(')');
        var tempArrayMap = tempArray.asMap();

        var otherStringyString = tempArrayMap[0].toString();
        var stringyString = tempArrayMap[1].toString();
        var anotherTempArray = stringyString.split('}');
        var anotherTempMap = anotherTempArray.asMap();
        var anotherStringyString = anotherTempMap[0];
        var finalAddressArray = anotherStringyString?.split('"');
        var finalTempArray = otherStringyString.split('(');

        newList.add(Place(
            address: finalAddressArray![0],
            name: finalTempArray[1],
            full: transitionString,
            percentage: 0));
      }
      setState(() {
        _suggestions = newList;
      });
    }
  }

  void _toggle() {
    setState(() {
      toggle = !toggle;
    });
  }

  _getToggleChild() {
    if (toggle) {
      return FadeInUp(
          from: MediaQuery.of(context).size.height / 2,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                _toggle();
              },
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 50,
                  right: MediaQuery.of(context).size.width / 50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 18,
                      width: MediaQuery.of(context).size.width / 1,
                      child: TextField(
                        controller: searchController,
                        onSubmitted: (query) {
                          populateList(query);
                          test = true;
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          filled: true,
                          hintText: 'Search...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFadd8eb),
                          ),
                          fillColor: Colors.grey[850],
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF303030)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF303030)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFadd8eb),
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFFadd8eb),
                        ),
                        // ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.2,
                      child: ImplicitlyAnimatedList<Place>(
                        items: _suggestions,
                        itemBuilder: (context, animation, item, i) {
                          return buildItem(context, item);
                        },
                        areItemsTheSame: (a, b) => a.name == b.name,
                        updateItemBuilder: (context, animation, item) {
                          return buildItem(context, item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
    } else {
      return FadeInDown(
          child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width / 50,
            right: MediaQuery.of(context).size.width / 50,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Image.asset(
                        'assets/coronasafe_full_logo_black_background.png')),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height / 50)),
                TextField(
                  controller: searchController,
                  onTap: () {
                    _toggle();
                  },
                  onSubmitted: (query) {
                    populateList(query);
                    test = true;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    hintText: 'Calculate Risk For...',
                    hintStyle: const TextStyle(
                      color: Color(0xFFadd8eb),
                    ),
                    fillColor: Colors.grey[850],
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF303030)),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF303030)),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFadd8eb),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(0xFFadd8eb),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height / 50)),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.15,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFFadd8eb))),
                        onPressed: () => {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const USMapScreen()))
                        },
                        child: const Icon(
                          Icons.map_outlined,
                          color: Color(0xFF121212),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 40)),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.15,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFFadd8eb))),
                        onPressed: () async {
                          Position position = await _determinePosition();

                          GeoData data = await Geocoder2.getDataFromCoordinates(
                              latitude: position.latitude,
                              longitude: position.longitude,
                              googleMapApiKey:
                                  String.fromEnvironment("G_API_KEY"));

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => StateGraphScreen(
                                      inputState: data.state)));
                        },
                        child: const Icon(
                          Icons.stacked_line_chart_outlined,
                          color: Color(0xFF121212),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: false,
      body: _getToggleChild(),
    );
  }

  int currentIndex = 0;
  void _showPicker(BuildContext context) {
    setState(() {});
    Future<LocationData> _locationData;
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 10,
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text(
                    'Select Your State',
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Color(0xFF302B34),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => {Navigator.of(context).maybePop()},
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: Center(
                      child: Icon(
                        Icons.clear,
                        size: 27,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoPicker.builder(
              useMagnifier: true,
              magnification: 1.07,
              squeeze: 1,
              diameterRatio: 10,
              offAxisFraction: 0.0,
              scrollController: scrollController,
              backgroundColor: Colors.white,
              onSelectedItemChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemExtent: 50,
              childCount: countryList.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                    '${countryList[index].data}',
                    style: const TextStyle(fontSize: 19.0),
                  ),
                );
              },
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                shadowColor: MaterialStateProperty.all(Colors.transparent),
              ),
              onPressed: () async {},
              child: Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0088FB),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Select State',
                      style: TextStyle(color: Colors.white, fontSize: 17.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final countryList = [
    const Text('Alabama'),
    const Text('Alaska'),
    const Text('Arizona'),
    const Text('Arkansas'),
    const Text('California'),
    const Text('Colorado'),
    const Text('Connecticut'),
    const Text('Delaware'),
    const Text('Florida'),
    const Text('Georgia'),
    const Text('Hawaii'),
    const Text('Idaho'),
    const Text('Illinois'),
    const Text('Indiana'),
    const Text('Iowa'),
    const Text('Kansas'),
    const Text('Kentucky'),
    const Text('Louisiana'),
    const Text('Maine'),
    const Text('Maryland'),
    const Text('Massachusetts'),
    const Text('Michigan'),
    const Text('Minnesota'),
    const Text('Mississippi'),
    const Text('Missouri'),
    const Text('Montana'),
    const Text('Nebraska'),
    const Text('Nevada'),
    const Text('New Hampshire'),
    const Text('New Jersey'),
    const Text('New Mexico'),
    const Text('New York'),
    const Text('North Carolina'),
    const Text('North Dakota'),
    const Text('Ohio'),
    const Text('Oklahoma'),
    const Text('Oregon'),
    const Text('Pennsylvania'),
    const Text('Rhode Island'),
    const Text('South Carolina'),
    const Text('South Dakota'),
    const Text('Tennessee'),
    const Text('Texas'),
    const Text('Utah'),
    const Text('Vermont'),
    const Text('Virginia'),
    const Text('Washington'),
    const Text('West Virginia'),
    const Text('Wisconsin'),
    const Text('Wyoming'),
  ];
}

Widget buildItem(BuildContext context, Place place) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: 19,
        child: Divider(
          color: Colors.grey[800],
          thickness: 1,
        ),
      ),
      InkWell(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 5,
            top: 5,
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 36,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: Icon(
                    Icons.place,
                    color: Color(0xFFadd8eb),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFF121212)),
                          elevation: MaterialStateProperty.all(0),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ResultScreen(place: place)));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: const TextStyle(color: Color(0xFFadd8eb)),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              place.address,
                              textAlign: TextAlign.left,
                              style: const TextStyle(color: Color(0xFFadd8eb)),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          ),
          // ),
        ),
      )
    ],
  );
}
