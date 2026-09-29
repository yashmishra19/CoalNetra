import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Digital Inspection Checklist – category-specific checklist for
/// Safety, Environment, Labour, and Equipment inspections.
class InspectionChecklistScreen extends StatefulWidget {
  const InspectionChecklistScreen({super.key});

  @override
  State<InspectionChecklistScreen> createState() =>
      _InspectionChecklistScreenState();
}

class _InspectionChecklistScreenState
    extends State<InspectionChecklistScreen> {
  final List<_ChecklistCategory> _categories = [
    _ChecklistCategory(
      name: 'Safety',
      icon: Icons.health_and_safety,
      color: AppTheme.redDanger,
      items: [
        _CheckItem('Roof bolt condition checked at all faces', false),
        _CheckItem('Gas readings (CH₄ < 0.8%, CO < 25ppm)', false),
        _CheckItem('Fire extinguisher accessible & charged', true),
        _CheckItem('Emergency escape route clear', false),
        _CheckItem('Self-rescue devices issued to all workers', true),
        _CheckItem('First-aid kit stocked and accessible', true),
        _CheckItem('No loose stones / overhangs at face', false),
        _CheckItem('Shot-firing cable secured and tagged', true),
      ],
    ),
    _ChecklistCategory(
      name: 'Environment',
      icon: Icons.eco,
      color: AppTheme.greenVerified,
      items: [
        _CheckItem('Dust suppression water sprays operational', false),
        _CheckItem('Dust mask compliance ≥95% workers', false),
        _CheckItem('Sump water turbidity within limits', true),
        _CheckItem('Noise levels at haul roads within limits', true),
        _CheckItem('Waste dump stability – no slippage signs', false),
        _CheckItem('Diesel vehicles exhaust within norms', true),
      ],
    ),
    _ChecklistCategory(
      name: 'Labour',
      icon: Icons.groups,
      color: AppTheme.cobaltBlue,
      items: [
        _CheckItem('Workers attendance recorded biometrically', true),
        _CheckItem('No child / bonded labour present', true),
        _CheckItem('PPE worn by all workers on shift', false),
        _CheckItem('Overtime not exceeding 2 hrs/day', true),
        _CheckItem('Rest breaks provided every 4 hours', true),
        _CheckItem('Women workers not deployed underground', true),
      ],
    ),
    _ChecklistCategory(
      name: 'Equipment',
      icon: Icons.construction,
      color: AppTheme.amberAccent,
      items: [
        _CheckItem('Conveyor belt tension & alignment checked', false),
        _CheckItem('Winding engine pre-shift test done', false),
        _CheckItem('Electrical earth continuity tested', true),
        _CheckItem('Ventilation fan operational (no bypass)', true),
        _CheckItem('Dewatering pump serviceable', false),
        _CheckItem('HEMM vehicles daily pre-use inspection', true),
      ],
    ),
  ];

  int _activeCategoryIndex = 0;

  _ChecklistCategory get _active => _categories[_activeCategoryIndex];

  int get _completedCount =>
      _active.items.where((i) => i.checked).length;

  double get _progress =>
      _active.items.isEmpty ? 0 : _completedCount / _active.items.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhiteBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.nearBlackCoal,
        foregroundColor: Colors.white,
        title: const Text('Digital Inspection Checklist',
            style: TextStyle(fontSize: 16)),
        actions: [
          TextButton.icon(
            onPressed: _submitChecklist,
            icon: const Icon(Icons.send, color: AppTheme.amberAccent, size: 18),
            label: const Text('SUBMIT',
                style: TextStyle(
                    color: AppTheme.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_categories.length, (i) {
                final cat = _categories[i];
                final isActive = i == _activeCategoryIndex;
                final done = cat.items.where((it) => it.checked).length;
                return GestureDetector(
                  onTap: () => setState(() => _activeCategoryIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? cat.color.withAlpha(25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isActive ? cat.color : Colors.transparent,
                          width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Icon(cat.icon,
                            color: isActive ? cat.color : Colors.grey,
                            size: 22),
                        const SizedBox(height: 4),
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isActive ? cat.color : Colors.grey,
                          ),
                        ),
                        Text(
                          '$done/${cat.items.length}',
                          style: TextStyle(
                              fontSize: 9,
                              color: isActive ? cat.color : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Progress
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(_progress * 100).round()}% Complete',
                      style: TextStyle(
                          fontSize: 12,
                          color: _active.color,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_completedCount of ${_active.items.length} items',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_active.color),
                  ),
                ),
              ],
            ),
          ),

          // Checklist items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _active.items.length,
              itemBuilder: (context, i) {
                final item = _active.items[i];
                return _buildCheckItem(item, i);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(_CheckItem item, int index) {
    return GestureDetector(
      onTap: () => setState(() => item.checked = !item.checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.checked
              ? _active.color.withAlpha(12)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: item.checked ? _active.color.withAlpha(80) : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.checked ? _active.color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: item.checked ? _active.color : Colors.grey[300]!,
                    width: 2),
              ),
              child: item.checked
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  decoration:
                      item.checked ? TextDecoration.lineThrough : null,
                  color: item.checked ? Colors.grey : AppTheme.nearBlackCoal,
                ),
              ),
            ),
            if (!item.checked)
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined,
                    size: 18, color: Colors.grey),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Camera: Attach photo evidence'),
                        duration: Duration(seconds: 1)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _submitChecklist() {
    final pending = _active.items.where((i) => !i.checked).length;
    if (pending > 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Incomplete Checklist'),
          content: Text(
              '$pending items are unchecked. Do you want to submit with remarks?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSubmitSuccess();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.amberAccent),
              child: const Text('Submit Anyway'),
            ),
          ],
        ),
      );
    } else {
      _showSubmitSuccess();
    }
  }

  void _showSubmitSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
                '${_active.name} checklist submitted · GPS + timestamp recorded'),
          ],
        ),
        backgroundColor: AppTheme.greenVerified,
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context);
  }
}

class _ChecklistCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<_CheckItem> items;

  _ChecklistCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _CheckItem {
  final String label;
  bool checked;

  _CheckItem(this.label, this.checked);
}
