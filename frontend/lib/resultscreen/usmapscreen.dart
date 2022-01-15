import 'dart:convert';

import 'package:coronasafe/homescreen/homescreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class USMapScreen extends StatefulWidget {
  const USMapScreen({Key? key}) : super(key: key);

  @override
  State<USMapScreen> createState() => _USMapScreenState();
}

class _USMapScreenState extends State<USMapScreen> {
  late WebViewController _controller;
  @override
  Widget build(BuildContext context) {
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
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller = webViewController;
                    _loadHtmlFromAssets();
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

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('assets/temp-plot.html');
    _controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
