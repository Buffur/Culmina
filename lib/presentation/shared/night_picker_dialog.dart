import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_theme.dart';

/// A content-sized calendar at standard text size with Material controls,
/// YearPicker, validated date input and the local-date Cancel/OK contract.
class NightPickerDialog extends StatefulWidget {
  const NightPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<NightPickerDialog> createState() => _NightPickerDialogState();
}

class _NightPickerDialogState extends State<NightPickerDialog> {
  late DateTime _selected = widget.initialDate;
  final _form = GlobalKey<FormState>();
  bool _input = false;
  bool _years = false;
  late DateTime _month = DateTime(_selected.year, _selected.month);

  void _confirm() {
    if (_input) {
      if (!_form.currentState!.validate()) return;
      _form.currentState!.save();
    }
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    // Keep the existing native large-text behavior; this task refines 100%.
    // This chooses a composition, never alters the user's text scaler.
    if (MediaQuery.textScalerOf(context).scale(1) > 1) {
      return DatePickerDialog(
        initialDate: widget.initialDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        helpText: 'Choose a night',
      );
    }
    final localizations = MaterialLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            key: const Key('nightPicker.content'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.itemGap,
                  AppSpacing.sm,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Choose a night'),
                          const SizedBox(height: AppSpacing.xs),
                          Semantics(
                            header: true,
                            child: Text(
                              localizations.formatMediumDate(_selected),
                              style: AppTextTheme.of(context).nightHeading,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('nightPicker.inputMode'),
                      tooltip: _input
                          ? localizations.calendarModeButtonLabel
                          : localizations.inputDateModeButtonLabel,
                      onPressed: () {
                        if (_input) {
                          if (!_form.currentState!.validate()) return;
                          _form.currentState!.save();
                          _month = DateTime(_selected.year, _selected.month);
                        }
                        setState(() => _input = !_input);
                      },
                      icon: Icon(
                        _input ? Icons.calendar_today : Icons.edit_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              if (_input)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Form(
                    key: _form,
                    child: InputDatePickerFormField(
                      initialDate: _selected,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                      autofocus: true,
                      onDateSaved: (date) => _selected = date,
                      onDateSubmitted: (date) {
                        _selected = date;
                        _confirm();
                      },
                    ),
                  ),
                )
              else
                _calendar(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  0,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: AppSpacing.sm,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(localizations.cancelButtonLabel),
                    ),
                    TextButton(
                      onPressed: _confirm,
                      child: Text(localizations.okButtonLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendar(BuildContext context) {
    final labels = MaterialLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    final leading = (_month.weekday % 7 - labels.firstDayOfWeekIndex + 7) % 7;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  key: const Key('nightPicker.year'),
                  onPressed: () => setState(() => _years = !_years),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(labels.formatMonthYear(_month)),
                  ),
                ),
              ),
              IconButton(
                tooltip: labels.previousMonthTooltip,
                onPressed: _years || !_month.isAfter(firstMonth)
                    ? null
                    : () => setState(
                        () => _month = DateTime(_month.year, _month.month - 1),
                      ),
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: labels.nextMonthTooltip,
                onPressed: _years || !_month.isBefore(lastMonth)
                    ? null
                    : () => setState(
                        () => _month = DateTime(_month.year, _month.month + 1),
                      ),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        if (_years)
          SizedBox(
            height: 288,
            child: YearPicker(
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              selectedDate: _month,
              onChanged: (date) => setState(() {
                final month = DateTime(date.year, _month.month);
                _month = month.isBefore(firstMonth)
                    ? firstMonth
                    : month.isAfter(lastMonth)
                    ? lastMonth
                    : month;
                _years = false;
              }),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 7 * 48) {
                return _DateChoiceList(
                  key: ValueKey(
                    'nightPicker.list.${_month.year}.${_month.month}',
                  ),
                  month: _month,
                  selected: _selected,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onSelected: (date) => setState(() => _selected = date),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: Center(
                            child: Text(
                              labels.narrowWeekdays[(labels
                                          .firstDayOfWeekIndex +
                                      i) %
                                  7],
                              style: AppTextTheme.of(context).caption,
                            ),
                          ),
                        ),
                    ],
                  ),
                  GridView.builder(
                    key: ValueKey(
                      'nightPicker.month.${_month.year}.${_month.month}',
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisExtent: 48,
                        ),
                    itemCount: leading + days,
                    itemBuilder: (context, index) {
                      if (index < leading) return const SizedBox.shrink();
                      final date = DateTime(
                        _month.year,
                        _month.month,
                        index - leading + 1,
                      );
                      final selected = DateUtils.isSameDay(date, _selected);
                      final enabled =
                          !date.isBefore(widget.firstDate) &&
                          !date.isAfter(widget.lastDate);
                      void choose() => setState(() => _selected = date);
                      return Semantics(
                        label: labels.formatFullDate(date),
                        selected: selected,
                        button: true,
                        enabled: enabled,
                        onTap: enabled ? choose : null,
                        excludeSemantics: true,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                            foregroundColor: selected
                                ? scheme.onPrimary
                                : scheme.onSurface,
                            textStyle:
                                Theme.of(context).datePickerTheme.dayStyle ??
                                AppTextTheme.of(context).body,
                          ),
                          onPressed: enabled ? choose : null,
                          child: ExcludeSemantics(
                            child: SizedBox.square(
                              dimension: 40,
                              child: DecoratedBox(
                                decoration: ShapeDecoration(
                                  color: selected ? scheme.primary : null,
                                  shape: CircleBorder(
                                    side:
                                        !selected &&
                                            DateUtils.isSameDay(
                                              date,
                                              DateTime.now(),
                                            )
                                        ? BorderSide(color: scheme.primary)
                                        : BorderSide.none,
                                  ),
                                ),
                                child: Center(
                                  child: Text(labels.formatDecimal(date.day)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// The approved narrow-width date list; wider calendars retain their grid.
class _DateChoiceList extends StatefulWidget {
  const _DateChoiceList({
    super.key,
    required this.month,
    required this.selected,
    required this.firstDate,
    required this.lastDate,
    required this.onSelected,
  });
  final DateTime month;
  final DateTime selected;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelected;

  @override
  State<_DateChoiceList> createState() => _DateChoiceListState();
}

class _DateChoiceListState extends State<_DateChoiceList> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    final days = DateUtils.getDaysInMonth(
      widget.month.year,
      widget.month.month,
    );
    final selectedMonth =
        widget.selected.year == widget.month.year &&
        widget.selected.month == widget.month.month;
    _scroll = ScrollController(
      initialScrollOffset:
          ((selectedMonth ? widget.selected.day - 1 : 0) * 48.0).clamp(
            0.0,
            (days - 6) * 48.0,
          ),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = MaterialLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      key: const Key('nightPicker.dates'),
      height: 6 * 48,
      child: ListView.builder(
        key: PageStorageKey(
          'nightPicker.dates.${widget.month.year}.${widget.month.month}',
        ),
        controller: _scroll,
        padding: EdgeInsets.zero,
        itemExtent: 48,
        itemCount: DateUtils.getDaysInMonth(
          widget.month.year,
          widget.month.month,
        ),
        itemBuilder: (context, index) {
          final date = DateTime(
            widget.month.year,
            widget.month.month,
            index + 1,
          );
          final selected = DateUtils.isSameDay(date, widget.selected);
          final enabled =
              !date.isBefore(widget.firstDate) &&
              !date.isAfter(widget.lastDate);
          void choose() => widget.onSelected(date);
          return Semantics(
            label: labels.formatFullDate(date),
            selected: selected,
            button: true,
            enabled: enabled,
            onTap: enabled ? choose : null,
            excludeSemantics: true,
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                foregroundColor: selected ? scheme.onPrimary : scheme.onSurface,
                backgroundColor: selected ? scheme.primary : null,
                textStyle:
                    Theme.of(context).datePickerTheme.dayStyle ??
                    AppTextTheme.of(context).body,
              ),
              onPressed: enabled ? choose : null,
              child: Row(
                children: [
                  Expanded(child: Text(labels.formatMediumDate(date))),
                  if (selected) const Icon(Icons.check, size: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
