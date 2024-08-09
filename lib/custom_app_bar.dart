import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSwapUser;
  final Function onReload;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onSwapUser,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: () => {onSwapUser(), onReload()},
          child: const Text(
            'Swap User',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
