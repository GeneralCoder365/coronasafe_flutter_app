import 'package:coronasafe/homescreen/homescreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class USMapScreen extends StatefulWidget {
  const USMapScreen({Key? key}) : super(key: key);

  @override
  State<USMapScreen> createState() => _USMapScreenState();
}

class _USMapScreenState extends State<USMapScreen> {
  late WebViewController _controller;
  late String _urlQueryString;

  Future<String> getData() async {
    Dio _dio = Dio();
    var data2 = await _dio
        .get('http://coronasafe-flask-app.herokuapp.com/getUSCaseMap');

    var initialGraphString = data2.data.toString();

    var takeAwayFront = initialGraphString.split("a:");
    var frontTakenAwayString = takeAwayFront[1];

    var takeBackAway = frontTakenAwayString.split("}");

    var finalGraphUrlString = takeBackAway[0];

    var takeAwaySpace = finalGraphUrlString.split(" ");
    print(takeAwaySpace[1]);
    return takeAwaySpace[1];
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      getData();
    });
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
                    String _urlQueryString = await getData();
                    _controller = webViewController;

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
