import 'package:flutter/material.dart';
import 'package:retur/screens/journeys.dart';
import 'package:retur/screens/settings.dart';
import 'package:retur/theme.dart';

/// Root scaffold holding the bottom navbar. Pages are kept alive in an
/// IndexedStack so switching tabs preserves their state.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  static const _pages = [Journeys(), Settings()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _NavBar(
        index: _index,
        onSelect: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Each tab is a pill (icon + label together) styled like the app's buttons:
/// the selected one borrows the ElevatedButton theme's colors.
class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pillColor =
        AppColors.of(context).accentFill.withValues(alpha: 50 / 255);
    final selectedColor = theme.colorScheme.primary;
    final idleColor = theme.colorScheme.onSurfaceVariant;

    Widget tab(int i, IconData icon, IconData selectedIcon, String label) {
      final selected = index == i;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelect(i),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? pillColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selected ? selectedIcon : icon,
                      size: 22, color: selected ? selectedColor : idleColor),
                  const SizedBox(height: 3),
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          color: selected ? selectedColor : idleColor)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        height: 66, // a bottom bar needs a bounded height; pills center within it
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            tab(0, Icons.commute_outlined, Icons.commute, "Journeys"),
            tab(1, Icons.settings_outlined, Icons.settings, "Settings"),
          ],
        ),
      ),
    );
  }
}
