import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/events_provider.dart';

class CalendarEventCreateScreen extends ConsumerStatefulWidget {
  final String? date;
  final String? eventId;

  const CalendarEventCreateScreen({super.key, this.date, this.eventId});

  @override
  ConsumerState<CalendarEventCreateScreen> createState() =>
      _CalendarEventCreateScreenState();
}

class _CalendarEventCreateScreenState
    extends ConsumerState<CalendarEventCreateScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _allDay = false;
  bool _notify = false;
  int _typeIndex = 0;
  bool _isLoading = false;

  final _types = ['Personal', 'Examen', 'Clase', 'Entrega', 'Reunión'];
  final _typeValues = ['personal', 'examen', 'clase', 'entrega', 'reunión'];
  final _typeColors = [
    AppColors.info,
    AppColors.error,
    AppColors.primary,
    AppColors.warning,
    Colors.purple,
  ];

  bool get _isEditing => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    if (widget.date != null) {
      final parsed = DateTime.tryParse(widget.date!);
      if (parsed != null) {
        _startDate = DateTime(parsed.year, parsed.month, parsed.day);
      }
    }
    if (_isEditing) {
      _loadEvent();
    }
  }

  Future<void> _loadEvent() async {
    final eventsAsync = ref.read(eventsNotifierProvider);
    eventsAsync.whenData((events) {
      final eventId = int.tryParse(widget.eventId!);
      if (eventId != null) {
        try {
          final event = events.firstWhere((e) => e.id == eventId);
          setState(() {
            _titleCtrl.text = event.title;
            _descriptionCtrl.text = event.description ?? '';
            _startDate = event.startDate;
          _endDate = event.endDate;
          _notify = event.notify;
          _typeIndex = _typeValues.indexOf(event.type.toLowerCase());
          if (_typeIndex < 0) _typeIndex = 0;
          });
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveEvent() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final eventId = int.parse(widget.eventId!);
        await ref.read(eventsNotifierProvider.notifier).updateEvent(
          eventId,
          {
            'title': _titleCtrl.text.trim(),
            'description': _descriptionCtrl.text.trim().isEmpty
                ? null
                : _descriptionCtrl.text.trim(),
            'start_date': _startDate.toIso8601String(),
            'end_date': _endDate?.toIso8601String(),
            'type': _typeValues[_typeIndex],
            'notify': _notify,
          },
        );
      } else {
        await ref.read(eventsNotifierProvider.notifier).create(
          title: _titleCtrl.text.trim(),
          description: _descriptionCtrl.text.trim().isEmpty
              ? null
              : _descriptionCtrl.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          type: _typeValues[_typeIndex],
          notify: _notify,
        );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar evento' : 'Nuevo evento'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEvent,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleCtrl,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Título del evento',
                hintStyle: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Divider(color: AppColors.border),
            const SizedBox(height: 20),

            Text(
              'Descripción (opcional)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionCtrl,
              style: GoogleFonts.inter(fontSize: 15),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Agrega una descripción...',
                hintStyle: GoogleFonts.inter(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Tipo de evento',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.asMap().entries.map((e) {
                final isSelected = _typeIndex == e.key;
                final color = _typeColors[e.key];
                return GestureDetector(
                  onTap: () => setState(() => _typeIndex = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withAlpha(38) : AppColors.surface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : AppColors.border,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Todo el día',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Switch(
                  value: _allDay,
                  onChanged: (v) => setState(() {
                    _allDay = v;
                    if (v) {
                      _endDate = null;
                    }
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickStartDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat(_allDay
                              ? "d 'de' MMMM, yyyy"
                              : "d 'de' MMMM, yyyy — h:mm a",
                          'es')
                          .format(_startDate),
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (!_allDay) ...[
              GestureDetector(
                onTap: _pickEndDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_outlined,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        _endDate != null
                            ? DateFormat("d 'de' MMMM, yyyy — h:mm a", 'es')
                                .format(_endDate!)
                            : 'Agregar hora de fin',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _endDate != null
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notificar',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Switch(
                  value: _notify,
                  onChanged: (v) => setState(() => _notify = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );
      if (time != null && mounted) {
        setState(() {
          _startDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        setState(() {
          _startDate = DateTime(date.year, date.month, date.day);
        });
      }
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDate ?? _startDate),
      );
      if (time != null && mounted) {
        setState(() {
          _endDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        setState(() {
          _endDate = DateTime(date.year, date.month, date.day);
        });
      }
    }
  }
}