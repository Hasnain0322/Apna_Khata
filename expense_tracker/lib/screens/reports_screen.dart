import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/services/firestore_service.dart';
import 'package:expense_tracker/widgets/glass_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // A vibrant and distinct color palette for the charts
  final List<Color> colorPalette = [
    const Color(0xFF8A77FF), const Color(0xFF23B6E6), const Color(0xFF00D5A3),
    const Color(0xFFF0A500), const Color(0xFFE53935), const Color(0xFF3D445C),
  ];
  
  int pieTouchedIndex = -1; // For pie chart interactivity
  int barTouchedIndex = -1; // For bar chart interactivity

  /// Processes raw expense data into a map of {Category: TotalAmount}.
  Map<String, double> _processCategoryData(List<Expense> expenses) {
    Map<String, double> categoryData = {};
    for (var expense in expenses) {
      categoryData[expense.category] = (categoryData[expense.category] ?? 0.0) + expense.amount;
    }
    return categoryData;
  }

  /// Processes expenses for the last 7 days into a map of {DayOfWeek: TotalAmount}.
  Map<String, double> _processWeeklyData(List<Expense> expenses) {
    Map<String, double> weeklySpending = {};
    final now = DateTime.now();
    // Initialize the map with the last 7 days in the correct order
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayKey = DateFormat.E().format(day); // e.g., "Mon", "Tue"
      weeklySpending[dayKey] = 0.0;
    }

    for (var expense in expenses) {
      final expenseDate = expense.timestamp.toDate();
      // This is a true "rolling 7 day" check
      if (now.difference(expenseDate).inDays < 7) {
        final dayKey = DateFormat.E().format(expenseDate);
        if (weeklySpending.containsKey(dayKey)) {
          weeklySpending[dayKey] = weeklySpending[dayKey]! + expense.amount;
        }
      }
    }
    return weeklySpending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Analysis')),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expense data to generate reports.'));
          }
          
          final expenses = snapshot.data!;
          final categoryData = _processCategoryData(expenses);
          final weeklyData = _processWeeklyData(expenses);
          final totalExpenses = expenses.fold(0.0, (sum, item) => sum + item.amount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTotalCard(totalExpenses),
                const SizedBox(height: 20),
                _buildBarChartCard(weeklyData),
                const SizedBox(height: 20),
                _buildDonutChartCard(categoryData, totalExpenses),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the top card showing total expenses.
  Widget _buildTotalCard(double total) {
    return GlassCard(
      child: Center(
        child: Column(
          children: [
            Text('Total Expenses', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              '₹${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the interactive bar chart for weekly spending.
  Widget _buildBarChartCard(Map<String, double> weeklyData) {
    final double maxY = weeklyData.values.fold(0.0, (max, current) => current > max ? current : max);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Analytics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY == 0 ? 100 : maxY * 1.2,
                // This section handles the touch interaction
                barTouchData: BarTouchData(
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
                        barTouchedIndex = -1; // User is not touching a bar
                        return;
                      }
                      // User is touching a bar, store its index
                      barTouchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final titles = weeklyData.keys.toList();
                        return SideTitleWidget(
                          space: 4,
                          meta: meta,
                          child: Text(titles[value.toInt()], style: TextStyle(fontSize: 12, color: Colors.white70)),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(weeklyData.length, (i) {
                  final isTouched = i == barTouchedIndex;
                  final entry = weeklyData.entries.elementAt(i);
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        // Bar becomes brighter and thicker when touched
                        color: isTouched ? primaryColor : primaryColor.withOpacity(0.5),
                        width: isTouched ? 22 : 16,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the interactive donut chart for category breakdown.
  Widget _buildDonutChartCard(Map<String, double> categoryData, double total) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                            pieTouchedIndex = -1;
                            return;
                          }
                          pieTouchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: List.generate(categoryData.length, (i) {
                      final isTouched = i == pieTouchedIndex;
                      final fontSize = isTouched ? 16.0 : 12.0;
                      final radius = isTouched ? 50.0 : 40.0;
                      final entry = categoryData.entries.elementAt(i);
                      final percentage = total > 0 ? (entry.value / total) * 100 : 0;
                      
                      return PieChartSectionData(
                        color: colorPalette[i % colorPalette.length],
                        value: entry.value,
                        title: '${percentage.toStringAsFixed(0)}%',
                        radius: radius,
                        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
                      );
                    }),
                    centerSpaceRadius: 50,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryData.entries.map((entry) {
                    final index = categoryData.keys.toList().indexOf(entry.key);
                    return _buildLegendItem(colorPalette[index % colorPalette.length], entry.key);
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper widget for the legend items next to the donut chart.
  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}