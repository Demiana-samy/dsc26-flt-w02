import 'package:flutter/material.dart';

import '../view_models/alerts_view_model.dart';
import '../../../domain/models/stock_alert.dart';

/// The branch alerts screen.
///
/// Shows what the view model exposes and forwards taps to it.
/// No business rules (sorting, filtering) live here.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, required this.viewModel});

  final AlertsViewModel viewModel;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(AlertsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.removeListener(_onChanged);
      widget.viewModel.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final alerts = vm.visibleAlerts;
    final count = alerts.length;
    final countText = count == 1 ? '1 alert' : '$count alerts';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nour Shelf – Branch Alerts'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search field ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              key: const Key('search-field'),
              decoration: const InputDecoration(
                hintText: 'Search medicines…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: vm.setQuery,
            ),
          ),

          // ── Severity filter chips ────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                for (final sev in Severity.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      key: Key('filter-${sev.name}'),
                      label: Text(_severityLabel(sev)),
                      selected: vm.activeFilters.contains(sev),
                      selectedColor: _severityColor(sev).withAlpha(80),
                      onSelected: (_) => vm.toggleFilter(sev),
                    ),
                  ),
              ],
            ),
          ),

          // ── Count ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              countText,
              key: const Key('alerts-count'),
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.black54),
            ),
          ),

          // ── Content area ─────────────────────────────────────────────────
          Expanded(
            child: vm.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      key: Key('alerts-loading'),
                    ),
                  )
                : alerts.isEmpty
                    ? const Center(
                        child: Text(
                          'No alerts match your filters.',
                          key: Key('alerts-empty'),
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    : ListView.separated(
                        key: const Key('alerts-list'),
                        itemCount: alerts.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final alert = alerts[i];
                          return _AlertRow(
                            alert: alert,
                            onAcknowledge: () => vm.acknowledge(alert.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _severityLabel(Severity sev) {
    switch (sev) {
      case Severity.critical:
        return 'Critical';
      case Severity.high:
        return 'High';
      case Severity.medium:
        return 'Medium';
      case Severity.low:
        return 'Low';
    }
  }

  Color _severityColor(Severity sev) {
    switch (sev) {
      case Severity.critical:
        return Colors.red;
      case Severity.high:
        return Colors.orange;
      case Severity.medium:
        return Colors.amber;
      case Severity.low:
        return Colors.green;
    }
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert, required this.onAcknowledge});

  final StockAlert alert;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('alert-${alert.id}'),
      leading: _SeverityBadge(severity: alert.severity),
      title: Text(alert.medicineNameEn),
      subtitle: Text('${alert.medicineNameAr} · ${alert.branchCode}'),
      trailing: alert.acknowledged
          ? const Icon(Icons.check_circle, color: Colors.green)
          : IconButton(
              key: Key('ack-${alert.id}'),
              icon: const Icon(Icons.notifications_active),
              color: Colors.teal,
              tooltip: 'Acknowledge',
              onPressed: onAcknowledge,
            ),
      tileColor: alert.acknowledged ? Colors.grey[50] : null,
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final label = severity.name[0].toUpperCase();
    return CircleAvatar(
      backgroundColor: color,
      foregroundColor: Colors.white,
      radius: 18,
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Color _color() {
    switch (severity) {
      case Severity.critical:
        return Colors.red[700]!;
      case Severity.high:
        return Colors.orange[700]!;
      case Severity.medium:
        return Colors.amber[700]!;
      case Severity.low:
        return Colors.green[600]!;
    }
  }
}
