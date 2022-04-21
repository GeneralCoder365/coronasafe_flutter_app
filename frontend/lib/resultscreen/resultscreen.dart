import 'package:coronasafe/resultscreen/stategraphscreen.dart';
import 'package:coronasafe/resultscreen/usmapscreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:coronasafe/resultscreen/utils/barchart.dart';
import 'package:coronasafe/utils/place.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key, required this.place}) : super(key: key);
  final Place place;

  @override
  // ignore: no_logic_in_create_state
  State<ResultScreen> createState() => _ResultScreenState(place: place);
}

class _ResultScreenState extends State<ResultScreen> {
  // ignore: unused_element
  _ResultScreenState({Key? key, required this.place}) : yesString = place.name;
  String yesString;
  final Place place;
  late double percentage;
  late String _urlQueryString;
  String fullString = '';

  void buildBody(String query) async {
    List listylist = [];
    Dio _dio = Dio();

    var queryParameters = {'address': query};

    var data = await _dio.get(
        'http://coronasafe-flask-app.herokuapp.com/getRisk',
        queryParameters: queryParameters);

    var data2 = await _dio
        .get('http://coronasafe-flask-app.herokuapp.com/getUSCaseMap');

    var initialGraphString = data2.data.toString();

    var takeAwayFront = initialGraphString.split("a:");
    var frontTakenAwayString = takeAwayFront[1];

    var takeBackAway = frontTakenAwayString.split("}");

    var finalGraphUrlString = takeBackAway[0];

    var takeAwaySpace = finalGraphUrlString.split(" ");

    if (!mounted) return;
    var newString = data.data.toString();

    listylist = newString.split(':');

    fullString = listylist[1].toString();
    var tempArray = fullString.split('}');
    var string = tempArray[0];
    percentage = double.parse(string);
    setState(() {
      _urlQueryString = takeAwaySpace[1];
      place.percentage = percentage;
    });
  }

  Color chooseColors() {
    if (place.percentage > 67) {
      return Colors.redAccent;
    } else if (place.percentage > 33) {
      return Colors.yellowAccent;
    } else {
      return Colors.greenAccent;
    }
  }

  String getChancesName() {
    if (place.percentage > 67) {
      return 'HIGH';
    } else if (place.percentage > 33) {
      return 'MEDIUM';
    } else {
      return 'LOW';
    }
  }

  @override
  void initState() {
    super.initState();
    buildBody(place.full);
  }

  final infoSelectionController = TextEditingController();
  String? selectedValue;
  final List<String> _list = ['US Case Map', 'State Case Graph'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SizedBox(
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding:
                          const EdgeInsets.only(bottom: 5, left: 10, right: 50),
                      width: double.infinity,
                      child: Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontFamily: 'Manrope',
                          color: Color(0xFFadd8eb),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      getChancesName(),
                      style: TextStyle(
                        fontSize: 45,
                        color: chooseColors(),
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 1.4,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    color: const Color(0xFF121212),
                    child: MyBarChart(place: place),
                  ),
                ),
              ),
              CustomDropdown(
                items: _list,
                controller: infoSelectionController,
                onChanged: (selected) {
                  if (selected == 'US Case Map') {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const USMapScreen()));
                  } else if (selected == 'State Case Graph') {
                    var takingPlace = place.address.split(",");

                    var yes = takingPlace[2].replaceAll(RegExp('[0-9]'), '');

                    print(yes);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => StateGraphScreen(
                              inputState: fullStateNameFromAbbreviation(
                                  yes.toUpperCase()),
                            )));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  int currentIndex = 0;
  void _showPicker(BuildContext context) {
    setState(() {});
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
              onPressed: () => {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => StateGraphScreen(
                        inputState: countryList[currentIndex].data)))
              },
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

  final FixedExtentScrollController scrollController =
      FixedExtentScrollController(
    initialItem: 0,
  );
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

String fullStateNameFromAbbreviation(String input) {
  switch (input) {
    case 'MD':
      {
        return "maryland";
      }
    default:
      {
        return "maryland";
      }
  }
}
