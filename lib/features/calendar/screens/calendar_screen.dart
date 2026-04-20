import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/task.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final _tasks = TaskModel.mockList;

  List<TaskModel> _getEventsForDay(DateTime day) {
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return isSameDay(t.dueDate!, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = _getEventsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
            child: const Text('Hoy'),
          ),
          IconButton(
            icon: Icon(
              _format == CalendarFormat.month
                  ? Icons.view_week_rounded
                  : Icons.calendar_month_rounded,
            ),
            onPressed: () => setState(() {
              _format = _format == CalendarFormat.month
                  ? CalendarFormat.week
                  : CalendarFormat.month;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<TaskModel>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            calendarFormat: _format,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onFormatChanged: (f) => setState(() => _format = f),
            onPageChanged: (focused) => _focusedDay = focused,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textPrimary),
              weekendTextStyle: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withAlpha(38),
                shape: BoxShape.circle,
              ),
              todayTextStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
              markerDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerSize: 5,
              markersMaxCount: 3,
              cellMargin: const EdgeInsets.all(4),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.textPrimary),
              rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textPrimary),
              headerPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary),
              weekendStyle: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textDisabled),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),

          // Day events panel
          Expanded(
            child: dayEvents.isEmpty
                ? Center(
                    child: Text(
                      'Día libre 🎉',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dayEvents.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            DateFormat("EEEE d 'de' MMMM", 'es')
                                .format(_selectedDay),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      final task = dayEvents[i - 1];
                      return _CalendarEventItem(
                        task: task,
                        onTap: () => context.push('/tasks/${task.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/calendar/event/create'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _CalendarEventItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const _CalendarEventItem({required this.task, required this.onTap});

  Color get _color {
    switch (task.priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color.withAlpha(76)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  if (task.courseName != null)
                    Text(
                      task.courseName!,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            if (task.dueDate != null)
              Text(
                DateFormat('h:mm a').format(task.dueDate!),
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
