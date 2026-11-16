import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/round.dart';

/// The green "LIVE" card from the Figma home screen.
class LiveStatusCard extends StatelessWidget {
  const LiveStatusCard({
    super.key,
    required this.round,
    required this.position,
    required this.totalRounds,
    required this.use24Hour,
    this.now,
  });
  final Round round;
  final int position;
  final int totalRounds;
  final bool use24Hour;

  /// Used by tests to get a fixed "Updated ... ago" text.
  final DateTime? now;
  String get _subtitle {
    final String departs = Formatters.time(
      round.departureTime,
      use24Hour: use24Hour,
    );
    if (round.note != null && round.note!.trim().isNotEmpty) {
      return round.note!.trim();
    }
    if (round.status == RoundStatus.planned) {
      return 'Leaves campus at $departs';
    }
    if (round.isFinished) {
      return 'This round has finished';
    }
    return 'Left campus at $departs';
  }

  @override
  Widget build(BuildContext context) {
    const Color soft = Color(0xFFD6EFE5);
    final DateTime? updated = round.updatedAt;
    return Semantics(
      container: true,
      label:
          '${round.label}, ${round.status.label}, '
          '${round.seatsLeft} seats left',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _LivePill(isLive: round.isLive),
                const Spacer(),
                if (updated != null)
                  Flexible(
                    child: Text(
                      'Updated ${Formatters.timeAgo(updated, now: now)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: soft, fontSize: 11.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Round $position of $totalRounds today',
              style: const TextStyle(color: soft, fontSize: 12.5),
            ),
            const SizedBox(height: 2),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                round.status.label,
                key: ValueKey<RoundStatus>(round.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: round.seatsTakenFraction),
                duration: const Duration(milliseconds: 500),
                builder: (BuildContext context, double value, Widget? child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${round.seatsLeft} of ${round.seatsTotal} seats left',
                    style: const TextStyle(color: soft, fontSize: 12),
                  ),
                ),
                Text(
                  round.label,
                  style: const TextStyle(color: soft, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({required this.isLive});
  final bool isLive;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isLive ? const Color(0xFF9FE0C6) : Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isLive ? 'LIVE' : 'NEXT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
