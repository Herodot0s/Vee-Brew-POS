// lib/widgets/analytics/components/peak_hours_card.dart
import 'package:flutter/material.dart';
import '../../admin/bento_card.dart';

class PeakHoursCard extends StatelessWidget {
  final Map<int, int> peakHours;

  const PeakHoursCard({super.key, required this.peakHours});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = peakHours.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final displayEntries = sortedEntries.take(5).toList();

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Busiest Hours',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: displayEntries.map((entry) {
                final hourStr = '${entry.key > 12 ? entry.key - 12 : (entry.key == 0 ? 12 : entry.key)} ${entry.key >= 12 ? 'PM' : 'AM'}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hourStr, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${entry.value} orders', style: const TextStyle(color: Colors.purple, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
