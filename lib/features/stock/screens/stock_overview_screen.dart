import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/core/widgets/animated_card.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';
import 'package:med_assist/features/stock/widgets/stock_card.dart';
import 'package:med_assist/features/stock/widgets/stock_empty_state.dart';
import 'package:med_assist/features/stock/widgets/stock_stat_item.dart';
import 'package:med_assist/l10n/app_localizations.dart';

enum _StockFilter { all, low, out }

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      iconTheme: IconThemeData(
        color: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Stock Overview Screen — shows medications with stock levels,
/// filterable by All / Low / Out.
class StockOverviewScreen extends ConsumerStatefulWidget {
  const StockOverviewScreen({super.key});

  @override
  ConsumerState<StockOverviewScreen> createState() =>
      _StockOverviewScreenState();
}

class _StockOverviewScreenState extends ConsumerState<StockOverviewScreen> {
  _StockFilter _filter = _StockFilter.all;

  List<MedicationStock> _applyFilter(List<MedicationStock> all) {
    switch (_filter) {
      case _StockFilter.all:
        return all;
      case _StockFilter.low:
        return all
            .where(
              (s) =>
                  s.stockLevel == StockLevel.critical ||
                  s.stockLevel == StockLevel.low,
            )
            .toList();
      case _StockFilter.out:
        return all.where((s) => s.currentStock == 0).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final medicationsStockAsync = ref.watch(medicationsStockProvider);
    final stockStatsAsync = ref.watch(stockStatisticsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.stockOverview),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshStock,
            onPressed: () => ProviderRefreshUtils.refreshStockProviders(ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'stock_fab',
        onPressed: () => context.push(AppConstants.routeShoppingList),
        icon: const Icon(Icons.shopping_cart_outlined),
        label: Text(l10n.shoppingList),
        elevation: 3,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ProviderRefreshUtils.refreshStockProviders(ref);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            // Stats summary
            stockStatsAsync.when(
              data: (stats) => AnimatedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.stockSummary,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StockStatItem(
                          label: l10n.total,
                          value: stats['total']!,
                          color: cs.primary,
                          index: 0,
                        ),
                        StockStatItem(
                          label: l10n.critical,
                          value: stats['critical']!,
                          color: cs.error,
                          index: 1,
                        ),
                        StockStatItem(
                          label: l10n.low,
                          value: stats['low']!,
                          color: cs.tertiary,
                          index: 2,
                        ),
                        StockStatItem(
                          label: l10n.good,
                          value: stats['good']!,
                          color: cs.secondary,
                          index: 3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.medications,
                      icon: Icons.list,
                      selected: _filter == _StockFilter.all,
                      onTap: () => setState(() => _filter = _StockFilter.all),
                      colorScheme: cs,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l10n.low,
                      icon: Icons.warning_outlined,
                      selected: _filter == _StockFilter.low,
                      onTap: () => setState(() => _filter = _StockFilter.low),
                      colorScheme: cs,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l10n.outOfStock,
                      icon: Icons.remove_circle_outline,
                      selected: _filter == _StockFilter.out,
                      onTap: () => setState(() => _filter = _StockFilter.out),
                      colorScheme: cs,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Medications list
            medicationsStockAsync.when(
              data: (allStock) {
                final filtered = _applyFilter(allStock);
                if (filtered.isEmpty) {
                  return const StockEmptyState();
                }
                return Column(
                  children: filtered.map((stock) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StockCard(
                        medicationStock: stock,
                        onStockAdjusted: () =>
                            ProviderRefreshUtils.refreshStockProviders(ref),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: cs.error),
                      const SizedBox(height: 16),
                      Text('${l10n.errorLoadingStock}: $error'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
