import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _nameCtrl = TextEditingController();
  final _topicCtrl = TextEditingController(text: 'lightmanagement/device1');
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _topicCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await context.read<AppProvider>().addDevice(
      _nameCtrl.text.trim(),
      _topicCtrl.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightManagementTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: LightManagementTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: LightManagementTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Novo equipamento',
                    style: TextStyle(
                      color: LightManagementTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: LightManagementTheme.amberDim,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline,
                            size: 36,
                            color: LightManagementTheme.amber,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      const _FieldLabel('Nome do equipamento'),
                      const SizedBox(height: 8),
                      _LightManagementField(
                        controller: _nameCtrl,
                        hint: 'ex: Anel LED Principal',
                        icon: Icons.label_outline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe um nome'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      const _FieldLabel('Tópico MQTT base'),
                      const SizedBox(height: 4),
                      const Text(
                        'O app vai publicar em <tópico>/cmd e escutar <tópico>/status e <tópico>/telemetry',
                        style: TextStyle(
                          color: LightManagementTheme.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _LightManagementField(
                        controller: _topicCtrl,
                        hint: 'ex: lightmanagement/device1',
                        icon: Icons.topic_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe o tópico'
                            : null,
                      ),

                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: LightManagementTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: LightManagementTheme.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Configure o ESP32 com:',
                              style: TextStyle(
                                color: LightManagementTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.upload_outlined,
                              text: 'Publicar telemetria em <tópico>/telemetry',
                            ),
                            _InfoRow(
                              icon: Icons.upload_outlined,
                              text: 'Publicar status em <tópico>/status',
                            ),
                            _InfoRow(
                              icon: Icons.download_outlined,
                              text: 'Escutar comandos em <tópico>/cmd',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _loading ? null : _add,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _loading
                                  ? LightManagementTheme.amberDim
                                  : LightManagementTheme.amber,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: LightManagementTheme.amber,
                                      ),
                                    )
                                  : const Text(
                                      'Adicionar equipamento',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: LightManagementTheme.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _LightManagementField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  const _LightManagementField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    style: const TextStyle(
      color: LightManagementTheme.textPrimary,
      fontSize: 15,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: LightManagementTheme.textTertiary),
      prefixIcon: Icon(
        icon,
        color: LightManagementTheme.textTertiary,
        size: 20,
      ),
      filled: true,
      fillColor: LightManagementTheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LightManagementTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LightManagementTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: LightManagementTheme.amber,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: LightManagementTheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: LightManagementTheme.error,
          width: 1.5,
        ),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        Icon(icon, size: 14, color: LightManagementTheme.amber),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: LightManagementTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}
