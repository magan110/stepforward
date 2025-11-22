import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:step_counter_app/features/home/widgets/premium_stat_card.dart';
import 'package:step_counter_app/features/home/widgets/premium_circular_progress.dart';
import 'package:step_counter_app/services/step_service.dart';
import 'package:step_counter_app/services/storage_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:step_counter_app/features/profile/profile_screen.dart';
import 'package:step_counter_app/features/gamification/achievements_screen.dart';
import 'package:step_counter_app/features/leaderboard/leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Consumer2<StepService, StorageService>(
          builder: (context, stepService, storageService, child) {
            final steps = stepService.steps;
            final goal = storageService.getDailyGoal();
            final calories = stepService.calories.toStringAsFixed(0);
            final distance = stepService.distance.toStringAsFixed(2);
            final time = stepService.activeTime.toString();
            final level = storageService.getLevel();
            final progress = (steps / goal).clamp(0.0, 1.0);
            final date = DateTime.now();
            final formattedDate =
                "${date.day} ${_getMonthName(date.month)} ${date.year}";

            return Screenshot(
              controller: _screenshotController,
              child: Column(
                children: [
                  // Enhanced Header with Date
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Today\'s Progress',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        // Profile Avatar
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          ),
                          child: Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Level Badge
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 8.h,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Level $level',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Progress Circle with Enhanced Visuals
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 24.h),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer ring with gradient
                                    Container(
                                      width: 280.w,
                                      height: 280.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Progress Circle
                                    PremiumCircularProgress(
                                      steps: steps,
                                      goal: goal,
                                      size: 260.w,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Motivational Message
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 8.h,
                            ),
                            child: Text(
                              _getMotivationalMessage(progress),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),

                          // --- FIXED STATS SECTION ---
                          // Replaced GridView with a Row of Expanded widgets to prevent overflow
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 24.h,
                            ),
                            height: 160
                                .h, // Define a fixed height for the row of cards
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    Icons.local_fire_department_rounded,
                                    'Calories',
                                    calories,
                                    const Color(0xFFFF6584),
                                    const Color(0xFFFF8FA3),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    Icons.route_rounded,
                                    'Distance',
                                    '$distance km',
                                    const Color(0xFF00F5D4),
                                    const Color(0xFF00D4AA),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    Icons.timer_rounded,
                                    'Time',
                                    '$time min',
                                    const Color(0xFF6C63FF),
                                    const Color(0xFF8B83FF),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quick Actions
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 16.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  context,
                                  Icons.emoji_events_rounded,
                                  'Achievements',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AchievementsScreen(),
                                    ),
                                  ),
                                  Theme.of(context).colorScheme.tertiary,
                                ),
                                _buildActionButton(
                                  context,
                                  Icons.leaderboard_rounded,
                                  'Leaderboard',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LeaderboardScreen(),
                                    ),
                                  ),
                                  Theme.of(context).colorScheme.secondary,
                                ),
                                _buildActionButton(
                                  context,
                                  Icons.share_rounded,
                                  'Share',
                                  () => _shareStats(steps, distance, calories),
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),

                          // Bottom padding
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color gradientStart,
    Color gradientEnd,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w), // Reduced padding slightly
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Center align text
          children: [
            Icon(icon, color: Colors.white, size: 32.sp),
            SizedBox(height: 8.h),
            FittedBox(
              // Ensures text scales down if it's too long
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getMotivationalMessage(double progress) {
    if (progress < 0.25) {
      return "Great start! Every step counts! 💪";
    } else if (progress < 0.5) {
      return "You're making progress! Keep going! 🚶";
    } else if (progress < 0.75) {
      return "More than halfway there! You've got this! 🎯";
    } else if (progress < 1.0) {
      return "Almost there! Push to the finish line! 🔥";
    } else {
      return "Goal achieved! You're a champion! 🏆";
    }
  }

  Future<void> _shareStats(int steps, String distance, String calories) async {
    final imagePath = await _screenshotController.captureAndSave(
      (await getTemporaryDirectory()).path,
      fileName: 'step_stats_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    if (imagePath != null) {
      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            'I walked $steps steps today! That\'s $distance km and $calories kcal! #StepCounter',
      );
    }
  }
}
