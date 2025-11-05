import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/bottom_nav_bar.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../bloc/wardrobe/wardrobe_bloc.dart';
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
  late final List<Widget> _screens;
  late AnimationController _pageTransitionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;

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

    // Initialize app state immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _initializeApp() {
    if (!_isInitialized) {
      _isInitialized = true;

      // Initialize wardrobe bloc first
      context.read<WardrobeBloc>().add(WardrobeLoadItems());

      // Ensure navigation starts at wardrobe (index 0) and trigger navigation event
      final currentState = context.read<NavigationBloc>().state;
      if (currentState.currentIndex != 0) {
        context.read<NavigationBloc>().add(const NavigationTabChanged(0));
      } else {
        // Force trigger navigation to ensure first screen renders properly
        context.read<NavigationBloc>().add(const NavigationTabChanged(0));
      }
    }
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listener: (context, state) {
        // Handle navigation animations
        if (state.currentIndex != state.previousIndex) {
          final isMovingForward = state.currentIndex > state.previousIndex;

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
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Main Content
              Expanded(
                child: BlocBuilder<NavigationBloc, NavigationState>(
                  builder: (context, navState) {
                    return AnimatedBuilder(
                      animation: _pageTransitionController,
                      builder: (context, child) {
                        // For initial load or when indices are the same, show the current screen directly
                        if (navState.currentIndex == navState.previousIndex) {
                          return _screens[navState.currentIndex];
                        }

                        return Stack(
                          children: [
                            // Previous page (fading out)
                            if (navState.currentIndex != navState.previousIndex)
                              Positioned.fill(
                                child: FadeTransition(
                                  opacity: _fadeAnimation.drive(
                                    Tween<double>(begin: 1.0, end: 0.0),
                                  ),
                                  child: _screens[navState.previousIndex],
                                ),
                              ),
                            // Current page (sliding in)
                            Positioned.fill(
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: _screens[navState.currentIndex],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom Navigation
              BlocBuilder<NavigationBloc, NavigationState>(
                builder: (context, navState) {
                  return BottomNavBar(
                    currentIndex: navState.currentIndex,
                    onTap: (index) {
                      context.read<NavigationBloc>().add(NavigationTabChanged(index));
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}