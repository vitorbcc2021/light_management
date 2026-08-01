import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/brightness_slider.dart';
import '../widgets/temp_gauge.dart';
import 'history_screen.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String deviceId;
  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final d = prov.devices.firstWhere((d) => d.id == deviceId);

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
                  Expanded(
                    child: Text(
                      d.name,
                      style: const TextStyle(
                        color: LightManagementTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // History button
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(deviceId: deviceId),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: LightManagementTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: LightManagementTheme.textSecondary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Histórico',
                            style: TextStyle(
                              color: LightManagementTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: LightManagementTheme.surface,
                          title: const Text(
                            'Remover dispositivo?',
                            style: TextStyle(
                              color: LightManagementTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: Text(
                            'Tem certeza que deseja remover "${d.name}" da aplicação?',
                            style: const TextStyle(
                              color: LightManagementTheme.textSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: LightManagementTheme.textSecondary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<AppProvider>().removeDevice(
                                  deviceId,
                                );
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Remover',
                                style: TextStyle(
                                  color: LightManagementTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: LightManagementTheme.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: LightManagementTheme.error,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Remover',
                            style: TextStyle(
                              color: LightManagementTheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusChip(device: d),
                        const Spacer(),
                        Text(
                          d.mqttTopic,
                          style: const TextStyle(
                            color: LightManagementTheme.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Center(child: _PowerButton(device: d)),

                    const SizedBox(height: 36),

                    const Text(
                      'Intensidade',
                      style: TextStyle(
                        color: LightManagementTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BrightnessSlider(device: d),

                    const SizedBox(height: 32),

                    const Text(
                      'Temperatura',
                      style: TextStyle(
                        color: LightManagementTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TempGauge(temperature: d.temperature),

                    const SizedBox(height: 32),

                    if (d.isOn && d.sessionStart != null)
                      _SessionCard(device: d),

                    const SizedBox(height: 16),

                    if (d.history.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text(
                            'Última sessão',
                            style: TextStyle(
                              color: LightManagementTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HistoryScreen(deviceId: deviceId),
                              ),
                            ),
                            child: const Text(
                              'Ver tudo',
                              style: TextStyle(
                                color: LightManagementTheme.amber,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _LastSessionCard(session: d.history.first),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Device device;
  const _StatusChip({required this.device});

  @override
  Widget build(BuildContext context) {
    final online = device.isOnline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: online
            ? LightManagementTheme.success.withOpacity(0.12)
            : LightManagementTheme.textTertiary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: online
              ? LightManagementTheme.success.withOpacity(0.3)
              : LightManagementTheme.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: online
                  ? LightManagementTheme.success
                  : LightManagementTheme.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            online ? 'Online' : 'Offline',
            style: TextStyle(
              color: online
                  ? LightManagementTheme.success
                  : LightManagementTheme.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerButton extends StatelessWidget {
  final Device device;
  const _PowerButton({required this.device});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();
    final on = device.isOn;

    return GestureDetector(
      onTap: () => on ? prov.turnOff(device) : prov.turnOn(device),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: on
              ? LightManagementTheme.amberDim
              : LightManagementTheme.surfaceHigh,
          border: Border.all(
            color: on
                ? LightManagementTheme.amber
                : LightManagementTheme.border,
            width: on ? 2.5 : 1.5,
          ),
          boxShadow: on
              ? [
                  BoxShadow(
                    color: LightManagementTheme.amber.withOpacity(0.25),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.power_settings_new,
              size: 40,
              color: on
                  ? LightManagementTheme.amber
                  : LightManagementTheme.textTertiary,
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: on
                    ? LightManagementTheme.amber
                    : LightManagementTheme.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              child: Text(on ? 'LIGADO' : 'DESLIGADO'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Device device;
  const _SessionCard({required this.device});

  String _elapsed() {
    final dur = DateTime.now().difference(device.sessionStart!);
    final h = dur.inHours;
    final m = dur.inMinutes % 60;
    final s = dur.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: LightManagementTheme.amberDim,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightManagementTheme.amber.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            color: LightManagementTheme.amber,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sessão ativa',
                style: TextStyle(
                  color: LightManagementTheme.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _elapsed(),
                style: const TextStyle(
                  color: LightManagementTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Temperatura',
                style: TextStyle(
                  color: LightManagementTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${device.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  color: LightManagementTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LastSessionCard extends StatelessWidget {
  final SessionRecord session;
  const _LastSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final dur = session.duration;
    final durStr = dur.inHours > 0
        ? '${dur.inHours}h ${dur.inMinutes % 60}m'
        : '${dur.inMinutes}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightManagementTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightManagementTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Duração',
              value: durStr,
              icon: Icons.timer_outlined,
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              label: 'Temp. mín.',
              value: '${session.minTemp.toStringAsFixed(1)}°',
              icon: Icons.thermostat,
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              label: 'Temp. máx.',
              value: '${session.maxTemp.toStringAsFixed(1)}°',
              icon: Icons.thermostat,
              color: _tempColor(session.maxTemp),
            ),
          ),
        ],
      ),
    );
  }

  Color _tempColor(double t) {
    if (t > 70) return LightManagementTheme.error;
    if (t > 50) return LightManagementTheme.warn;
    return LightManagementTheme.success;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 16, color: color ?? LightManagementTheme.textTertiary),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: color ?? LightManagementTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(
          color: LightManagementTheme.textTertiary,
          fontSize: 11,
        ),
      ),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: LightManagementTheme.border);
}
