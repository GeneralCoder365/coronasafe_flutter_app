import 'package:flutter/material.dart';
import 'onboarding.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({Key? key}) : super(key: key);
  final onboardingPagesList = [
    Pages(
      widget: Column(
        children: [
          Container(
              padding: const EdgeInsets.only(top: 50, left: 10.0, right: 10.0),
              child: Image.asset(
                  'assets/coronasafe_full_logo_black_background.png')),
          Container(
              padding: const EdgeInsets.only(
                  bottom: 5, top: 20, left: 10, right: 50),
              width: double.infinity,
              child: const Text('Worried About Covid?',
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'CenturyGothic',
                    color: Colors.white,
                  ))),
          Container(
            padding: const EdgeInsets.only(bottom: 20, left: 10, right: 50),
            width: double.infinity,
            child: const Text(
              'We Get It',
              style: TextStyle(
                fontFamily: 'CenturyGothic',
                fontSize: 15,
                color: Color(0xFFadd8eb),
              ),
            ),
          ),
        ],
      ),
    ),
    Pages(
      widget: Column(
        children: [
          Container(
              padding: const EdgeInsets.only(top: 50, left: 10.0, right: 10.0),
              child: Image.asset(
                  'assets/coronasafe_full_logo_black_background.png')),
          Container(
              padding: const EdgeInsets.only(
                  bottom: 5, top: 20, left: 10, right: 50),
              width: double.infinity,
              child: const Text('That\'s why we made CoronaSafe',
                  style: TextStyle(
                    fontFamily: 'CenturyGothic',
                    fontSize: 25,
                    color: Colors.white,
                  ))),
          Container(
            padding: const EdgeInsets.only(bottom: 20, left: 10, right: 50),
            width: double.infinity,
            child: const Text(
              'We wanted to create an application that informed people about their chances of contracting COVID-19.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFadd8eb),
                fontFamily: 'CenturyGothic',
              ),
            ),
          ),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Onboarding(
        backgroundColor: const Color(0xFF121212),
        pages: onboardingPagesList,
      ),
    );
  }
}
