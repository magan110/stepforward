import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_counter_app/services/storage_service.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();
    final lifetimeSteps = storageService.getLifetimeSteps();
    final level = storageService.getLevel();
    final unlockedBadges = storageService.getUnlockedBadges();

    // Simple level calculation: Level = (Lifetime Steps / 10000) + 1
    final calculatedLevel = (lifetimeSteps / 10000).floor() + 1;
    if (calculatedLevel > level) {
      storageService.saveLevel(calculatedLevel);
      _confettiController.play();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Level Circle
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Level',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$calculatedLevel',
                        style: GoogleFonts.outfit(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Total Steps: $lifetimeSteps',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Badges',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _badges.length,
                  itemBuilder: (context, index) {
                    final badge = _badges[index];
                    final isUnlocked =
                        unlockedBadges.contains(badge.id) ||
                        lifetimeSteps >= badge.requiredSteps;

                    if (isUnlocked && !unlockedBadges.contains(badge.id)) {
                      // Unlock it now
                      storageService.unlockBadge(badge.id);
                    }

                    return Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isUnlocked
                                ? Theme.of(
                                    context,
                                  ).colorScheme.tertiary.withValues(alpha: 0.2)
                                : Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.1),
                            border: isUnlocked
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Icon(
                            badge.icon,
                            size: 36,
                            color: isUnlocked
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          badge.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isUnlocked
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).disabledColor,
                            fontWeight: isUnlocked
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.tertiary,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Badge {
  final String id;
  final String name;
  final int requiredSteps;
  final IconData icon;

  const Badge({
    required this.id,
    required this.name,
    required this.requiredSteps,
    required this.icon,
  });
}

final List<Badge> _badges = [
  const Badge(
    id: 'first_step',
    name: 'First Step',
    requiredSteps: 1,
    icon: Icons.directions_walk_rounded,
  ),
  const Badge(
    id: 'walker',
    name: 'Walker',
    requiredSteps: 10000,
    icon: Icons.hiking_rounded,
  ),
  const Badge(
    id: 'runner',
    name: 'Runner',
    requiredSteps: 50000,
    icon: Icons.run_circle_rounded,
  ),
  const Badge(
    id: 'marathon',
    name: 'Marathoner',
    requiredSteps: 100000,
    icon: Icons.emoji_events_rounded,
  ),
  const Badge(
    id: 'master',
    name: 'Step Master',
    requiredSteps: 500000,
    icon: Icons.workspace_premium_rounded,
  ),
  const Badge(
    id: 'legend',
    name: 'Legend',
    requiredSteps: 1000000,
    icon: Icons.star_rounded,
  ),
];
