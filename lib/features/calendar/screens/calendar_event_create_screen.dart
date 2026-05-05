import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class CalendarEventCreateScreen extends StatefulWidget {
  final String? date;
  final String? eventId;

  const CalendarEventCreateScreen({super.key, this.date, this.eventId});

  @override
  State<CalendarEventCreateScreen> createState() =>
      _CalendarEventCreateScreenState();
}

class _CalendarEventCreateScreenState extends State<CalendarEventCreateScreen> {
  final _titleCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  bool _allDay = false;
  int _typeIndex = 0;

  final _types = ['Personal', 'Examen', 'Clase', 'Entrega', 'Reunión'];
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
      _startDate = DateTime.tryParse(widget.date!) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
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
            onPressed: () => context.pop(),
            child: const Text('Guardar'),
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
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Título del evento',
                hintStyle: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDisabled),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Divider(color: AppColors.border),
            const SizedBox(height: 20),
            Text('Tipo de evento',
                style: Theme.of(context).textTheme.titleMedium),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? color.withAlpha(38) : AppColors.surface2,
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
                Text('Todo el día',
                    style: Theme.of(context).textTheme.titleMedium),
                Switch(
                  value: _allDay,
                  onChanged: (v) => setState(() => _allDay = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
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
                      DateFormat(
                              _allDay
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
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      setState(() => _startDate = date);
    }
  }
}
