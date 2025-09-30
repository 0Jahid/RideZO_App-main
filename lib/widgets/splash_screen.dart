import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../animation/fade_animation.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextPage;

  const SplashScreen({Key? key, required this.nextPage}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _scale2Controller;
  late AnimationController _widthController;
  late AnimationController _positionController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _scale2Animation;
  late Animation<double> _widthAnimation;
  late Animation<double> _positionAnimation;

  bool hideIcon = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(_scaleController)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _widthController.forward();
      }
    });

    _widthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _widthAnimation = Tween<double>(
      begin: 80.0,
      end: 300.0,
    ).animate(_widthController)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _positionController.forward();
      }
    });

    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: 215.0,
    ).animate(_positionController)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          hideIcon = true;
        });
        _scale2Controller.forward();
      }
    });

    _scale2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale2Animation = Tween<double>(
      begin: 1.0,
      end: 32.0,
    ).animate(_scale2Controller)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          PageTransition(type: PageTransitionType.fade, child: widget.nextPage),
        );
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _scale2Controller.dispose();
    _widthController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: <Widget>[
          // Background animations
          Positioned(
            top: -50,
            left: 0,
            child: FadeAnimation(
              1,
              Container(
                width: width,
                height: 400,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/one.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: 0,
            child: FadeAnimation(
              1.3,
              Container(
                width: width,
                height: 400,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/one.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -150,
            left: 0,
            child: FadeAnimation(
              1.6,
              Container(
                width: width,
                height: 400,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/one.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Text and button
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FadeAnimation(
                  1,
                  Text(
                    "Welcome",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                FadeAnimation(
                  1.3,
                  Text(
                    "Get ready for seamless rides and \neffortless journeys with RideZO.",
                    style: TextStyle(
                      color: colorScheme.primary.withOpacity(0.85),
                      height: 1.4,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 180),
                FadeAnimation(
                  1.6,
                  AnimatedBuilder(
                    animation: _scaleController,
                    builder:
                        (context, child) => Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _widthController,
                              builder:
                                  (context, child) => Container(
                                    width: _widthAnimation.value,
                                    height: 80,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: primary.withOpacity(.4),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        _scaleController.forward();
                                      },
                                      child: Stack(
                                        children: <Widget>[
                                          AnimatedBuilder(
                                            animation: _positionController,
                                            builder:
                                                (context, child) => Positioned(
                                                  left:
                                                      _positionAnimation.value,
                                                  child: AnimatedBuilder(
                                                    animation:
                                                        _scale2Controller,
                                                    builder:
                                                        (
                                                          context,
                                                          child,
                                                        ) => Transform.scale(
                                                          scale:
                                                              _scale2Animation
                                                                  .value,
                                                          child: Container(
                                                            width: 60,
                                                            height: 60,
                                                            decoration:
                                                                BoxDecoration(
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                  color:
                                                                      primary,
                                                                ),
                                                            child:
                                                                hideIcon ==
                                                                        false
                                                                    ? Icon(
                                                                      Icons
                                                                          .airport_shuttle,
                                                                      color:
                                                                          onPrimary,
                                                                    )
                                                                    : Container(),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
