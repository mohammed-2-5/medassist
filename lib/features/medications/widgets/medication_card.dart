import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/medications/widgets/medication_card_footer.dart';
import 'package:med_assist/features/medications/widgets/medication_card_header.dart';
import 'package:med_assist/features/medications/widgets/medication_card_icon.dart';
import 'package:med_assist/features/medications/widgets/medication_card_info.dart';
import 'package:med_assist/features/medications/widgets/medication_card_swipe_background.dart';

/// Beautiful medication card with modern medical design
class MedicationCard extends StatelessWidget {
  const MedicationCard({
    required this.medication,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    super.key,
  });
  final Medication medication;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key('med_${medication.id}'),
      background: MedicationCardSwipeBackground(
        colorScheme: colorScheme,
        isEdit: true,
      ),
      secondaryBackground: MedicationCardSwipeBackground(
        colorScheme: colorScheme,
        isEdit: false,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete();
          return false; // Don't dismiss, let the dialog handle it
        } else {
          onEdit();
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: medication.isActive
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.outline.withOpacity(0.5),
                  width: 2,
                ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: medication.isActive
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer.withOpacity(0.1),
                        colorScheme.surface,
                        colorScheme.secondaryContainer.withOpacity(0.05),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    )
                  : LinearGradient(
                      colors: [
                        colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        colorScheme.surface,
                      ],
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    MedicationCardIcon(
                      medication: medication,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 12),
                    MedicationCardHeader(
                      medication: medication,
                      theme: theme,
                      colorScheme: colorScheme,
                    ),
                    MedicationStatusChip(
                      isActive: medication.isActive,
                      theme: theme,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                MedicationCardInfo(
                  medication: medication,
                  theme: theme,
                  colorScheme: colorScheme,
                ),

                const SizedBox(height: 12),

                MedicationCardFooter(
                  isActive: medication.isActive,
                  onEdit: onEdit,
                  onToggleActive: onToggleActive,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
