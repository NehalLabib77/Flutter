import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../utils/currency.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
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
        title: const Text('History'),
        backgroundColor: Colors.blueAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily Savings'),
            Tab(text: 'Targets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDailySavingsTab(), _buildTargetsTab()],
      ),
    );
  }

  Widget _buildDailySavingsTab() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, _) {
        if (provider.savingsHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No savings yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        // Group by date
        final groupedByDate = <String, List<dynamic>>{};
        for (var entry in provider.savingsHistory) {
          final dateKey = DateFormat('MMM dd, yyyy').format(entry.date);
          groupedByDate.putIfAbsent(dateKey, () => []);
          groupedByDate[dateKey]!.add(entry);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: groupedByDate.length,
          itemBuilder: (context, index) {
            final dateKey = groupedByDate.keys.toList()[index];
            final entries = groupedByDate[dateKey]!;
            final dailyTotal = entries.fold<double>(
              0,
              (sum, e) => sum + e.amount,
            );

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateKey,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '+${formatTaka(dailyTotal)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entries.length,
                    itemBuilder: (context, entryIndex) {
                      final entry = entries[entryIndex];
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${entry.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (entry.note != null)
                                    Text(
                                      entry.note!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('Delete'),
                                  onTap: () {
                                    final fullIndex = provider.savingsHistory
                                        .indexOf(entry);
                                    provider.deleteSavingsEntry(fullIndex);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Savings entry deleted'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTargetsTab() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, _) {
        if (provider.targetHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No target history',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: provider.targetHistory.length,
          itemBuilder: (context, index) {
            final target = provider
                .targetHistory[provider.targetHistory.length - 1 - index];
            final isCurrent = target == provider.currentTarget;

            Color statusColor = Colors.grey;
            String statusText = 'Active';

            if (target.isCompleted) {
              statusColor = Colors.green;
              statusText = 'Completed';
            } else if (target.isMissed) {
              statusColor = Colors.red;
              statusText = 'Missed';
            }

            final daysRemaining = target.targetDate
                .difference(DateTime.now())
                .inDays;

            return Card(
              elevation: isCurrent ? 4 : 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isCurrent
                    ? BorderSide(color: Colors.blue[400]!, width: 2)
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${target.targetAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(target.targetDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Chip(
                          label: Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Created: ${DateFormat('MMM dd, yyyy').format(target.createdDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          daysRemaining > 0
                              ? '$daysRemaining days left'
                              : 'Deadline passed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: daysRemaining > 0 ? Colors.blue : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
