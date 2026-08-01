import 'package:flutter/material.dart';
import '../theme.dart';

class TempGauge extends StatelessWidget {
  final double temperature;
  const TempGauge({super.key, required this.temperature});

  Color get _tempColor {
    if (temperature >= 70) return LightManagementTheme.error;
    if (temperature >= 50) return LightManagementTheme.warn;
    return LightManagementTheme.success;
  }

  String get _tempLabel {
    if (temperature >= 70) return 'Crítico';
    if (temperature >= 50) return 'Quente';
    if (temperature > 0) return 'Normal';
    return '—';
  }

  double get _fillFraction {
    if (temperature <= 0) return 0;
    return (temperature / 100).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LightManagementTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightManagementTheme.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                temperature > 0 ? temperature.toStringAsFixed(1) : '—',
                style: TextStyle(
                  color: _tempColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              if (temperature > 0) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    '°C',
                    style: TextStyle(
                      color: LightManagementTheme.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _tempColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _tempColor.withOpacity(0.25)),
                ),
                child: Text(
                  _tempLabel,
                  style: TextStyle(
                    color: _tempColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1A3D2B),
                      Color(0xFF3D2A00),
                      Color(0xFF4A1010),
                    ],
                  ),
                ),
              ),
              // Indicator line
              FractionallySizedBox(
                widthFactor: _fillFraction,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: Colors.transparent,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _tempColor,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                            color: _tempColor.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: const [
              Text(
                '0°',
                style: TextStyle(
                  color: LightManagementTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
              Spacer(),
              Text(
                '50°',
                style: TextStyle(
                  color: LightManagementTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
              Spacer(),
              Text(
                '70°',
                style: TextStyle(
                  color: LightManagementTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
              Spacer(),
              Text(
                '100°',
                style: TextStyle(
                  color: LightManagementTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
