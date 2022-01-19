import 'package:after_layout/after_layout.dart';
import 'package:coronasafe/resultscreen/resultscreen.dart';
import 'package:coronasafe/resultscreen/usmapscreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:coronasafe/utils/place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:animate_do/animate_do.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AfterLayoutMixin<MyHomePage> {
  bool test = true;
  TextEditingController searchController = TextEditingController();
  List<Place> _suggestions = [];
  bool toggle = false;

  void populateList(String query) async {
    var listylist = [];
    List<Place> newList = [];

    if (query.isEmpty) {
      _suggestions = newList;
    } else {
      Dio _dio = Dio();
      var queryParameters = {'search_query': query};
      var data = await _dio.get(
          'http://coronasafe-flask-app.herokuapp.com/getPlaces/',
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
          child: SafeArea(
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

                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    hintText: 'Search...',
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
      ));
    } else {
      return SlideInDown(
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
                const Padding(padding: EdgeInsets.only(bottom: 10)),
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
                    hintText: 'Search For A Place You\'ve Been...',
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
                        top: MediaQuery.of(context).size.height / 2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.1,
                      child: Align(
                        alignment: Alignment.bottomLeft,
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
                    ),
                    const Spacer(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xFFadd8eb))),
                          onPressed: () =>
                              {_openSimpleItemPicker(context, countryList)},
                          child: const Icon(
                            Icons.add_chart_outlined,
                            color: Color(0xFF121212),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
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

  void _openSimpleItemPicker(BuildContext context, List<Text> items) {
    BottomPicker(
      items: items,
      title: 'Choose your state',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Color(0xFFadd8eb),
      ),
      backgroundColor: const Color(0xFF121212),
      bottomPickerTheme: BOTTOM_PICKER_THEME.morningSalad,
      onSubmit: (index) {
        print(items[index]);
      },
    ).show(context);
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
                                style:
                                    const TextStyle(color: Color(0xFFadd8eb)),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                place.address,
                                textAlign: TextAlign.left,
                                style:
                                    const TextStyle(color: Color(0xFFadd8eb)),
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

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _taught = (prefs.getBool('taught') ?? false);

    if (_taught) {
      test = true;
    } else {
      await prefs.setBool('taught', true);
      test = false;
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();
}
