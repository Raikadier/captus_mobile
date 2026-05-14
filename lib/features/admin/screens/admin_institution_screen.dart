import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_errors.dart';
import '../services/admin_service.dart';

class AdminInstitutionScreen extends StatefulWidget {
  const AdminInstitutionScreen({super.key});

  @override
  State<AdminInstitutionScreen> createState() => _AdminInstitutionScreenState();
}

class _AdminInstitutionScreenState extends State<AdminInstitutionScreen> {
  Map<String, dynamic>? _institution;
  bool _loading = true;
  bool _saving = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _websiteCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl    = TextEditingController();
    _addressCtrl = TextEditingController();
    _phoneCtrl   = TextEditingController();
    _emailCtrl   = TextEditingController();
    _websiteCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await AdminService.instance.getInstitution();
      if (mounted && data != null) {
        setState(() {
          _institution = data;
          _nameCtrl.text    = data['name']    ?? '';
          _addressCtrl.text = data['address'] ?? '';
          _phoneCtrl.text   = data['phone']   ?? '';
          _emailCtrl.text   = data['email']   ?? '';
          _websiteCtrl.text = data['website'] ?? '';
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }
    setState(() => _saving = true);
    try {
      final payload = {
        'name':    name,
        'address': _addressCtrl.text.trim(),
        'phone':   _phoneCtrl.text.trim(),
        'email':   _emailCtrl.text.trim(),
        'website': _websiteCtrl.text.trim(),
      };
      if (_institution != null) {
        await AdminService.instance.updateInstitution(
          _institution!['id'].toString(), payload);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Institución actualizada')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo guardar. Intenta de nuevo.'))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Institución',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? 'Guardando…' : 'Guardar',
              style: GoogleFonts.inter(
                color: _saving ? AppColors.textDisabled : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Field(ctrl: _nameCtrl,    label: 'Nombre de la institución', hint: 'Colegio San Marcos'),
                _Field(ctrl: _addressCtrl, label: 'Dirección',                hint: 'Calle 10 # 20-30'),
                _Field(ctrl: _phoneCtrl,   label: 'Teléfono',                 hint: '+57 300 000 0000',
                  type: TextInputType.phone),
                _Field(ctrl: _emailCtrl,   label: 'Correo institucional',     hint: 'info@colegio.edu',
                  type: TextInputType.emailAddress),
                _Field(ctrl: _websiteCtrl, label: 'Sitio web',                hint: 'https://www.colegio.edu',
                  type: TextInputType.url),
              ],
            ),
          ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType type;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
    );
  }
}
