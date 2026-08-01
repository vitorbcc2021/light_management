import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/connection_banner.dart';
import '../widgets/device_card.dart';
import 'add_device_screen.dart';
import 'broker_config_screen.dart';
import 'device_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: LightManagementTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: LightManagementTheme.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.light_mode,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'LightManagement',
                            style: TextStyle(
                              color: LightManagementTheme.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${prov.devices.length} equipamento${prov.devices.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: LightManagementTheme.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _IconBtn(
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BrokerConfigScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ConnectionBanner(),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: prov.devices.isEmpty
                  ? _EmptyState(onAdd: () => _goAddDevice(context))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      itemCount: prov.devices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final d = prov.devices[i];
                        return DeviceCard(
                          device: d,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DeviceDetailScreen(deviceId: d.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goAddDevice(context),
        backgroundColor: LightManagementTheme.amber,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo equipamento',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _goAddDevice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: LightManagementTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: LightManagementTheme.textSecondary, size: 20),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: LightManagementTheme.amberDim,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.light_mode_outlined,
            size: 36,
            color: LightManagementTheme.amber,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Nenhum equipamento',
          style: TextStyle(
            color: LightManagementTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Adicione um ESP32 para começar',
          style: TextStyle(
            color: LightManagementTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
