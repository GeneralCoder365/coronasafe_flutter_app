import 'package:flutter/material.dart';
import 'package:coronasafe/homescreen/homescreen.dart';
import 'onboardingsetup.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckOnboarding extends StatefulWidget {
  const CheckOnboarding({Key? key}) : super(key: key);

  @override
  CheckOnboardingState createState() => CheckOnboardingState();
}

class CheckOnboardingState extends State<CheckOnboarding>
    with AfterLayoutMixin<CheckOnboarding> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()));
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => OnboardingScreen()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}
