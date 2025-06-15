import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:pet_tracker/features/navigation/presentation/widgets/health_stats_bar.dart';
import 'package:pet_tracker/features/navigation/presentation/providers/health_stream_provider.dart'; // Importa el provider
import 'package:go_router/go_router.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acceder al estado del authProvider
    final authState = ref.watch(authProvider);
    final userName = authState.userProfile?.firstName ?? 'Usuario';

    // Observar los datos del WebSocket
    final healthState = ref.watch(healthStreamProvider);

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 36,
                  height: 36,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF08273A),
                    BlendMode.srcIn,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.go('/devices');
                      },
                      child: SvgPicture.asset(
                        'assets/images/dog-collar.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF08273A),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    PopupMenuButton<String>(
                      icon: CircleAvatar(
                        backgroundColor: const Color(0xFFE8F7FF),
                        radius: 16,
                        child: SvgPicture.asset(
                          'assets/images/user.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF08273A),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'settings') {
                          context.go('/settings');
                        } else if (value == 'profile') {
                          context.go('/profile');
                        } else if (value == 'logout') {
                          ref.read(authProvider.notifier).logout();
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: ListTile(
                            leading:
                                Icon(Icons.settings, color: Colors.blueGrey),
                            title: Text(
                              'Settings',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading:
                                Icon(Icons.logout, color: Colors.redAccent),
                            title: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            color: const Color(0xFF08273A),
            child: healthState.when(
              data: (data) => HealthStatsBar(
                bpm: data.bpm.toString(),
                spo2: data.spo2.toString(),
              ),
              loading: () => const HealthStatsBar(
                bpm: '...',
                spo2: '...',
              ),
              error: (error, stackTrace) => const HealthStatsBar(
                bpm: 'Err',
                spo2: 'Err',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(105);
}
