import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'order_form_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            // Add order — open as modal page and stay on Home
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderFormScreen()),
            );
            return;
          }
          setState(() => _selectedIndex = index);
        },
        height: kBottomNavigationBarHeight,
        backgroundColor: const Color(0xFFf3f6ff),
        indicatorColor: primary.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle_rounded, color: primary),
            label: 'Add Booking',
          ),
        ],
      ),
    );
  }
}
