import 'package:flutter/material.dart';

import '../models/app_tab.dart';

class SparePartsTab extends StatelessWidget {
  const SparePartsTab({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          AppTab.spareParts.icon,
          size: 56,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          AppTab.spareParts.label,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    ),
  );
}
