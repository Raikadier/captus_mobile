import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class RegisterAcademicProfileScreen extends StatefulWidget {
  const RegisterAcademicProfileScreen({super.key});

  @override
  State<RegisterAcademicProfileScreen> createState() =>
      _RegisterAcademicProfileScreenState();
}

class _RegisterAcademicProfileScreenState
    extends State<RegisterAcademicProfileScreen> {
  int _selectedSemester = 1;
  final List<String> _selectedSubjects = [];
  final _careerCtrl = TextEditingController();

  static const _suggestedSubjects = [
    'Cálculo I', 'Cálculo II', 'Álgebra Lineal',
    'Programación I', 'Estructuras de Datos',
    'Ingeniería de Software', 'Bases de Datos',
    'Sistemas Operativos', 'Redes', 'IA',
    'Física I', 'Química', 'Estadística',
  ];

  @override
  void dispose() {
    _careerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil académico'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _StepBar(current: 2),
              const SizedBox(height: 28),
              Text('Tu perfil académico',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text('Paso 2 de 3',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              TextFormField(
                controller: _careerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Carrera / Programa',
                  prefixIcon: Icon(Icons.school_outlined),
                  hintText: 'Ingeniería de Sistemas',
                ),
              ),
              const SizedBox(height: 24),
              Text('Semestre actual',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(10, (i) {
                  final sem = i + 1;
                  final isSelected = _selectedSemester == sem;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSemester = sem),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$sem',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text('Mis materias este semestre',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Selecciona las que cursas actualmente',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedSubjects.map((s) {
                  final isSelected = _selectedSubjects.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: isSelected,
                    onSelected: (_) => setState(() {
                      isSelected
                          ? _selectedSubjects.remove(s)
                          : _selectedSubjects.add(s);
                    }),
                    selectedColor: AppColors.primaryDark,
                    checkmarkColor: AppColors.primary,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.push('/register/notifications'),
                child: const Text('Continuar'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final active = i + 1 <= current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surface2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
