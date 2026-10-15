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
