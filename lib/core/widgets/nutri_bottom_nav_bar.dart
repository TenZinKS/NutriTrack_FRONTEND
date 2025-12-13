import 'package:flutter/material.dart';

class NutriBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final VoidCallback? onAddTap;
  final bool isAddDisabled;

  const NutriBottomNavBar({
    super.key,
    required this.selectedIndex,
    this.onItemSelected,
    this.onAddTap,
    this.isAddDisabled = false,
  });

  static const _activeColor = Color(0xFF20C86B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: Colors.white10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavButton(icon: Icons.home_filled, index: 0),
            _buildNavButton(icon: Icons.show_chart_rounded, index: 1),
            _buildAddButton(),
            _buildNavButton(icon: Icons.restaurant_menu, index: 3),
            _buildNavButton(icon: Icons.settings, index: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required int index,
  }) {
    final isActive = selectedIndex == index;
    final color = isActive ? Colors.white : Colors.white70;
    final background = isActive ? _activeColor : Colors.transparent;

    return GestureDetector(
      onTap: () => onItemSelected?.call(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _buildAddButton() {
    final background = isAddDisabled ? Colors.white54 : Colors.white;
    return GestureDetector(
      onTap: isAddDisabled ? null : onAddTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: [
            if (!isAddDisabled)
              const BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: isAddDisabled ? Colors.black45 : Colors.black,
          size: 32,
        ),
      ),
    );
  }
}
