import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/providers/events_provider.dart';
import '../../../models/task.dart';
import '../../../shared/widgets/captus_fab.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/captus_pressable.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<dynamic> _getEventsForDay(DateTime day) {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final eventsAsync = ref.watch(eventsNotifierProvider);

    final targetDate = DateTime(day.year, day.month, day.day);
    final List<dynamic> dayItems = [];

    tasksAsync.whenData((tasks) {
      for (final task in tasks) {
        if (task.dueDate == null) continue;
        final taskDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        if (taskDate.isAtSameMomentAs(targetDate)) {
          dayItems.add({'type': 'task', 'data': task});
        }
      }
    });

    eventsAsync.whenData((events) {
      for (final event in events) {
        final eventDate = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        );
        if (eventDate.isAtSameMomentAs(targetDate)) {
          dayItems.add({'type': 'event', 'data': event});
        }
      }
    });

    return dayItems;
  }

  Color _getEventColor(CalendarEvent event) {
    switch (event.type.toLowerCase()) {
      case 'personal':
        return AppColors.info;
      case 'examen':
        return AppColors.error;
      case 'clase':
        return AppColors.primary;
      case 'entrega':
        return AppColors.warning;
      case 'reunión':
      case 'reunion':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  void _showCreateMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.s3),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.r1),
              ),
            ),
            SizedBox(height: AppSpacing.s4),
            Text(
              'Crear',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: AppSpacing.s4),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(AppAlpha.a10),
                  borderRadius: BorderRadius.circular(AppRadius.r5),
                ),
                child: const Icon(Icons.assignment_outlined, color: AppColors.primary),
              ),
              title: const Text('Nueva tarea'),
              subtitle: const Text('Tarea personal'),
              onTap: () {
                Navigator.pop(context);
                final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
                context.push('/tasks/personal/create?date=$dateStr');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(AppAlpha.a10),
                  borderRadius: BorderRadius.circular(AppRadius.r5),
                ),
                child: const Icon(Icons.event_outlined, color: AppColors.info),
              ),
              title: const Text('Nuevo evento'),
              subtitle: const Text('Evento del calendario'),
              onTap: () {
                Navigator.pop(context);
                final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
                context.push('/calendar/event/create?date=$dateStr');
              },
            ),
            SizedBox(height: AppSpacing.s6),
          ],
        ),
      ),
    );
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (context) => _MonthYearPickerDialog(
        initialDate: _focusedDay,
        onSelected: (date) {
          setState(() {
            _focusedDay = date;
            _selectedDay = date;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final dayEvents = _getEventsForDay(_selectedDay);

    return Scaffold(
      restorationId: 'calendar_screen',
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CaptusPressable(
                    onTap: _showMonthYearPicker,
                    child: Row(
                      children: [
                        Text(
                          DateFormat('MMMM yyyy', 'es').format(_focusedDay).toUpperCase(),
                          style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: AppSpacing.s1),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _FormatButton(
                              label: 'Mes',
                              isSelected: _format == CalendarFormat.month,
                              onTap: () => setState(() => _format = CalendarFormat.month),
                            ),
                            _FormatButton(
                              label: 'Sem',
                              isSelected: _format == CalendarFormat.week,
                              onTap: () => setState(() => _format = CalendarFormat.week),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpacing.s2),
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () {
                          setState(() {
                            if (_format == CalendarFormat.month) {
                              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                            } else {
                              _focusedDay = _focusedDay.subtract(const Duration(days: 7));
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () {
                          setState(() {
                            if (_format == CalendarFormat.month) {
                              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                            } else {
                              _focusedDay = _focusedDay.add(const Duration(days: 7));
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.today_rounded, color: AppColors.primary),
                        tooltip: 'Hoy',
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime.now();
                            _selectedDay = DateTime.now();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
              padding: EdgeInsets.all(AppSpacing.s3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r7),
                border: Border.all(color: AppColors.surface2),
              ),
              child: TableCalendar<dynamic>(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _format,
                eventLoader: _getEventsForDay,
                headerVisible: false,
                availableCalendarFormats: const {},
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(AppAlpha.a20),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: tt.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ) ?? const TextStyle(),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: tt.bodyMedium?.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ) ?? const TextStyle(),
                  markerDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox.shrink();

                    final displayEvents = events.take(2).toList();
                    final extraCount = events.length - 2;

                    return Positioned(
                      bottom: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...displayEvents.map((item) {
                            final eventType = item['type'] as String;
                            Color color;
                            if (eventType == 'task') {
                              color = _getPriorityColor((item['data'] as TaskModel).priority);
                            } else {
                              color = _getEventColor(item['data'] as CalendarEvent);
                            }
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                          if (extraCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary.withAlpha(AppAlpha.a20),
                                borderRadius: BorderRadius.circular(AppRadius.r1),
                              ),
                              child: Text(
                                '+$extraCount',
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Actividades del ${DateFormat('d MMM', 'es').format(_selectedDay)}',
                    style: tt.headlineSmall,
                  ),
                  if (dayEvents.isNotEmpty)
                    Text(
                      '${dayEvents.length} actividad${dayEvents.length > 1 ? 'es' : ''}',
                      style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.s2),
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Error al cargar: $error'),
                ),
                data: (_) {
                  if (dayEvents.isEmpty) {
                    return EmptyState(
                      icon: Icons.event_outlined,
                      title: 'Sin actividades',
                      subtitle: 'No hay tareas ni eventos para este día',
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.s4),
                    itemCount: dayEvents.length,
                    itemBuilder: (context, index) {
                      final item = dayEvents[index];
                      final eventType = item['type'] as String;

                      if (eventType == 'task') {
                        final task = item['data'] as TaskModel;
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.r6),
                            border: Border.all(color: AppColors.surface2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(task.priority),
                                  borderRadius: BorderRadius.circular(AppRadius.r1),
                                ),
                              ),
                              SizedBox(width: AppSpacing.s3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: AppSpacing.s1),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(task.priority).withAlpha(AppAlpha.a10),
                                            borderRadius: BorderRadius.circular(AppRadius.r4),
                                          ),
                                          child: Text(
                                            task.priority.label,
                                            style: tt.labelMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: _getPriorityColor(task.priority),
                                            ),
                                          ),
                                        ),
                                        if (task.courseName != null) ...[
                                          SizedBox(width: AppSpacing.s2),
                                          Text(
                                            task.courseName!,
                                            style: tt.bodySmall,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        );
                      } else {
                        final event = item['data'] as CalendarEvent;
                        final eventColor = _getEventColor(event);
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.r6),
                            border: Border.all(color: AppColors.surface2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: eventColor,
                                  borderRadius: BorderRadius.circular(AppRadius.r1),
                                ),
                              ),
                              SizedBox(width: AppSpacing.s3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: AppSpacing.s1),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: eventColor.withAlpha(AppAlpha.a10),
                                            borderRadius: BorderRadius.circular(AppRadius.r4),
                                          ),
                                          child: Text(
                                            event.type,
                                            style: tt.labelMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: eventColor,
                                            ),
                                          ),
                                        ),
                                        if (event.endDate != null) ...[
                                          SizedBox(width: AppSpacing.s2),
                                          Text(
                                            '${DateFormat('h:mm a', 'es').format(event.startDate)} - ${DateFormat('h:mm a', 'es').format(event.endDate!)}',
                                            style: tt.bodySmall,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CaptusFab(
        onPressed: _showCreateMenu,
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return CaptusPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
        child: Text(
          label,
          style: tt.labelLarge?.copyWith(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onSelected;

  const _MonthYearPickerDialog({
    required this.initialDate,
    required this.onSelected,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  final _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Theme(
      data: Theme.of(context).copyWith(dialogBackgroundColor: AppColors.surface),
      child: AlertDialog(
        title: Text(
          'Seleccionar mes y año',
          style: tt.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(
                labelText: 'Mes',
                border: OutlineInputBorder(),
              ),
              items: List.generate(12, (index) => DropdownMenuItem(
                value: index + 1,
                child: Text(_months[index]),
              )),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMonth = value);
                }
              },
            ),
            SizedBox(height: AppSpacing.s4),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Año',
                border: OutlineInputBorder(),
              ),
              items: List.generate(11, (index) => DropdownMenuItem(
                value: DateTime.now().year - 5 + index,
                child: Text((DateTime.now().year - 5 + index).toString()),
              )),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedYear = value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ElevatedButton(
          onPressed: () {
            widget.onSelected(DateTime(_selectedYear, _selectedMonth));
          },
          child: const Text('Aceptar'),
        ),
      ],
      ),
    );
  }
}
