import 'package:flutter/material.dart';

class MapTopBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onHide;

  const MapTopBar({super.key, required this.controller, required this.onHide});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Search location…',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            IconButton(
              onPressed: onHide,
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
              tooltip: 'Hide search',
            ),
          ],
        ),
      ),
    );
  }
}

class MapTopBarCollapsedButton extends StatelessWidget {
  final VoidCallback onShow;

  const MapTopBarCollapsedButton({super.key, required this.onShow});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: IconButton(
        onPressed: onShow,
        icon: const Icon(Icons.search),
        tooltip: 'Show search',
      ),
    );
  }
}
