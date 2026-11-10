import 'package:flutter/material.dart';

import '../core/checklists.dart';
import '../core/scoring.dart';
import 'risk_gauge.dart';

class ChecklistPanel extends StatefulWidget {
  const ChecklistPanel({
    super.key,
    required this.items,
    this.mode = ChecklistMode.checkbox,
  });

  final List<ChecklistItem> items;
  final ChecklistMode mode;

  @override
  State<ChecklistPanel> createState() => ChecklistPanelState();
}

enum ChecklistMode { checkbox, yesNo }

class ChecklistPanelState extends State<ChecklistPanel> {
  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<bool>.filled(widget.items.length, false);
  }

  int evaluate() {
    final weights = widget.items.map((e) => e.weight).toList();
    final score = scoreWeighted(weights, _selected);
    setState(() {});
    return score;
  }

  void reset() {
    setState(() {
      _selected = List<bool>.filled(widget.items.length, false);
    });
  }

  List<bool> get selected => List.unmodifiable(_selected);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: widget.mode == ChecklistMode.checkbox
                ? CheckboxListTile(
                    value: _selected[i],
                    onChanged: (v) => setState(() => _selected[i] = v ?? false),
                    title: Text(widget.items[i].question),
                    subtitle: widget.items[i].hint != null
                        ? Text(widget.items[i].hint!)
                        : null,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )
                : _YesNoRow(
                    question: widget.items[i].question,
                    value: _selected[i],
                    onChanged: (v) => setState(() => _selected[i] = v),
                  ),
          ),
      ],
    );
  }
}

class _YesNoRow extends StatelessWidget {
  const _YesNoRow({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final String question;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: value
                          ? const Color(0xFFC53030)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor: value ? Colors.white : null,
                    ),
                    onPressed: () => onChanged(true),
                    child: const Text('ใช่'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !value
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                    ),
                    onPressed: () => onChanged(false),
                    child: const Text('ไม่ใช่'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EvalActions extends StatelessWidget {
  const EvalActions({
    super.key,
    required this.onEval,
    required this.onReset,
  });

  final VoidCallback onEval;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onEval,
            child: const Text('ประเมินผล'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: onReset,
            child: const Text('ล้างคำตอบ'),
          ),
        ),
      ],
    );
  }
}

class ChecklistScreenBody extends StatefulWidget {
  const ChecklistScreenBody({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    this.mode = ChecklistMode.checkbox,
    this.leading,
  });

  final String title;
  final String subtitle;
  final List<ChecklistItem> items;
  final ChecklistMode mode;
  final Widget? leading;

  @override
  State<ChecklistScreenBody> createState() => _ChecklistScreenBodyState();
}

class _ChecklistScreenBodyState extends State<ChecklistScreenBody> {
  final _key = GlobalKey<ChecklistPanelState>();
  int? _score;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
        if (widget.leading != null) ...[
          const SizedBox(height: 12),
          widget.leading!,
        ],
        const SizedBox(height: 16),
        ChecklistPanel(key: _key, items: widget.items, mode: widget.mode),
        const SizedBox(height: 8),
        EvalActions(
          onEval: () {
            final score = _key.currentState?.evaluate() ?? 0;
            setState(() => _score = score);
          },
          onReset: () {
            _key.currentState?.reset();
            setState(() => _score = null);
          },
        ),
        if (_score != null) ...[
          const SizedBox(height: 16),
          RiskResultCard(score: _score!),
        ],
      ],
    );
  }
}
