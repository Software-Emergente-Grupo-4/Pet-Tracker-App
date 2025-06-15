import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_tracker/features/navigation/presentation/providers/navigation_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final navigationNotifier = ref.read(navigationProvider.notifier);

    return BottomNavigationBar(
      currentIndex: navigationState.selectedIndex,
      onTap: (index) {
        navigationNotifier.updateIndex(index);
        if (index == 0) context.go('/');
        if (index == 1) context.go('/activities');
        if (index == 2) context.go('/chat');
        if (index == 3) context.go('/vital-signs');
        if (index == 4) context.go('/geofences');
      },
      
      backgroundColor:
          const Color(0xFF08273A),
      selectedItemColor: Colors.white,
      unselectedItemColor:
          Colors.white54,
      selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold),
      unselectedLabelStyle:
          const TextStyle(fontSize: 12),
      type: BottomNavigationBarType.fixed,

      showUnselectedLabels: false,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Activities',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Vital signs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Geofences',
        ),
      ],
    );
  }
}
