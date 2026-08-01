import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/mqtt_service.dart';
import '../theme.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final state = prov.connectionState;
    final config = _bannerConfig(state);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.border),
      ),
      child: Row(
        children: [
          if (state == AppMqttState.connecting)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: config.color,
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: config.color,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              config.label,
              style: TextStyle(
                color: config.color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (state == AppMqttState.disconnected || state == AppMqttState.error)
            GestureDetector(
              onTap: () => prov.connect(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Conectar',
                  style: TextStyle(
                    color: config.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (state == AppMqttState.connected)
            GestureDetector(
              onTap: () => prov.disconnect(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: LightManagementTheme.textTertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Desconectar',
                  style: TextStyle(
                    color: LightManagementTheme.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _BannerConfig _bannerConfig(AppMqttState state) {
    switch (state) {
      case AppMqttState.connected:
        return _BannerConfig(
          label: 'Broker MQTT conectado',
          color: LightManagementTheme.success,
          bg: LightManagementTheme.success.withOpacity(0.08),
          border: LightManagementTheme.success.withOpacity(0.2),
        );
      case AppMqttState.connecting:
        return _BannerConfig(
          label: 'Conectando ao broker...',
          color: LightManagementTheme.amber,
          bg: LightManagementTheme.amberDim,
          border: LightManagementTheme.amber.withOpacity(0.2),
        );
      case AppMqttState.error:
        return _BannerConfig(
          label: 'Falha na conexão',
          color: LightManagementTheme.error,
          bg: LightManagementTheme.error.withOpacity(0.08),
          border: LightManagementTheme.error.withOpacity(0.2),
        );
      case AppMqttState.disconnected:
        return _BannerConfig(
          label: 'Desconectado do broker',
          color: LightManagementTheme.textTertiary,
          bg: LightManagementTheme.surfaceHigh,
          border: LightManagementTheme.border,
        );
    }
  }
}

class _BannerConfig {
  final String label;
  final Color color;
  final Color bg;
  final Color border;
  const _BannerConfig({
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
  });
}
