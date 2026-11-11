import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_gradients.dart';
import '../../routes/app_routes.dart';
import '../../widgets/gradient_button.dart';

class _SlideData {
  const _SlideData(this.icon, this.title, this.subtitle, this.gradient);

  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<_SlideData> _slides = [
    _SlideData(
      Icons.public_rounded,
      'Discover meaningful causes',
      'Explore volunteer opportunities and events from NGOs working on issues you care about.',
      AppGradients.primaryCompact,
    ),
    _SlideData(
      Icons.insights_rounded,
      'Track your impact',
      'Log volunteer hours, watch your progress, and earn achievements as you give back.',
      AppGradients.info,
    ),
    _SlideData(
      Icons.groups_rounded,
      'Join a caring community',
      'Connect with passionate volunteers and organizations building a better tomorrow together.',
      AppGradients.sunrise,
    ),
  ];

  int _current = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(BuildContext context, int page) {
    _pageController.animateToPage(
      page,
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
    );
  }

  void _finish(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _current == _slides.length - 1;

    return AnimatedContainer(
      duration: AppDurations.normal,
      decoration: BoxDecoration(gradient: _slides[_current].gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextButton(
                    onPressed: () => _finish(context),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _current = index),
                  itemBuilder: (context, index) {
                    final _SlideData slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                            ),
                            child: Icon(slide.icon, size: 84, color: Colors.white),
                          ),
                          const SizedBox(height: 44),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final bool active = index == _current;
                  return AnimatedContainer(
                    duration: AppDurations.normal,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: GradientButton(
                  label: isLast ? 'Get Started' : 'Next',
                  icon: isLast ? null : Icons.arrow_forward_rounded,
                  onPressed: () => isLast ? _finish(context) : _goTo(context, _current + 1),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}