import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/pharmacy.dart';
import '../../models/reservation.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';

class ReservationScreen extends ConsumerStatefulWidget {
  final Pharmacy pharmacy;
  final String medication;
  final double price;
  final String stockId;

  const ReservationScreen({
    super.key,
    required this.pharmacy,
    required this.medication,
    required this.stockId,
    this.price = 145.50,
  });

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String _quantity = '1';
  bool _showSuccessScreen = false;
  String? _reservationId;

  // Colors
  static const Color primaryColor = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF059669);  // Emerald 600

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? "";
    }

    final now = DateTime.now();
    _dateController.text = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _timeController.text = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _onPressValidate() {
    if (_formKey.currentState!.validate()) {
      _showConfirmationDialog();
    }
  }

  // ==========================================
  // ENHANCED CONFIRMATION DIALOG
  // ==========================================
  void _showConfirmationDialog() {
    final double total = widget.price * int.parse(_quantity);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.summary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _dialogRow(AppLocalizations.of(context)!.medication, widget.medication, isBold: true),
                  const SizedBox(height: 8),
                  _dialogRow(AppLocalizations.of(context)!.pharmacy, widget.pharmacy.name),
                  const SizedBox(height: 8),
                  _dialogRow(AppLocalizations.of(context)!.quantity, "x$_quantity"),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.totalToPay, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text("${total.toStringAsFixed(2)} DH", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryDark)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.confirmReservation,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _finalizeReservation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(AppLocalizations.of(context)!.confirm, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: Colors.black87)
          ),
        ),
      ],
    );
  }

  void _finalizeReservation() {
    final user = ref.read(authProvider);
    final userId = user?.id.toString() ?? 'guest';

    List<String> dateParts = _dateController.text.split('/');
    String formattedDate = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}"; 
    String pickupDateTime = "$formattedDate ${_timeController.text}:00"; 

    final newReservation = Reservation(
      id: '',
      userId: userId,
      patientName: _nameController.text, 
      patientPhone: _phoneController.text,
      pharmacyId: widget.pharmacy.id,
      pharmacyName: widget.pharmacy.name,
      pharmacyAddress: widget.pharmacy.address,
      pharmacyPhone: widget.pharmacy.phone,
      medicationName: widget.medication,
      stockId: widget.stockId,
      quantity: int.parse(_quantity),
      status: 'en_attente',
      createdAt: DateTime.now(),
    );

    Map<String, dynamic> data = newReservation.toJson();
    data['dateReservation'] = pickupDateTime; 

    ref.read(reservationProvider.notifier).makeReservation(data);
  }

  // ==========================================
  // ENHANCED PDF RECEIPT
  // ==========================================
  Future<void> _generatePdf() async {
    final localizations = AppLocalizations.of(context)!;
    final doc = pw.Document();
    final total = (widget.price * int.parse(_quantity)).toStringAsFixed(2);
    final nowStr = DateTime.now().toString().substring(0, 16);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(localizations.reservationReceipt, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    // CHANGED TO SmartPharma
                    pw.Text("SmartPharma", style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              
              // IDs
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                     pw.Text("ID: ${_reservationId ?? '---'}", style: const pw.TextStyle(fontSize: 12)),
                     pw.Text("Date: $nowStr", style: const pw.TextStyle(fontSize: 12)),
                  ]
                )
              ),
              pw.SizedBox(height: 20),

              // Info Boxes
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(localizations.pharmacyCaps, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text(widget.pharmacy.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.pharmacy.address),
                        pw.Text(widget.pharmacy.phone),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("PATIENT", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text(_nameController.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(_phoneController.text),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Table
              pw.Table.fromTextArray(
                context: context,
                border: const pw.TableBorder(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  horizontalInside: pw.BorderSide.none,
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                },
                headers: [localizations.designation, localizations.qty, localizations.unitPrice],
                data: [
                  [widget.medication, _quantity, "${widget.price} DH"],
                ],
              ),
              pw.SizedBox(height: 10),
              
              // Total
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text("${localizations.estimatedTotal}  ", style: const pw.TextStyle(fontSize: 14)),
                    pw.Text("$total DH", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ]
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: _reservationId ?? "ERROR", width: 100, height: 100),
                    pw.SizedBox(height: 10),
                    pw.Text("Merci de votre confiance.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                  ]
                )
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Reservation-${_reservationId ?? 'doc'}.pdf',
    );
  }

  // Date/Time pickers
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: primaryDark)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}");
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: primaryDark)),
        child: child!,
      ),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() => _timeController.text = "$hour:$minute");
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationState = ref.watch(reservationProvider);

    ref.listen(reservationProvider, (previous, next) {
      if (next.status == ReservationStatus.success && next.reservations.isNotEmpty) {
        if (_showSuccessScreen) return;
        final latestReservation = next.reservations.first;
        setState(() {
          _reservationId = latestReservation.qrCode.isNotEmpty
              ? latestReservation.qrCode
              : (latestReservation.id.isNotEmpty ? latestReservation.id : "RES-${DateTime.now().millisecondsSinceEpoch}");
          _showSuccessScreen = true;
        });
      } else if (next.status == ReservationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage ?? "Une erreur est survenue"), backgroundColor: Colors.red));
      }
    });

    if (_showSuccessScreen) {
      return _buildSuccessView();
    }

    return _buildFormView(reservationState.status == ReservationStatus.loading);
  }

  // ==========================================
  // ENHANCED SUCCESS VIEW (Ticket Style)
  // ==========================================
  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Success Header
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, color: primaryDark, size: 40),
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.reservationConfirmed, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.orderTransmitted, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
              const SizedBox(height: 32),

              // TICKET CARD
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    // Top Section (QR)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          if (_reservationId != null)
                            QrImageView(
                              data: _reservationId!,
                              version: QrVersions.auto,
                              size: 180.0,
                              backgroundColor: Colors.white,
                            ),
                          const SizedBox(height: 16),
                          Text("ID: $_reservationId", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                    ),
                    
                    // Dashed Line Simulation
                    Row(
                      children: List.generate(30, (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade300,
                          height: 2,
                        ),
                      )),
                    ),
                    
                    // Bottom Section (Info)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Médicament", style: TextStyle(color: Colors.grey)),
                              Text(widget.medication, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Pharmacie", style: TextStyle(color: Colors.grey)),
                              Text(widget.pharmacy.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _generatePdf,
                  icon: const Icon(LucideIcons.download, size: 18),
                  label: Text(AppLocalizations.of(context)!.downloadReceipt),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF374151),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(AppLocalizations.of(context)!.finish, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FORM VIEW
  // ==========================================
  Widget _buildFormView(bool isLoading) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [primaryColor, Color(0xFF0D9488)]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text("← ${AppLocalizations.of(context)!.goBack}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.reserve, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(LucideIcons.pill, color: primaryDark, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.medication, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
                                const SizedBox(height: 4),
                                Text("${widget.price.toStringAsFixed(2)} DH / unité", style: const TextStyle(color: primaryDark, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Inputs
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.informations, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                          const SizedBox(height: 20),
                          
                          _buildLabel(AppLocalizations.of(context)!.fullName),
                          _buildTextField(_nameController, "Votre nom et prénom"),
                          const SizedBox(height: 16),
                          
                          _buildLabel(AppLocalizations.of(context)!.phoneNumber),
                          _buildTextField(_phoneController, "06 XX XX XX XX", isPhone: true),
                          const SizedBox(height: 16),

                          _buildLabel(AppLocalizations.of(context)!.quantity),
                          // Enhanced Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _quantity,
                                icon: const Icon(LucideIcons.chevronDown, color: Colors.grey),
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(12),
                                items: ['1', '2', '3', '4', '5'].map((val) => DropdownMenuItem(
                                  value: val,
                                  child: Text("$val ${AppLocalizations.of(context)!.boxes}", style: const TextStyle(fontSize: 15)),
                                )).toList(),
                                onChanged: (val) => setState(() => _quantity = val!),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(AppLocalizations.of(context)!.date),
                                    TextFormField(
                                      controller: _dateController,
                                      readOnly: true,
                                      onTap: _selectDate,
                                      // REDUCED PADDING to fix 202... cutoff
                                      decoration: _inputDecoration(icon: LucideIcons.calendar, tight: true),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(AppLocalizations.of(context)!.time),
                                    TextFormField(
                                      controller: _timeController,
                                      readOnly: true,
                                      onTap: _selectTime,
                                      // REDUCED PADDING
                                      decoration: _inputDecoration(icon: LucideIcons.clock, tight: true),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Validate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onPressValidate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: primaryDark.withValues(alpha: 0.4),
                        ),
                        child: isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(AppLocalizations.of(context)!.confirmReservation, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
      decoration: _inputDecoration(hint: hint),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon, bool tight = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
      // FIX: Tighter padding for Date/Time to prevent cutoff on small screens
      contentPadding: tight 
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 14)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryDark, width: 2)),
    );
  }
}