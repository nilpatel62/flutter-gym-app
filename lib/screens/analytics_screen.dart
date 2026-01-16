import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../models/exercise_analytics.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  ExerciseAnalytics? _analytics;
  bool _isLoading = false;
  Map<DateTime, double> _dateScores = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get start and end of the current month
      final startDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final endDate = DateTime(_currentMonth.year, _currentMonth.month + 1, 0, 23, 59, 59);

      final response = await SupabaseService.getExerciseAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      final analytics = ExerciseAnalytics.fromJson(response);
      
      // Build date scores map
      final dateScores = <DateTime, double>{};
      for (var exercise in analytics.data) {
        try {
          // Parse date string like "12th Jan 2026"
          final date = _parseDate(exercise.date);
          if (date != null) {
            // Store the maximum score for each date (in case of multiple exercises)
            if (!dateScores.containsKey(date) || dateScores[date]! < exercise.score) {
              dateScores[date] = exercise.score;
            }
          }
        } catch (e) {
          print('Error parsing date: ${exercise.date} - $e');
        }
      }

      setState(() {
        _analytics = analytics;
        _dateScores = dateScores;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Handle formats like "12th Jan 2026" or "1st Jan 2026"
      final cleaned = dateStr.replaceAll(RegExp(r'(st|nd|rd|th)'), '').trim();
      return DateFormat('d MMM yyyy').parse(cleaned);
    } catch (e) {
      try {
        // Try ISO format as fallback
        return DateTime.parse(dateStr);
      } catch (e2) {
        print('Failed to parse date: $dateStr');
        return null;
      }
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadAnalytics();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadAnalytics();
  }

  Color _getDateColor(DateTime date) {
    final score = _dateScores[date];
    if (score == null) return Colors.grey.shade400;
    
    if (score < 34) {
      return Colors.red;
    } else if (score <= 66) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  List<ExerciseData> _getExercisesForDate(DateTime date) {
    if (_analytics == null) return [];
    
    return _analytics!.data.where((exercise) {
      final exerciseDate = _parseDate(exercise.date);
      if (exerciseDate == null) return false;
      return exerciseDate.year == date.year &&
          exerciseDate.month == date.month &&
          exerciseDate.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Month Navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _previousMonth,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(_currentMonth).toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _nextMonth,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Days of week
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                              .map((day) => SizedBox(
                                    width: 40,
                                    child: Text(
                                      day,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        // Calendar Grid
                        _buildCalendarGrid(isDark),
                        const SizedBox(height: 16),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(Colors.red, '<34%', isDark),
                            const SizedBox(width: 16),
                            _buildLegendItem(Colors.yellow, '34% - 66%', isDark),
                            const SizedBox(width: 16),
                            _buildLegendItem(Colors.green, '>66%', isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Exercise Data Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exercise Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_analytics != null) ...[
                          Text(
                            'Average Score: ${_analytics!.averageScore.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_analytics!.data.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'No exercise data available for this month',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            )
                          else
                            ..._analytics!.data.map((exercise) => _buildExerciseCard(exercise, isDark)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday
    final daysInMonth = lastDayOfMonth.day;

    final List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Add cells for each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final isToday = date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final hasData = _dateScores.containsKey(date);
      final dateColor = _getDateColor(date);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: dateColor,
                      width: 2,
                    )
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? dateColor
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
                if (hasData)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dateColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Build rows of 7 days
    final List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayWidgets.sublist(
            i,
            i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseData exercise, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
      child: ListTile(
        title: Text(
          exercise.name.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          exercise.date,
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getScoreColor(exercise.score).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${exercise.score.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getScoreColor(exercise.score),
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score < 34) {
      return Colors.red;
    } else if (score <= 66) {
      return Colors.yellow.shade700;
    } else {
      return Colors.green;
    }
  }
}
