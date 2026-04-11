import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/core/widgets/animated_card.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';
import 'package:med_assist/features/stock/widgets/stock_card.dart';
import 'package:med_assist/features/stock/widgets/stock_empty_state.dart';
import 'package:med_assist/features/stock/widgets/stock_stat_item.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Stock Overview Screen - Shows all medications with stock levels
class StockOverviewScreen extends ConsumerWidget {
  const StockOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final medicationsStockAsync = ref.watch(medicationsStockProvider);
    final stockStatsAsync = ref.watch(stockStatisticsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.stockOverview),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshStock,
            onPressed: () {
              ProviderRefreshUtils.refreshStockProviders(ref);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ProviderRefreshUtils.refreshStockProviders(ref);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stock Statistics Summary with modern design
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
                          color: colorScheme.primary,
                          index: 0,
                        ),
                        StockStatItem(
                          label: l10n.critical,
                          value: stats['critical']!,
                          color: Colors.red,
                          index: 1,
                        ),
                        StockStatItem(
                          label: l10n.low,
                          value: stats['low']!,
                          color: Colors.orange,
                          index: 2,
                        ),
                        StockStatItem(
                          label: l10n.good,
                          value: stats['good']!,
                          color: Colors.green,
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

            // Medications List
            Text(
              l10n.medications,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            medicationsStockAsync.when(
              data: (stockList) {
                if (stockList.isEmpty) {
                  return const StockEmptyState();
                }

                return Column(
                  children: stockList.map((stock) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StockCard(
                        medicationStock: stock,
                        onStockAdjusted: () {
                          // Refresh stock data after adjustment
                          ProviderRefreshUtils.refreshStockProviders(ref);
                        },
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
                      Icon(Icons.error_outline, size: 48, color: colorScheme.error),
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
