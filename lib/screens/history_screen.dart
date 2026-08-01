import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/app_provider.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  final String deviceId;
  const HistoryScreen({super.key, required this.deviceId});

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Histórico',
                          style: TextStyle(
                            color: LightManagementTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          d.name,
                          style: const TextStyle(
                            color: LightManagementTheme.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${d.history.length} sessões',
                    style: const TextStyle(
                      color: LightManagementTheme.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (d.history.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SummaryRow(history: d.history),
              ),

            const SizedBox(height: 16),

            Expanded(
              child: d.history.isEmpty
                  ? const _EmptyHistory()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      itemCount: d.history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) =>
                          _SessionTile(session: d.history[i], index: i),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<SessionRecord> history;
  const _SummaryRow({required this.history});

  @override
  Widget build(BuildContext context) {
    final totalMins = history.fold<int>(
      0,
      (sum, s) => sum + s.duration.inMinutes,
    );
    final allMaxTemps = history.map((s) => s.maxTemp).toList();
    allMaxTemps.sort();
    final overallMax = allMaxTemps.last;
    final overallAvg =
        history.map((s) => s.avgTemp).reduce((a, b) => a + b) / history.length;

    final h = totalMins ~/ 60;
    final m = totalMins % 60;
    final totalStr = h > 0 ? '${h}h ${m}m' : '${m}m';

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.timer_outlined,
            label: 'Tempo total',
            value: totalStr,
            color: LightManagementTheme.amber,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.thermostat,
            label: 'Temp. média',
            value: '${overallAvg.toStringAsFixed(1)}°C',
            color: LightManagementTheme.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.local_fire_department_outlined,
            label: 'Pico máximo',
            value: '${overallMax.toStringAsFixed(1)}°C',
            color: overallMax >= 70
                ? LightManagementTheme.error
                : LightManagementTheme.warn,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: LightManagementTheme.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

class _SessionTile extends StatelessWidget {
  final SessionRecord session;
  final int index;
  const _SessionTile({required this.session, required this.index});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hoje ${_time(dt)}';
    if (diff.inDays == 1) return 'Ontem ${_time(dt)}';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${_time(dt)}';
  }

  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }

  Color _maxTempColor(double t) {
    if (t >= 70) return LightManagementTheme.error;
    if (t >= 50) return LightManagementTheme.warn;
    return LightManagementTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightManagementTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightManagementTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: LightManagementTheme.amberDim,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: LightManagementTheme.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatDate(session.startTime),
                style: const TextStyle(
                  color: LightManagementTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LightManagementTheme.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDuration(session.duration),
                  style: const TextStyle(
                    color: LightManagementTheme.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: LightManagementTheme.border, height: 1),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _StatCol(
                  label: 'Temp. mín.',
                  value: '${session.minTemp.toStringAsFixed(1)}°C',
                  color: LightManagementTheme.success,
                ),
              ),
              Expanded(
                child: _StatCol(
                  label: 'Temp. média',
                  value: '${session.avgTemp.toStringAsFixed(1)}°C',
                  color: LightManagementTheme.textSecondary,
                ),
              ),
              Expanded(
                child: _StatCol(
                  label: 'Temp. máx.',
                  value: '${session.maxTemp.toStringAsFixed(1)}°C',
                  color: _maxTempColor(session.maxTemp),
                ),
              ),
              Expanded(
                child: _StatCol(
                  label: 'Brilho médio',
                  value: '${((session.avgBrightness / 255) * 100).round()}%',
                  color: LightManagementTheme.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCol({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: LightManagementTheme.textTertiary,
          fontSize: 10,
        ),
      ),
    ],
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: LightManagementTheme.surfaceHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.history,
            size: 28,
            color: LightManagementTheme.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nenhuma sessão registrada',
          style: TextStyle(
            color: LightManagementTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ligue o equipamento para iniciar o registro',
          style: TextStyle(
            color: LightManagementTheme.textTertiary,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
