import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:gemini_chatbot/main_screens/home_screen_maaz.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(const Duration(seconds: 4), ()
    {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreenMaaz(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Define the animation curve and duration
            const curve = Curves.easeInOut;
            //const duration = Duration(milliseconds: 500);

            // Scale transition
            final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
            );

            // Fade transition
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
    );
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return Scaffold(
      body: Container(
        height: height*1,
        width: width*1,
        color: Colors.blueGrey.shade400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: height*.23),
              child: Image.asset(
                'images/ic_launcher.png',
                //fit: BoxFit.cover,
                width: width * .35,
                height: height * .35,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: height* .2),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading ',
                    style: TextStyle(
                      letterSpacing: .3,
                      color:Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    ' ChatBot',
                    style: TextStyle(
                      letterSpacing: .3,
                      color:Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .04,),
            const SpinKitFoldingCube(
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
