import 'package:flutter/material.dart';

class DataAnalysisAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DataAnalysisAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Data Analysis'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
