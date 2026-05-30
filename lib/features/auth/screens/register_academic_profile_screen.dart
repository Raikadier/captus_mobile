import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../shared/widgets/captus_pressable.dart';

class RegisterAcademicProfileScreen extends ConsumerStatefulWidget {
  const RegisterAcademicProfileScreen({super.key});

  @override
  ConsumerState<RegisterAcademicProfileScreen> createState() =>
      _RegisterAcademicProfileScreenState();
}

class _RegisterAcademicProfileScreenState
    extends ConsumerState<RegisterAcademicProfileScreen> {
  int _selectedSemester = 1;
  final List<String> _selectedSubjects = [];
  final _careerCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

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

  Future<void> _continue() async {
    setState(() { _saving = true; _error = null; });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Sesión expirada');

      await Supabase.instance.client
          .from('users')
          .update({
            'career': _careerCtrl.text.trim().isEmpty
                ? null
                : _careerCtrl.text.trim(),
            'semester': _selectedSemester,
          })
          .eq('id', user.id);

      if (!mounted) return;
      context.push('/register/notifications');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo guardar el perfil. Intenta de nuevo.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      restorationId: 'register_academic_profile_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil académico'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s2),
              const _StepBar(current: 2),
              const SizedBox(height: AppSpacing.s8),
              Text('Tu perfil académico',
                  style: tt.headlineLarge!.copyWith(fontSize: 24)),
              const SizedBox(height: AppSpacing.s1 + 2),
              Text('Paso 2 de 3',
                  style: tt.bodySmall!
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.s8),
              TextFormField(
                controller: _careerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Carrera / Programa',
                  hintText: 'Ingeniería de Sistemas',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text('Semestre actual', style: tt.headlineSmall),
              const SizedBox(height: AppSpacing.s3),
              Wrap(
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s2,
                children: List.generate(10, (i) {
                  final sem = i + 1;
                  final isSelected = _selectedSemester == sem;
                  return CaptusPressable(
                    onTap: () =>
                        setState(() => _selectedSemester = sem),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      curve: AppCurves.standard,
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(AppRadius.r4),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$sem',
                          style: tt.labelLarge!.copyWith(
                            color: isSelected
                                ? AppColors.textOnPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text('Mis materias este semestre',
                  style: tt.headlineSmall),
              const SizedBox(height: AppSpacing.s1),
              Text(
                'Selecciona las que cursas actualmente',
                style: tt.bodySmall!
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s3),
              Wrap(
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s2,
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
                    selectedColor:
                        AppColors.primary.withAlpha(AppAlpha.a20),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.s4),
                _ErrorBanner(message: _error!),
              ],
              const SizedBox(height: AppSpacing.s8),
              ElevatedButton(
                onPressed: _saving ? null : _continue,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.textOnPrimary,
                            strokeWidth: 2),
                      )
                    : const Text('Continuar'),
              ),
              const SizedBox(height: AppSpacing.s6),
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
            margin: EdgeInsets.only(right: i < 2 ? AppSpacing.s1 : 0),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surface2,
              borderRadius: BorderRadius.circular(AppRadius.r1),
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3, vertical: AppSpacing.s2 + 2),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(AppAlpha.a10),
        borderRadius: BorderRadius.circular(AppRadius.r3),
        border:
            Border.all(color: AppColors.error.withAlpha(AppAlpha.a30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 16),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(message,
                style: tt.bodySmall!.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
