import 'package:flutter/material.dart';

class ManagementTabLayout extends StatelessWidget {
  const ManagementTabLayout({
    required this.form,
    required this.recordsTitle,
    required this.records,
    this.title,
    super.key,
  });

  final Widget form;
  final String? title;
  final String recordsTitle;
  final Widget records;

  static const double maxWidth = 1100;
  static const EdgeInsets pagePadding = EdgeInsets.all(20);
  static const double sectionSpacing = 24;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth < maxWidth
          ? constraints.maxWidth
          : maxWidth;
      return SingleChildScrollView(
        padding: pagePadding,
        child: Center(
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                ],
                form,
                const SizedBox(height: sectionSpacing),
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
