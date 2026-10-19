import 'package:flutter/material.dart';

/// Common responsive frame for a management form and its records section.
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
      final availableWidth = constraints.maxWidth;
      final isPhone = availableWidth < 600;
      final isTablet = availableWidth >= 600 && availableWidth < 1100;
      final horizontalPadding = isPhone ? 12.0 : (isTablet ? 20.0 : 28.0);
      final contentWidth = availableWidth < 1100 ? availableWidth : 1100.0;
      final cardPadding = isPhone ? 16.0 : (isTablet ? 20.0 : 24.0);

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isPhone ? 12 : 20,
        ),
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: form,
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
