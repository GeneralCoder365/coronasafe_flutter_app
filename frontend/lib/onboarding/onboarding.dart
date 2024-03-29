import 'package:coronasafe/homescreen/homescreen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/material.dart';
// import 'package:coronasafe/main.dart';

class Onboarding extends StatefulWidget {
  const Onboarding(
      {Key? key, required this.backgroundColor, required this.pages})
      : super(key: key);
  final Color? backgroundColor;

  final List<Pages> pages;
  @override
  OnboardingState createState() => OnboardingState();
}

class OnboardingState extends State<Onboarding> {
  final PageController _controller =
      PageController(initialPage: 0, viewportFraction: 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int indexter = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _controller,
            itemCount: widget.pages.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return widget.pages[index].widget;
            },
            onPageChanged: (int index) {
              setState(() {
                indexter = index;
              });
            },
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width / 24,
            right: MediaQuery.of(context).size.width / 2,
            child: Container(
              color: Colors.grey[999],
              padding: const EdgeInsets.all(20.0),
              child: AnimatedSmoothIndicator(
                activeIndex: indexter,
                count: widget.pages.length,
                effect: const WormEffect(
                  activeDotColor: Color(0xFFadd8eb),
                  dotHeight: 16,
                  spacing: 3,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2,
            right: MediaQuery.of(context).size.width / 24,
            child: Container(
              color: Colors.grey[999],
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  primary: const Color(0xFFadd8eb),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                onPressed: () {
                  if (widget.pages.length - 1 == indexter) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage()));
                  } else {
                    _controller.animateToPage(widget.pages.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease);
                  }
                },
                child: const Text(
                  'Finish',
                  style: TextStyle(
                    color: Color(0xFF121212),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: widget.backgroundColor,
    );
  }
}

class Pages {
  final Widget widget;

  Pages({
    required this.widget,
  });
}
