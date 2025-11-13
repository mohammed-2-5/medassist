import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/core/widgets/animated_card.dart';
import 'package:med_assist/core/widgets/gradient_container.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';
import 'package:med_assist/features/stock/widgets/stock_card.dart';
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
                onTap: () {},
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
                        _buildStatItem(
                          context,
                          l10n.total,
                          stats['total']!,
                          colorScheme.primary,
                          0,
                        ),
                        _buildStatItem(
                          context,
                          l10n.critical,
                          stats['critical']!,
                          Colors.red,
                          1,
                        ),
                        _buildStatItem(
                          context,
                          l10n.low,
                          stats['low']!,
                          Colors.orange,
                          2,
                        ),
                        _buildStatItem(
                          context,
                          l10n.good,
                          stats['good']!,
                          Colors.green,
                          3,
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
              error: (_, __) => const SizedBox.shrink(),
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
                  return _buildEmptyState(theme, colorScheme, l10n);
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int value,
    Color color,
    int index,
  ) {
    final theme = Theme.of(context);
    final delay = index * 100;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          GradientContainer(
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(12),
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
            child: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: Duration(milliseconds: 800 + delay),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, child) {
                return Text(
                  animValue.toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noMedications,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addMedicationsToTrackStock,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
