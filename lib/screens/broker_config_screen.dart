import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/mqtt_service.dart';
import '../theme.dart';

class BrokerConfigScreen extends StatefulWidget {
  const BrokerConfigScreen({super.key});

  @override
  State<BrokerConfigScreen> createState() => _BrokerConfigScreenState();
}

class _BrokerConfigScreenState extends State<BrokerConfigScreen> {
  late TextEditingController _brokerCtrl;
  late TextEditingController _portCtrl;
  late TextEditingController _userCtrl;
  late TextEditingController _passCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final cfg = context.read<AppProvider>().brokerConfig;
    _brokerCtrl = TextEditingController(text: cfg['broker']);
    _portCtrl = TextEditingController(text: cfg['port']);
    _userCtrl = TextEditingController(text: cfg['username']);
    _passCtrl = TextEditingController(text: cfg['password']);
  }

  @override
  void dispose() {
    _brokerCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndConnect() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final prov = context.read<AppProvider>();
    await prov.saveBrokerConfig({
      'broker': _brokerCtrl.text.trim(),
      'port': _portCtrl.text.trim(),
      'username': _userCtrl.text.trim(),
      'password': _passCtrl.text,
    });

    prov.disconnect();
    final ok = await prov.connect();

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Conectado com sucesso!'
                : 'Falha na conexão: ${prov.connectionError}',
          ),
          backgroundColor: ok
              ? LightManagementTheme.success
              : LightManagementTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final state = prov.connectionState;

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
                    'Configurar broker',
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
                      _StatusCard(state: state),
                      const SizedBox(height: 28),

                      const _Label('Endereço do broker'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _brokerCtrl,
                        hint: 'ex: broker.hivemq.com',
                        icon: Icons.dns_outlined,
                        keyboardType: TextInputType.url,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe o broker'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      const _Label('Porta'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _portCtrl,
                        hint: '1883',
                        icon: Icons.electrical_services_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Informe a porta';
                          if (int.tryParse(v.trim()) == null)
                            return 'Porta inválida';
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: const [
                          Expanded(
                            child: Divider(color: LightManagementTheme.border),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Credenciais (opcional)',
                              style: TextStyle(
                                color: LightManagementTheme.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: LightManagementTheme.border),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const _Label('Usuário'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _userCtrl,
                        hint: 'Deixe vazio se não necessário',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      const _Label('Senha'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        style: const TextStyle(
                          color: LightManagementTheme.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Deixe vazio se não necessário',
                          hintStyle: const TextStyle(
                            color: LightManagementTheme.textTertiary,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: LightManagementTheme.textTertiary,
                            size: 20,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            child: Icon(
                              _obscurePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: LightManagementTheme.textTertiary,
                              size: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: LightManagementTheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: LightManagementTheme.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: LightManagementTheme.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: LightManagementTheme.amber,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

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
                          children: [
                            const Text(
                              'Brokers públicos gratuitos:',
                              style: TextStyle(
                                color: LightManagementTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _BrokerSuggestion(
                              name: 'HiveMQ',
                              host: 'broker.hivemq.com',
                              port: '1883',
                              onTap: () {
                                _brokerCtrl.text = 'broker.hivemq.com';
                                _portCtrl.text = '1883';
                              },
                            ),
                            _BrokerSuggestion(
                              name: 'EMQX',
                              host: 'broker.emqx.io',
                              port: '1883',
                              onTap: () {
                                _brokerCtrl.text = 'broker.emqx.io';
                                _portCtrl.text = '1883';
                              },
                            ),
                            _BrokerSuggestion(
                              name: 'Mosquitto',
                              host: 'test.mosquitto.org',
                              port: '1883',
                              onTap: () {
                                _brokerCtrl.text = 'test.mosquitto.org';
                                _portCtrl.text = '1883';
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _saving ? null : _saveAndConnect,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _saving
                                  ? LightManagementTheme.amberDim
                                  : LightManagementTheme.amber,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: LightManagementTheme.amber,
                                      ),
                                    )
                                  : const Text(
                                      'Salvar e conectar',
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

class _StatusCard extends StatelessWidget {
  final AppMqttState state;
  const _StatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isConnected = state == AppMqttState.connected;
    final color = isConnected
        ? LightManagementTheme.success
        : LightManagementTheme.textTertiary;
    final label = isConnected ? 'Conectado' : 'Desconectado';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            'Status: $label',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

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

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
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

class _BrokerSuggestion extends StatelessWidget {
  final String name;
  final String host;
  final String port;
  final VoidCallback onTap;
  const _BrokerSuggestion({
    required this.name,
    required this.host,
    required this.port,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_outlined,
            size: 14,
            color: LightManagementTheme.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              color: LightManagementTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($host:$port)',
            style: const TextStyle(
              color: LightManagementTheme.textTertiary,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          const Text(
            'Usar',
            style: TextStyle(
              color: LightManagementTheme.amber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
