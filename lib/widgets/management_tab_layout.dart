import 'package:flutter/material.dart';

import '../models/ui_text_catalog.dart';

class ManagementTabLayout extends StatelessWidget {
  const ManagementTabLayout({
    required this.text,
    required this.form,
    required this.recordsTitle,
    required this.records,
    this.title,
    super.key,
  });

  final UiTextCatalog text;
  final Widget form;
  final String? title;
  final String recordsTitle;
  final Widget records;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final maxWidth = text.number('maxWidth', tab: 'layout');
      final width = constraints.maxWidth < maxWidth
          ? constraints.maxWidth
          : maxWidth;
      return SingleChildScrollView(
        padding: EdgeInsets.all(text.number('pagePadding', tab: 'layout')),
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
                SizedBox(height: text.number('sectionSpacing', tab: 'layout')),
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
