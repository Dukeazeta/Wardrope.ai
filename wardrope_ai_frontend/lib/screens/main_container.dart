import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'wardrobe_screen.dart';
import 'model_screen.dart';
import 'ai_stylist_screen.dart';
import 'profile_screen.dart';

class MainContainer extends StatefulWidget {
  final Map<String, dynamic>? imageData;

  const MainContainer({
    super.key,
    this.imageData,
  });

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;

  late final List<Widget> _screens;
  late AnimationController _pageTransitionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _screens = [
      WardrobeScreen(imageData: widget.imageData),
      const ModelScreen(),
      const AIStylistScreen(),
      const ProfileScreen(),
    ];

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutQuart,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _onPageChange(int newIndex) {
    if (newIndex != _currentIndex) {
      setState(() {
        _previousIndex = _currentIndex;
        _currentIndex = newIndex;
      });

      // Determine slide direction
      final isMovingForward = newIndex > _previousIndex;

      if (isMovingForward) {
        _slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _pageTransitionController,
          curve: Curves.easeOutQuart,
        ));
      } else {
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _pageTransitionController,
          curve: Curves.easeOutQuart,
        ));
      }

      _pageTransitionController.reset();
      _pageTransitionController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: AnimatedBuilder(
                animation: _pageTransitionController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Previous page (fading out)
                      if (_previousIndex != _currentIndex)
                        Positioned.fill(
                          child: FadeTransition(
                            opacity: _fadeAnimation.drive(
                              Tween<double>(begin: 1.0, end: 0.0),
                            ),
                            child: _screens[_previousIndex],
                          ),
                        ),
                      // Current page (sliding in)
                      Positioned.fill(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _screens[_currentIndex],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Navigation
            BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onPageChange,
            ),
          ],
        ),
      ),
    );
  }
}