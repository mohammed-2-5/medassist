import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/drug_database/open_fda_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Barcode scanner screen for scanning medication barcodes
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final OpenFdaService _fdaService = OpenFdaService();
  bool _isProcessing = false;
  bool _isFlashOn = false;
  String? _scannedCode;
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.scanBarcode ?? 'Scan Barcode'),
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: _isFlashOn ? 'Turn off flash' : 'Turn on flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // Scanning overlay
          _buildScanningOverlay(colorScheme),

          // Instructions
          _buildInstructions(theme, l10n),

          // Processing indicator
          if (_isProcessing) _buildProcessingIndicator(colorScheme),

          // Scanned code display
          if (_scannedCode != null && !_isProcessing)
            _buildScannedCodeDisplay(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay(ColorScheme colorScheme) {
    return CustomPaint(
      painter: ScannerOverlayPainter(
        scanAnimation: _scanAnimation,
        primaryColor: colorScheme.primary,
      ),
      child: Container(),
    );
  }

  Widget _buildInstructions(ThemeData theme, AppLocalizations l10n) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          l10n.scanBarcodeInstructions ??
              'Position the barcode within the frame\nIt will scan automatically',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator(ColorScheme colorScheme) {
    return ColoredBox(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Looking up medication...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedCodeDisplay(ThemeData theme, ColorScheme colorScheme) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scanned Code',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _scannedCode!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _controller.toggleTorch();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _scannedCode = code;
    });

    try {
      // Stop camera while processing
      await _controller.stop();

      // Look up drug information
      final drugInfo = await _fdaService.searchByBarcode(code);

      if (!mounted) return;

      if (drugInfo != null && drugInfo.isValid) {
        // Return drug info to previous screen
        Navigator.pop(context, drugInfo);
      } else {
        // No drug found, let user enter manually with the scanned code
        _showManualEntryDialog(code);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showManualEntryDialog(String code) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.medicationNotFound ?? 'Medication Not Found'),
        content: Text(
          l10n.medicationNotFoundMessage ??
              'Could not find medication information for barcode: $code\n\n'
                  'Would you like to enter the medication details manually?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              Navigator.pop(this.context); // Go back to form
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
              // Return code for manual entry
              Navigator.pop(this.context, code);
            },
            child: Text(l10n.enterManually ?? 'Enter Manually'),
          ),
        ],
      ),
    ).then((enterManually) {
      if (enterManually != true && mounted) {
        // Resume scanning
        _controller.start();
        setState(() {
          _scannedCode = null;
        });
      }
    });
  }

  void _showErrorDialog(String error) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.error ?? 'Error'),
        content: Text(
          l10n.errorScanningBarcode ??
              'An error occurred while scanning the barcode:\n\n$error',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(this.context);
            },
            child: Text(l10n.close ?? 'Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Resume scanning
              _controller.start();
              setState(() {
                _scannedCode = null;
              });
            },
            child: Text(l10n.tryAgain ?? 'Try Again'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the scanning overlay with animated scan line
class ScannerOverlayPainter extends CustomPainter {

  ScannerOverlayPainter({
    required this.scanAnimation,
    required this.primaryColor,
  }) : super(repaint: scanAnimation);
  final Animation<double> scanAnimation;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final right = left + scanAreaSize;
    final bottom = top + scanAreaSize;

    // Draw dark overlay outside scan area
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);

    canvas
      ..drawRect(Rect.fromLTWH(0, 0, size.width, top), overlayPaint)
      ..drawRect(Rect.fromLTWH(0, top, left, scanAreaSize), overlayPaint)
      ..drawRect(
        Rect.fromLTWH(right, top, size.width - right, scanAreaSize),
        overlayPaint,
      )
      ..drawRect(
        Rect.fromLTWH(0, bottom, size.width, size.height - bottom),
        overlayPaint,
      );

    // Draw scan area corners
    final cornerPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const double cornerLength = 30;

    // Top-left corner
    canvas
      ..drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint)
      ..drawLine(Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Top-right corner
    canvas
      ..drawLine(Offset(right - cornerLength, top), Offset(right, top), cornerPaint)
      ..drawLine(Offset(right, top), Offset(right, top + cornerLength), cornerPaint);

    // Bottom-left corner
    canvas
      ..drawLine(Offset(left, bottom - cornerLength), Offset(left, bottom), cornerPaint)
      ..drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), cornerPaint);

    // Bottom-right corner
    canvas
      ..drawLine(Offset(right - cornerLength, bottom), Offset(right, bottom), cornerPaint)
      ..drawLine(Offset(right, bottom - cornerLength), Offset(right, bottom), cornerPaint);

    // Draw animated scan line
    final scanLinePaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..strokeWidth = 3;

    final scanY = top + (scanAreaSize * scanAnimation.value);

    canvas.drawLine(
      Offset(left + 20, scanY),
      Offset(right - 20, scanY),
      scanLinePaint,
    );

    // Draw scan line glow
    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(
      Offset(left + 20, scanY),
      Offset(right - 20, scanY),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) =>
      scanAnimation != oldDelegate.scanAnimation;
}
