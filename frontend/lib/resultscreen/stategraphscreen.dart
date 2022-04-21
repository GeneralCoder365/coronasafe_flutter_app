import 'package:coronasafe/homescreen/homescreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// #TODO: some states aren't fully popping up (lost counties)
class StateGraphScreen extends StatefulWidget {
  final String? inputState;

  const StateGraphScreen({Key? key, this.inputState}) : super(key: key);

  @override
  State<StateGraphScreen> createState() =>
      _StateGraphScreenState(inputState: inputState);
}

class _StateGraphScreenState extends State<StateGraphScreen> {
  late WebViewController _controller;

  String? inputState;
  // ignore: unused_element
  _StateGraphScreenState({Key? key, required this.inputState});
  Future<String> getData(String? query) async {
    query = query?.toLowerCase();
    print(query);
    Dio _dio = Dio();
    var queryParameters = {'state': query};
    var data2 = await _dio.get(
        'http://coronasafe-flask-app.herokuapp.com/getUSStateCaseMap',
        queryParameters: queryParameters);

    var initialGraphString = data2.data.toString();

    var takeAwayFront = initialGraphString.split("a:");
    var frontTakenAwayString = takeAwayFront[1];

    var takeBackAway = frontTakenAwayString.split("}");

    var finalGraphUrlString = takeBackAway[0];

    var takeAwaySpace = finalGraphUrlString.split(" ");
    return takeAwaySpace[1];
  }

  @override
  Widget build(BuildContext context) {
    getData(inputState);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFF121212))),
                      onPressed: () => {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const MyHomePage()))
                          },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFFadd8eb),
                          ),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFFadd8eb),
                            ),
                          )
                        ],
                      )),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.2,
                child: WebView(
                  initialUrl: 'about:blank',
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  onWebViewCreated:
                      (WebViewController webViewController) async {
                    _controller = webViewController;
                    String _urlQueryString = await getData(this.inputState);
                    _controller.loadUrl(_urlQueryString);
                  },
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    // 2
                    Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer()),
                    Factory<HorizontalDragGestureRecognizer>(
                        () => HorizontalDragGestureRecognizer()),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
