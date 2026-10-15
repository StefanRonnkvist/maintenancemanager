import 'package:flutter/material.dart';

class ManagementTabLayout extends StatelessWidget {
  const ManagementTabLayout({
    required this.title,
    required this.icon,
    required this.form,
    required this.recordsTitle,
    required this.records,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget form;
  final String recordsTitle;
  final Widget records;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth < 1100 ? constraints.maxWidth : 1100.0;
      final colors = Theme.of(context).colorScheme;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(icon, size: 48, color: colors.primary),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        form,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  recordsTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                records,
              ],
            ),
          ),
        ),
      );
    },
  );
}
