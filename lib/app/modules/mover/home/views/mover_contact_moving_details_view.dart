import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MoverContactMovingDetailsView extends StatefulWidget {
  const MoverContactMovingDetailsView({super.key});

  @override
  State<MoverContactMovingDetailsView> createState() =>
      _MoverContactMovingDetailsViewState();
}

class _MoverContactMovingDetailsViewState
    extends State<MoverContactMovingDetailsView> {
  final _formKey = GlobalKey<FormState>();
  // Sender information
  final _senderNameCtrl = TextEditingController();
  final _senderPhoneCtrl = TextEditingController();
  // Receiver information
  final _receiverNameCtrl = TextEditingController();
  final _receiverPhoneCtrl = TextEditingController();
  // Moving details
  final _itemsCtrl = TextEditingController();
  String _loadSize = 'Medium';
  final _notesCtrl = TextEditingController();

  late final Map<String, dynamic> _draft;

  @override
  void initState() {
    super.initState();
    _draft = {...?Get.arguments as Map?};
  }

  @override
  void dispose() {
    _senderNameCtrl.dispose();
    _senderPhoneCtrl.dispose();
    _receiverNameCtrl.dispose();
    _receiverPhoneCtrl.dispose();
    _itemsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // For now just navigate back or to next step if implemented
      // Pass the collected details as arguments so next pages can use them
      final payload = {
        ..._draft,
        'senderName': _senderNameCtrl.text.trim(),
        'senderPhone': _senderPhoneCtrl.text.trim(),
        'receiverName': _receiverNameCtrl.text.trim(),
        'receiverPhone': _receiverPhoneCtrl.text.trim(),
        'items': _itemsCtrl.text.trim(),
        'loadSize': _loadSize,
        'notes': _notesCtrl.text.trim(),
      };

      // Store locally (in-memory draft) and log for debugging
      _draft
        ..clear()
        ..addAll(payload);
      debugPrint('Draft after contact details: $_draft');

      Get.toNamed(Routes.MOVER_PICKUP_LOCATION, arguments: payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Contact & Moving Details',
          style: TextStyle(color: AppColors.textHeadline),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 8.h),
              Text(
                'Sender information',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _senderNameCtrl,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Full name',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter sender name'
                    : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _senderPhoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter sender phone'
                    : null,
              ),

              SizedBox(height: 18.h),
              Text(
                'Receiver information',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _receiverNameCtrl,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Full name',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter receiver name'
                    : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _receiverPhoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter receiver phone'
                    : null,
              ),

              SizedBox(height: 18.h),
              Text(
                'Moving details',
                style: TextStyle(
                  color: AppColors.textHeadline,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _itemsCtrl,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type of items (e.g., furniture, boxes)',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Load size',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _loadSize,
                    dropdownColor: const Color(0xFF1E1E1E),
                    items: ['Small', 'Medium', 'Large']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _loadSize = v ?? _loadSize),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _notesCtrl,
                style: TextStyle(color: AppColors.textPrimary),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Special instructions (optional)',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              PrimaryButton(label: 'Continue', onPressed: _onContinue),
            ],
          ),
        ),
      ),
    );
  }
}
