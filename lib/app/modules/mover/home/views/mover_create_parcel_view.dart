import 'package:digaxy/app/routes/app_pages.dart';
import 'package:digaxy/models/parcel_data.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:digaxy/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/mover_create_parcel_controller.dart';

class MoverCreateParcelView extends StatefulWidget {
  const MoverCreateParcelView({super.key});

  @override
  State<MoverCreateParcelView> createState() => _MoverCreateParcelViewState();
}

class _MoverCreateParcelViewState extends State<MoverCreateParcelView> {
  final controller = Get.find<MoverCreateParcelController>();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Vehicle step
  String? _selectedVehicleType;
  final _vehicleTypes = ['Small', 'Medium', 'Large', 'Extra Large'];

  // Date & Time step
  final _pickupDateController = TextEditingController();
  final _pickupTimeController = TextEditingController();

  // Pickup contact step
  final _pickupNameController = TextEditingController();
  final _pickupPhoneController = TextEditingController();
  final _pickupAddressController = TextEditingController();

  // Dropoff contact step
  final _dropNameController = TextEditingController();
  final _dropPhoneController = TextEditingController();
  final _dropAddressController = TextEditingController();

  // Additional info step
  final _notesController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  @override
  void dispose() {
    _pickupDateController.dispose();
    _pickupTimeController.dispose();
    _pickupNameController.dispose();
    _pickupPhoneController.dispose();
    _pickupAddressController.dispose();
    _dropNameController.dispose();
    _dropPhoneController.dispose();
    _dropAddressController.dispose();
    _notesController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedVehicleType == null) {
          Get.snackbar(
            'Error',
            'Please select a vehicle type',
            backgroundColor: AppColors.accent,
            colorText: Colors.white,
          );
          return false;
        }
        return true;
      case 1:
        if (_pickupDateController.text.isEmpty ||
            _pickupTimeController.text.isEmpty) {
          Get.snackbar(
            'Error',
            'Please select pickup date and time',
            backgroundColor: AppColors.accent,
            colorText: Colors.white,
          );
          return false;
        }
        return true;
      case 2:
        if (_pickupNameController.text.isEmpty ||
            _pickupPhoneController.text.isEmpty ||
            _pickupAddressController.text.isEmpty) {
          Get.snackbar(
            'Error',
            'Please fill all pickup details',
            backgroundColor: AppColors.accent,
            colorText: Colors.white,
          );
          return false;
        }
        return true;
      case 3:
        if (_dropNameController.text.isEmpty ||
            _dropPhoneController.text.isEmpty ||
            _dropAddressController.text.isEmpty) {
          Get.snackbar(
            'Error',
            'Please fill all dropoff details',
            backgroundColor: AppColors.accent,
            colorText: Colors.white,
          );
          return false;
        }
        return true;
      case 4:
        return true;
      default:
        return false;
    }
  }

  Future<void> _submitParcel() async {
    if (!_validateStep()) return;

    setState(() => _isSubmitting = true);

    try {
      // Collect all locally stored data and prepare for API submission
      final parcelData = ParcelData(
        vehicleType: _selectedVehicleType!,
        pickupDate: _pickupDateController.text,
        pickupTime: _pickupTimeController.text,
        pickupUserName: _pickupNameController.text,
        pickupPhoneNumber: _pickupPhoneController.text,
        pickupAddress: _pickupAddressController.text,
        dropUserName: _dropNameController.text,
        dropPhoneNumber: _dropPhoneController.text,
        dropAddress: _dropAddressController.text,
        price: '100', // Default price
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        specialInstructions: _specialInstructionsController.text.isEmpty
            ? null
            : _specialInstructionsController.text,
      );

      await controller.createParcel(parcelData: parcelData);

      Get.snackbar(
        'Success',
        'Parcel created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to booking confirmation or back to home
      Get.offAllNamed(Routes.MOVER_HOME);
    } catch (e) {
      debugPrint('Error creating parcel: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Parcel Request'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_validateStep()) {
                  if (_currentStep < 4) {
                    // Move to next step - data stored locally
                    setState(() => _currentStep += 1);
                  } else {
                    // Final step - submit all collected data to API
                    _submitParcel();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                } else {
                  Get.back();
                }
              },
              steps: [
                // Step 0: Vehicle Type (stored locally)
                Step(
                  title: const Text('Step 1: Vehicle Type'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select vehicle type for your parcel',
                        style: TextStyle(
                          color: AppColors.textHeadline,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ..._vehicleTypes.map(
                        (type) => RadioListTile<String>(
                          title: Text(type),
                          value: type,
                          groupValue: _selectedVehicleType,
                          onChanged: (value) {
                            setState(() => _selectedVehicleType = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep >= 0
                      ? StepState.complete
                      : StepState.disabled,
                ),
                // Step 1: Date & Time (stored locally)
                Step(
                  title: const Text('Step 2: Pickup Schedule'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _pickupDateController,
                        readOnly: true,
                        onTap: () => _selectDate(_pickupDateController),
                        decoration: InputDecoration(
                          hintText: 'Select pickup date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: _pickupTimeController,
                        readOnly: true,
                        onTap: () => _selectTime(_pickupTimeController),
                        decoration: InputDecoration(
                          hintText: 'Select pickup time',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.editing,
                ),
                // Step 2: Pickup Contact (stored locally)
                Step(
                  title: const Text('Step 3: Sender Details'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryTextField(
                        controller: _pickupNameController,
                        hint: 'Sender name',
                        prefixIcon: const Icon(Icons.person),
                      ),
                      SizedBox(height: 12.h),
                      PrimaryTextField(
                        controller: _pickupPhoneController,
                        hint: 'Phone number',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _pickupAddressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Pickup address',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.editing,
                ),
                // Step 3: Dropoff Contact (stored locally)
                Step(
                  title: const Text('Step 4: Receiver Details'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryTextField(
                        controller: _dropNameController,
                        hint: 'Receiver name',
                        prefixIcon: const Icon(Icons.person),
                      ),
                      SizedBox(height: 12.h),
                      PrimaryTextField(
                        controller: _dropPhoneController,
                        hint: 'Phone number',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _dropAddressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Dropoff address',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 3,
                  state: _currentStep > 3
                      ? StepState.complete
                      : StepState.editing,
                ),
                // Step 4: Additional Info & Submit (data sent to API)
                Step(
                  title: const Text('Step 5: Review & Submit'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '100 PKR',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Additional Information (Optional)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Notes (optional)',
                          prefixIcon: const Icon(Icons.notes),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _specialInstructionsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Special instructions (optional)',
                          prefixIcon: const Icon(Icons.info),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 4,
                  state: StepState.editing,
                ),
              ],
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
