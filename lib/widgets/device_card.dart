import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/app_provider.dart';
import '../theme.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;
  const DeviceCard({super.key, required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();
    final d = device;
    final brightnessPercent = ((d.brightness / 255) * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: d.isOn
              ? LightManagementTheme.amberDim
              : LightManagementTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: d.isOn
                ? LightManagementTheme.amber.withOpacity(0.35)
                : LightManagementTheme.border,
            width: d.isOn ? 1.5 : 1,
          ),
          boxShadow: d.isOn
              ? [
                  BoxShadow(
                    color: LightManagementTheme.amber.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: d.isOn
                        ? LightManagementTheme.amber.withOpacity(0.2)
                        : LightManagementTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.light_mode,
                    color: d.isOn
                        ? LightManagementTheme.amber
                        : LightManagementTheme.textTertiary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        style: const TextStyle(
                          color: LightManagementTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.mqttTopic,
                        style: const TextStyle(
                          color: LightManagementTheme.textTertiary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => d.isOn ? prov.turnOff(d) : prov.turnOn(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 48,
                    height: 28,
                    decoration: BoxDecoration(
                      color: d.isOn
                          ? LightManagementTheme.amber
                          : LightManagementTheme.surfaceHigh,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: d.isOn
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: d.isOn
                              ? Colors.black.withOpacity(0.4)
                              : LightManagementTheme.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(
                  Icons.brightness_low,
                  size: 14,
                  color: LightManagementTheme.textTertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: d.isOn ? d.brightness / 255 : 0,
                      backgroundColor: LightManagementTheme.surfaceHigh,
                      valueColor: const AlwaysStoppedAnimation(
                        LightManagementTheme.amber,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.brightness_high,
                  size: 14,
                  color: LightManagementTheme.textTertiary,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Text(
                    d.isOn ? '$brightnessPercent%' : '—',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: d.isOn
                          ? LightManagementTheme.amber
                          : LightManagementTheme.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                // Online dot
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: d.isOnline
                        ? LightManagementTheme.success
                        : LightManagementTheme.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  d.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: d.isOnline
                        ? LightManagementTheme.success
                        : LightManagementTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (d.isOnline && d.temperature > 0) ...[
                  const Icon(
                    Icons.thermostat,
                    size: 13,
                    color: LightManagementTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${d.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: LightManagementTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (d.history.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.history,
                    size: 13,
                    color: LightManagementTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${d.history.length} sessões',
                    style: const TextStyle(
                      color: LightManagementTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
