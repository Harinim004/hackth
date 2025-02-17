import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final Function() onSkip;

  const OnboardingScreen({super.key, required this.onSkip});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildOnboardingPage(
                image: 'assets/Flux_Dev_i_need_3d_animation_images_for_initializing_of_a_app__0.jpg',
                title: 'Welcome',
                description: 'Get started with our app',
              ),
              _buildOnboardingPage(
                image: 'assets/onboard2.jpeg',
                title: 'Easy Navigation',
                description: 'Find what you need quickly',
              ),
              _buildOnboardingPage(
                image: 'assets/Flux_Dev_i_need_3d_animation_images_for_initializing_of_a_app__2.jpg',
                title: 'Stay Connected',
                description: 'Access important features',
              ),
              _buildOnboardingPage(
                image: 'assets/Flux_Dev_A_series_of_animated_images_showcasing_the_initializa_3.jpeg',
                title: 'Quick Access',
                description: 'Get help when you need it',
              ),
              _buildOnboardingPage(
                image: 'assets/Flux_Dev_i_need_animation_images_for_initialzing_of_a_app_whic_1.jpg',
                title: 'Ready to Go',
                description: 'Start using the app now',
              ),
            ],
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: widget.onSkip,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
