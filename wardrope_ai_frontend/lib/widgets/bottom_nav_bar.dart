import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.checkroom_outlined,
      activeIcon: Icons.checkroom,
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
    NavigationItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
    ),
    NavigationItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);

=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return Container(
      height: 92.h, // Increased to accommodate larger navbar
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          height: 76.h,
          decoration: BoxDecoration(
<<<<<<< HEAD
            color: cardColor,
            borderRadius: BorderRadius.circular(20.r), // Less rounded - subtle curve
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
=======
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r), // Less rounded - subtle curve
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                blurRadius: 20,
                offset: Offset(0, 8.h),
              ),
              BoxShadow(
<<<<<<< HEAD
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.04),
=======
                color: Colors.black.withValues(alpha: 0.04),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                blurRadius: 4,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = widget.currentIndex == index;

                return Expanded(
                  child: _AnimatedNavItem(
                    isSelected: isActive,
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onTap(index);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
  });
}

class _AnimatedNavItem extends StatefulWidget {
  final bool isSelected;
  final IconData icon;
  final IconData activeIcon;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.isSelected,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(_AnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark
        ? Colors.grey.shade400
        : Colors.black.withValues(alpha: 0.6);

=======
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
    return GestureDetector(
      onTap: () {
        // Quick scale animation on tap
        if (!widget.isSelected) {
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
        }
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 56.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: widget.isSelected ? activeColor : Colors.transparent,
=======
                color: widget.isSelected ? Colors.black : Colors.transparent,
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                borderRadius: BorderRadius.circular(20.r), // More rounded to match pill shape
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
<<<<<<< HEAD
                          color: activeColor.withValues(alpha: 0.15),
=======
                          color: Colors.black.withValues(alpha: 0.15),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                          blurRadius: 8,
                          offset: Offset(0, 2.h),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Transform.scale(
                  scale: widget.isSelected ? _iconScaleAnimation.value : 1.0,
                  child: Icon(
                    widget.isSelected ? widget.activeIcon : widget.icon,
                    size: 24.w,
                    color: widget.isSelected
<<<<<<< HEAD
                        ? isDark ? Colors.black : Colors.white
                        : inactiveColor,
=======
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.6),
>>>>>>> a383de17757c823bdb4441debf3917d342ff8b19
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}