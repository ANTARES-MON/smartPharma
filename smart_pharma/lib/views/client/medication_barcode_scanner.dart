import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../l10n/app_localizations.dart';

class MedicationBarcodeScanner extends StatefulWidget {
  const MedicationBarcodeScanner({super.key});

  @override
  State<MedicationBarcodeScanner> createState() => _MedicationBarcodeScannerState();
}

class _MedicationBarcodeScannerState extends State<MedicationBarcodeScanner> {
  bool _isScanned = false;
  MobileScannerController cameraController = MobileScannerController();

  // GREEN DESIGN SYSTEM (matching medication search screen)
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ==========================================
          // 1. THE CAMERA SCANNER
          // ==========================================
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => _isScanned = true);
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
          
          // ==========================================
          // 2. THE SCANNING OVERLAY (CENTER FRAME)
          // ==========================================
          const ScannerOverlay(borderColor: emerald500),
          
          // ==========================================
          // 3. THE ROUNDED GREEN HEADER
          // ==========================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [emerald500, emerald600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  
                  // Title
                  Text(
                    AppLocalizations.of(context)!.scanBarcode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // ==========================================
          // 4. THE STYLED BOTTOM INSTRUCTION
          // ==========================================
          Positioned(
            bottom: 60,
            left: 40, 
            right: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: emerald500.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: emerald500.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2
                  )
                ]
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.scan, color: emerald500, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.placeBarcode,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.w600,
                        fontSize: 14
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// REUSABLE SCANNER OVERLAY
class ScannerOverlay extends StatelessWidget {
  final Color borderColor;
  const ScannerOverlay({super.key, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The darkened area outside the frame
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        // The highlighted scanning border
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 260,
            width: 260,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 4),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2
                )
              ]
            ),
          ),
        ),
      ],
    );
  }
}
