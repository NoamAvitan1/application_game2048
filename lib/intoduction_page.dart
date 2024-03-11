import 'package:flutter/material.dart';
import 'package:application_game2048/game.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            children: const [
               AnimatedPage(
                color: Colors.red,
                text: "assets/images/right.png",
                direction: AxisDirection.right,
              ),
              AnimatedPage(
                color: Colors.blue,
                text: "assets/images/left.png",
                direction: AxisDirection.left,
              ),
              AnimatedPage(
                color: Colors.green,
                text: "assets/images/up.png",
                direction: AxisDirection.up,
              ),
              AnimatedPage(
                color: Colors.orange,
                text: "assets/images/down.png",
                direction: AxisDirection.down,
              ),
            ],
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPageIndex < 3) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const Game(),
                  ));
                }
              },
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPage extends StatelessWidget {
  final Color color;
  final String text;
  final AxisDirection direction;

  const AnimatedPage({
    Key? key,
    required this.color,
    required this.text,
    required this.direction,
  }) : super(key: key);

   @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Expanded(
              child: Padding(
                padding:  const EdgeInsets.all(16.0), 
                child: Image.asset(text, fit: BoxFit.contain)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

