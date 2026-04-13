import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/features/shopping_list/models/shopping_list_item.dart';
import 'package:med_assist/features/shopping_list/providers/shopping_list_providers.dart';
import 'package:med_assist/features/shopping_list/widgets/pharmacy_checklist_card.dart';
import 'package:med_assist/features/shopping_list/widgets/shopping_list_group_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final Set<int> _checkedMedicationIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
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
            final allItems = _uniqueItems([...urgent, ...expiring]);

            if (allItems.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.noItemsNeeded,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      l10n.noItemsNeededSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_checkout_rounded,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.itemsToRefill(allItems.length),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ShoppingListGroupCard(
                  title: l10n.urgentRefill,
                  icon: Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  items: urgent,
                ),
                ShoppingListGroupCard(
                  title: l10n.planAhead,
                  icon: Icons.event_note_rounded,
                  color: colorScheme.tertiary,
                  items: expiring,
                ),
                PharmacyChecklistCard(
                  items: allItems,
                  checkedMedicationIds: _checkedMedicationIds,
                  onToggleMedication: _toggleMedication,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('${l10n.errorLoadingStock}: $error'),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleMedication(int medicationId) {
    setState(() {
      if (_checkedMedicationIds.contains(medicationId)) {
        _checkedMedicationIds.remove(medicationId);
      } else {
        _checkedMedicationIds.add(medicationId);
      }
    });
  }

  void _refreshData() {
    ProviderRefreshUtils.refreshStockProviders(ref);
    ref.invalidate(shoppingListItemsProvider);
    ref.invalidate(shoppingListGroupsProvider);
  }

  List<ShoppingListItem> _uniqueItems(List<ShoppingListItem> items) {
    final byId = <int, ShoppingListItem>{};
    for (final item in items) {
      byId[item.medication.id] = item;
    }
    final unique = byId.values.toList();
    unique.sort(
      (a, b) => a.medication.medicineName.compareTo(b.medication.medicineName),
    );
    return unique;
  }
}
