import 'package:phone_cleaner/src/features/file/views/expand_button.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'clean_checkbox.dart';

class CleanerCategory extends StatefulWidget {
  const CleanerCategory({
    super.key,
    this.checkboxStatus,
    this.icon,
    required this.title,
    this.subtitle = '',
    this.trailing,
    this.hideHeader = false,
    this.initiallyExpanded = false,
    this.onSelect,
    this.onExpanded,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 0, 8),
    this.childSliver,
  });

  final Widget? icon;
  final String title;
  final String subtitle;
  final CheckboxStatus? checkboxStatus;
  final bool hideHeader;
  final bool initiallyExpanded;
  final Widget? trailing;
  final ValueChanged<CheckboxStatus?>? onSelect;
  final ValueChanged<bool>? onExpanded;
  final EdgeInsets padding;
  final Widget? childSliver;

  @override
  State<CleanerCategory> createState() => _CleanerCategoryState();
}

class _CleanerCategoryState extends State<CleanerCategory> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;
  }

  void onSelect() {
    if (widget.onSelect == null) return;
    // if (widget.checkboxStatus == null) return;

    widget.onSelect!(widget.checkboxStatus == CheckboxStatus.unchecked
        ? CheckboxStatus.checked
        : CheckboxStatus.unchecked);
  }

  void setExpanded(bool expanded) => setState(() => isExpanded = expanded);

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    Widget? checkbox = widget.checkboxStatus != null
        ? CleanCheckbox(
            checkboxStatus: widget.checkboxStatus!,
            onChanged: widget.onSelect ?? (_) {})
        : null;

    final backgroundColor = widget.checkboxStatus == CheckboxStatus.unchecked ||
            widget.checkboxStatus == null
        ? Colors.transparent
        : cleanerColor.primary1;

    final title = Text(
      widget.title,
      style: semibold16.copyWith(
        fontWeight: FontWeight.w500,
        color: cleanerColor.primary10,
      ),
    );
    final subtitle = Text(
      widget.subtitle,
      style: TextStyle(
          fontSize: 12,
          color: widget.checkboxStatus != CheckboxStatus.unchecked
              ? cleanerColor.primary7
              : cleanerColor.neutral5),
    );

    Widget? expandButton = widget.trailing;

    if (widget.childSliver != null) {
      expandButton = expandButton ??
          ExpandButton(
            isExpanded: isExpanded,
            valueChanged: (expanded) {
              if (widget.onExpanded != null) {
                widget.onExpanded!(expanded);
              }

              setExpanded(expanded);
            },
          );
    }

    Widget header = Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          if (checkbox != null) checkbox,
          if (checkbox != null) const SizedBox(width: 10),
          if (widget.icon != null) widget.icon!,
          if (widget.icon != null) const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(
                height: 4,
              ),
              subtitle,
            ],
          ),
          const Spacer(),
          if (expandButton != null) expandButton
        ],
      ),
    );

    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Material(
            color: backgroundColor,
            child: InkWell(
              onTap: () => onSelect(),
              child: Padding(
                padding: widget.padding,
                child: header,
              ),
            ),
          ),
        ),
        if (isExpanded) widget.childSliver!
      ],
    );
  }
}
