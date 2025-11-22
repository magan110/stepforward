import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_counter_app/services/step_service.dart';
import 'package:step_counter_app/services/storage_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboard(context, isDaily: true),
          _buildLeaderboard(context, isDaily: false),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, {required bool isDaily}) {
    final stepService = context.watch<StepService>();
    final storageService = context.watch<StorageService>();
    final userSteps = stepService.steps;
    final lifetimeSteps = storageService.getLifetimeSteps();

    // Generate mock leaderboard data
    final leaderboardData = _generateMockLeaderboard(
      userSteps: isDaily ? userSteps : lifetimeSteps,
      isDaily: isDaily,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: leaderboardData.length,
      itemBuilder: (context, index) {
        final entry = leaderboardData[index];
        final isCurrentUser = entry['isUser'] as bool? ?? false;
        final rank = index + 1;

        return _buildLeaderboardCard(
          context,
          rank: rank,
          name: entry['name'] as String,
          steps: entry['steps'] as int,
          isCurrentUser: isCurrentUser,
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateMockLeaderboard({
    required int userSteps,
    required bool isDaily,
  }) {
    // Mock data - in a real app, this would come from a backend
    final mockUsers = [
      {'name': 'Sarah Johnson', 'steps': isDaily ? 15420 : 125000},
      {'name': 'Mike Chen', 'steps': isDaily ? 14890 : 118000},
      {'name': 'Emma Wilson', 'steps': isDaily ? 13200 : 110000},
      {'name': 'You', 'steps': userSteps, 'isUser': true},
      {'name': 'Alex Kumar', 'steps': isDaily ? 11500 : 95000},
      {'name': 'Lisa Brown', 'steps': isDaily ? 10800 : 88000},
      {'name': 'Tom Davis', 'steps': isDaily ? 9500 : 82000},
      {'name': 'Rachel Green', 'steps': isDaily ? 8900 : 75000},
    ];

    // Sort by steps descending
    mockUsers.sort((a, b) => (b['steps'] as int).compareTo(a['steps'] as int));

    return mockUsers;
  }

  Widget _buildLeaderboardCard(
    BuildContext context, {
    required int rank,
    required String name,
    required int steps,
    required bool isCurrentUser,
  }) {
    Color? rankColor;
    IconData? medalIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      medalIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      medalIcon = Icons.emoji_events_rounded;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      medalIcon = Icons.emoji_events_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 40,
              child: medalIcon != null
                  ? Icon(medalIcon, color: rankColor, size: 32)
                  : Text(
                      '$rank',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            const SizedBox(width: 16),
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: isCurrentUser
                  ? Theme.of(context).primaryColor
                  : Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
              child: Text(
                name[0].toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser
                      ? Colors.white
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // Steps
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  steps.toString(),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  'steps',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
