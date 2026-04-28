import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/core/widgets/empty_state_widget.dart';
import 'package:med_assist/features/shopping_list/models/shopping_list_item.dart';
import 'package:med_assist/features/shopping_list/providers/shopping_list_providers.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final Set<int> _inCartIds = {};
  final Set<int> _doneIds = {};

  void _refreshData() {
    ProviderRefreshUtils.refreshStockProviders(ref);
    ref.invalidate(shoppingListItemsProvider);
    ref.invalidate(shoppingListGroupsProvider);
  }

  void _markDone(ShoppingListItem item) {
    setState(() {
      _inCartIds.remove(item.medication.id);
      _doneIds.add(item.medication.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(item.medication.medicineName),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.undo,
          onPressed: () => setState(() {
            _doneIds.remove(item.medication.id);
          }),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<ShoppingListItem> _unique(List<ShoppingListItem> items) {
    final byId = <int, ShoppingListItem>{};
    for (final item in items) {
      byId[item.medication.id] = item;
    }
    return byId.values.toList()..sort(
      (a, b) => a.medication.medicineName.compareTo(b.medication.medicineName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final groupsAsync = ref.watch(shoppingListGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppingList),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: groupsAsync.when(
          data: (groups) {
            final urgent = groups[ShoppingListGroup.urgentRefill] ?? [];
            final expiring = groups[ShoppingListGroup.expiringSoon] ?? [];
            final all = _unique([...urgent, ...expiring]);

            final toBuy = all
                .where(
                  (i) =>
                      !_inCartIds.contains(i.medication.id) &&
                      !_doneIds.contains(i.medication.id),
                )
                .toList();
            final inCart = all
                .where((i) => _inCartIds.contains(i.medication.id))
                .toList();
            final done = all
                .where((i) => _doneIds.contains(i.medication.id))
                .toList();

            if (all.isEmpty) {
              return _EmptyState();
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary chip
                Card(
                  color: cs.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_checkout_rounded,
                          color: cs.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.itemsToRefill(all.length),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (done.isNotEmpty)
                          Chip(
                            label: Text('${done.length}/${all.length}'),
                            backgroundColor: cs.secondaryContainer,
                            labelStyle: TextStyle(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (toBuy.isNotEmpty) ...[
                  _SectionLabel(label: l10n.toBuy, icon: Icons.circle_outlined),
                  const SizedBox(height: 8),
                  ...toBuy.map(
                    (item) => _SwipeableItem(
                      key: ValueKey('buy-${item.medication.id}'),
                      item: item,
                      onAddToCart: () => setState(
                        () => _inCartIds.add(item.medication.id),
                      ),
                      onDone: () => _markDone(item),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (inCart.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.inCart,
                    icon: Icons.shopping_cart_outlined,
                  ),
                  const SizedBox(height: 8),
                  ...inCart.map(
                    (item) => _SwipeableItem(
                      key: ValueKey('cart-${item.medication.id}'),
                      item: item,
                      inCart: true,
                      onAddToCart: () => setState(
                        () => _inCartIds.remove(item.medication.id),
                      ),
                      onDone: () => _markDone(item),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (done.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.done,
                    icon: Icons.check_circle_outline,
                    muted: true,
                  ),
                  const SizedBox(height: 8),
                  ...done.map(
                    (item) => _DoneItem(
                      key: ValueKey('done-${item.medication.id}'),
                      item: item,
                      onUndo: () => setState(
                        () => _doneIds.remove(item.medication.id),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error: $error'),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.icon,
    this.muted = false,
  });

  final String label;
  final IconData icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = muted ? cs.onSurfaceVariant : cs.primary;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _SwipeableItem extends StatelessWidget {
  const _SwipeableItem({
    required this.item,
    required this.onAddToCart,
    required this.onDone,
    this.inCart = false,
    super.key,
  });

  final ShoppingListItem item;
  final VoidCallback onAddToCart;
  final VoidCallback onDone;
  final bool inCart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key('dismiss-${item.medication.id}-$inCart'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.check, color: cs.onPrimaryContainer),
      ),
      onDismissed: (_) => onDone(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: InkWell(
            onTap: onAddToCart,
            borderRadius: BorderRadius.circular(20),
            child: Icon(
              inCart ? Icons.shopping_cart : Icons.circle_outlined,
              color: inCart ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          title: Text(item.medication.medicineName),
          subtitle: Text(
            '${item.currentStock} left · ${item.daysRemaining.toStringAsFixed(0)}d',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          trailing: item.isCriticalStock
              ? Icon(Icons.warning_rounded, color: cs.error, size: 20)
              : null,
        ),
      ),
    );
  }
}

class _DoneItem extends StatelessWidget {
  const _DoneItem({
    required this.item,
    required this.onUndo,
    super.key,
  });

  final ShoppingListItem item;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cs.surfaceContainerLow,
      child: ListTile(
        leading: Icon(Icons.check_circle, color: cs.secondary),
        title: Text(
          item.medication.medicineName,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        trailing: TextButton(
          onPressed: onUndo,
          child: Text(AppLocalizations.of(context)!.undo),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: EmptyStateWidget(
        icon: Icons.shopping_bag_outlined,
        title: l10n.noItemsNeeded,
        subtitle: l10n.noItemsNeededSubtitle,
      ),
    );
  }
}
