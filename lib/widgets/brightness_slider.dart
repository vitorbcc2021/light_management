import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/app_provider.dart';
import '../theme.dart';

class BrightnessSlider extends StatefulWidget {
  final Device device;
  const BrightnessSlider({super.key, required this.device});

  @override
  State<BrightnessSlider> createState() => _BrightnessSliderState();
}

class _BrightnessSliderState extends State<BrightnessSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.device.brightness.toDouble();
  }

  @override
  void didUpdateWidget(BrightnessSlider old) {
    super.didUpdateWidget(old);
    if (!_isDragging) {
      _value = widget.device.brightness.toDouble();
    }
  }

  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();
    final d = widget.device;
    final percent = ((_value / 255) * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        color: LightManagementTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightManagementTheme.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [10, 25, 50, 75, 100].map((p) {
                  final isSelected = percent == p;
                  return GestureDetector(
                    onTap: () {
                      final v = ((p / 100) * 255).roundToDouble();
                      setState(() => _value = v);
                      prov.setBrightness(d, v.round());
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? LightManagementTheme.amber
                            : LightManagementTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$p%',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : LightManagementTheme.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: LightManagementTheme.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: LightManagementTheme.amber,
              inactiveTrackColor: LightManagementTheme.surfaceHigh,
              thumbColor: LightManagementTheme.amber,
              overlayColor: LightManagementTheme.amberGlow,
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: _value,
              min: 0,
              max: 255,
              divisions: 255,
              onChangeStart: (_) => setState(() => _isDragging = true),
              onChanged: (v) => setState(() => _value = v),
              onChangeEnd: (v) {
                _isDragging = false;
                prov.setBrightness(d, v.round());
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Desligado',
                  style: TextStyle(
                    color: LightManagementTheme.textTertiary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  'Máximo',
                  style: TextStyle(
                    color: LightManagementTheme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
