import 'dart:io';
import 'package:digaxy/models/driver_signup_data.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../../../../services/api/api_service.dart';
import 'verify_email_view.dart';
import '../../../../shared/widgets/primary_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';

class DriverSignupView extends StatefulWidget {
  const DriverSignupView({super.key});

  @override
  State<DriverSignupView> createState() => _DriverSignupViewState();
}

class _DriverSignupViewState extends State<DriverSignupView> {
  late AuthController controller;
  final ImagePicker _imagePicker = ImagePicker();
  int _currentStep = 0;

  // Step 1: Basic Info
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      controller = Get.find<AuthController>();
    } catch (e) {
      debugPrint('Error initializing AuthController: $e');
    }
  }

  // Step 2: License Info
  final TextEditingController _licenseNumberController =
      TextEditingController();
  File? _licenseFrontImage;
  File? _licenseBackImage;

  // Step 3: Vehicle Info
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  String? _selectedVehicleType;
  File? _vehicleRegistrationImage;

  // Step 4: Identity Documents
  File? _nidFrontImage;
  File? _nidBackImage;
  File? _passportImage;

  final List<String> _vehicleTypes = ['Van', 'Pickup', 'Minibox', 'Bigbox'];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseNumberController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  // Get stored driver data
  DriverSignupData _getDriverData() {
    return DriverSignupData(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      driverLicenseNumber: _licenseNumberController.text.trim(),
      driverVehicleNumber: _vehicleNumberController.text.trim(),
      vehicleType: _selectedVehicleType,
      drivingLicenseFrontImage: _licenseFrontImage?.path,
      drivingLicenseBackImage: _licenseBackImage?.path,
      driverVehicleRegistrationImage: _vehicleRegistrationImage?.path,
      driverNidFrontImage: _nidFrontImage?.path,
      driverNidBackImage: _nidBackImage?.path,
      driverPassportImage: _passportImage?.path,
    );
  }

  Future<void> _pickImage(Function(File) onImagePicked) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          onImagePicked(File(pickedFile.path));
        });
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to pick image',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.accent,
        );
      }
    }
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (_usernameController.text.isEmpty) {
          Get.snackbar('Missing Info', 'Please enter username');
          return false;
        }
        if (_emailController.text.isEmpty) {
          Get.snackbar('Missing Info', 'Please enter email');
          return false;
        }
        if (_passwordController.text.isEmpty) {
          Get.snackbar('Missing Info', 'Please enter password');
          return false;
        }
        return true;
      case 1:
        if (_licenseNumberController.text.isEmpty) {
          Get.snackbar('Missing Info', 'Please enter license number');
          return false;
        }
        if (_licenseFrontImage == null) {
          Get.snackbar('Missing Info', 'Please upload license front image');
          return false;
        }
        if (_licenseBackImage == null) {
          Get.snackbar('Missing Info', 'Please upload license back image');
          return false;
        }
        return true;
      case 2:
        if (_vehicleNumberController.text.isEmpty) {
          Get.snackbar('Missing Info', 'Please enter vehicle number');
          return false;
        }
        if (_selectedVehicleType == null) {
          Get.snackbar('Missing Info', 'Please select vehicle type');
          return false;
        }
        if (_vehicleRegistrationImage == null) {
          Get.snackbar(
            'Missing Info',
            'Please upload vehicle registration image',
          );
          return false;
        }
        return true;
      case 3:
        if (_nidFrontImage == null) {
          Get.snackbar('Missing Info', 'Please upload NID front image');
          return false;
        }
        if (_nidBackImage == null) {
          Get.snackbar('Missing Info', 'Please upload NID back image');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _onSignup() async {
    if (!mounted) return;
    try {
      final driverData = DriverSignupData(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        driverLicenseNumber: _licenseNumberController.text.trim(),
        driverVehicleNumber: _vehicleNumberController.text.trim(),
        vehicleType: _selectedVehicleType,
        drivingLicenseFrontImage: _licenseFrontImage?.path,
        drivingLicenseBackImage: _licenseBackImage?.path,
        driverVehicleRegistrationImage: _vehicleRegistrationImage?.path,
        driverNidFrontImage: _nidFrontImage?.path,
        driverNidBackImage: _nidBackImage?.path,
        driverPassportImage: _passportImage?.path,
      );

      await controller.driverSignup(data: driverData);
      if (mounted) {
        Get.to(
          () => const VerifyEmailView(),
          arguments: {
            'email': driverData.email,
            'password': driverData.password,
          },
        );
      }
    } catch (e) {
      debugPrint('Driver signup error: $e');
      if (mounted) {
        final message = (e is ApiException)
            ? e.message
            : 'An error occurred during signup';
        Get.snackbar(
          'Sign up failed',
          message,
          backgroundColor: AppColors.accent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
        title: Text(
          'Driver Registration - Step ${_currentStep + 1}/5',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        height: 4.h,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.r),
                          color: index <= _currentStep
                              ? AppColors.accent
                              : Colors.grey.withAlpha(100),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(child: _buildStepContent()),
              ),
              // Navigation buttons
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _currentStep--),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.accent),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => PrimaryButton(
                          label: _currentStep == 4
                              ? 'Confirm & Sign Up'
                              : 'Next',
                          loading: controller.loading.value,
                          onPressed: controller.loading.value
                              ? null
                              : () {
                                  if (_validateStep(_currentStep)) {
                                    if (_currentStep == 4) {
                                      _onSignup();
                                    } else {
                                      setState(() => _currentStep++);
                                    }
                                  }
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildLicenseInfoStep();
      case 2:
        return _buildVehicleInfoStep();
      case 3:
        return _buildIdentityDocumentsStep();
      case 4:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            height: 180.h,
            child: SvgPicture.asset('assets/icons/auth_signup.svg'),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20.h),
        _buildLabel('Username'),
        SizedBox(height: 8.h),
        PrimaryTextField(
          controller: _usernameController,
          hint: 'Enter your username',
          keyboardType: TextInputType.text,
          prefixIcon: const Icon(Icons.person),
        ),
        SizedBox(height: 20.h),
        _buildLabel('Email'),
        SizedBox(height: 8.h),
        PrimaryTextField(
          controller: _emailController,
          hint: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email),
        ),
        SizedBox(height: 20.h),
        _buildLabel('Password'),
        SizedBox(height: 8.h),
        PrimaryTextField(
          controller: _passwordController,
          hint: 'Enter your password',
          obscure: true,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: const Icon(Icons.visibility_off),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildLicenseInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Driving License Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20.h),
        _buildLabel('License Number'),
        SizedBox(height: 8.h),
        PrimaryTextField(
          controller: _licenseNumberController,
          hint: 'Enter your license number',
          keyboardType: TextInputType.text,
          prefixIcon: const Icon(Icons.credit_card),
        ),
        SizedBox(height: 24.h),
        _buildLabel('License Front Image'),
        SizedBox(height: 12.h),
        _buildImageUploadButton(
          image: _licenseFrontImage,
          label: 'License Front',
          onTap: () => _pickImage((file) {
            setState(() => _licenseFrontImage = file);
          }),
        ),
        SizedBox(height: 24.h),
        _buildLabel('License Back Image'),
        SizedBox(height: 12.h),
        _buildImageUploadButton(
          image: _licenseBackImage,
          label: 'License Back',
          onTap: () => _pickImage((file) {
            setState(() => _licenseBackImage = file);
          }),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildVehicleInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20.h),
        _buildLabel('Vehicle Number'),
        SizedBox(height: 8.h),
        PrimaryTextField(
          controller: _vehicleNumberController,
          hint: 'Enter your vehicle number',
          keyboardType: TextInputType.text,
          prefixIcon: const Icon(Icons.directions_car),
        ),
        SizedBox(height: 20.h),
        _buildLabel('Vehicle Type'),
        SizedBox(height: 8.h),
        _buildVehicleTypeDropdown(),
        SizedBox(height: 24.h),
        _buildLabel('Vehicle Registration Image'),
        SizedBox(height: 12.h),
        _buildImageUploadButton(
          image: _vehicleRegistrationImage,
          label: 'Registration',
          onTap: () => _pickImage((file) {
            setState(() => _vehicleRegistrationImage = file);
          }),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildIdentityDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identity Documents',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20.h),
        _buildLabel('NID Front Image'),
        SizedBox(height: 12.h),
        _buildImageUploadButton(
          image: _nidFrontImage,
          label: 'NID Front',
          onTap: () => _pickImage((file) {
            setState(() => _nidFrontImage = file);
          }),
        ),
        SizedBox(height: 24.h),
        _buildLabel('NID Back Image'),
        SizedBox(height: 12.h),
        _buildImageUploadButton(
          image: _nidBackImage,
          label: 'NID Back',
          onTap: () => _pickImage((file) {
            setState(() => _nidBackImage = file);
          }),
        ),
        SizedBox(height: 24.h),
        _buildLabel('Passport Image (Optional)'),
        SizedBox(height: 12.h),
        _buildImageUploadButton(
          image: _passportImage,
          label: 'Passport',
          onTap: () => _pickImage((file) {
            setState(() => _passportImage = file);
          }),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
      ),
    );
  }

  Widget _buildImageUploadButton({
    required File? image,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: image != null
                ? AppColors.accent
                : Colors.grey.withAlpha(100),
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.accent,
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Upload $label',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withAlpha(100)),
      ),
      child: DropdownButton<String>(
        value: _selectedVehicleType,
        hint: Text(
          'Select vehicle type',
          style: TextStyle(color: Colors.grey[400]),
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: Colors.grey[800],
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
        items: _vehicleTypes.map((String type) {
          return DropdownMenuItem<String>(value: type, child: Text(type));
        }).toList(),
        onChanged: (String? value) {
          setState(() => _selectedVehicleType = value);
        },
      ),
    );
  }

  Widget _buildReviewStep() {
    final data = _getDriverData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20.h),
        _buildReviewSection('Basic Information', [
          _buildReviewItem('Username', data.username),
          _buildReviewItem('Email', data.email),
        ]),
        SizedBox(height: 16.h),
        _buildReviewSection('License Information', [
          _buildReviewItem('License Number', data.driverLicenseNumber),
          _buildReviewItem(
            'License Front',
            data.drivingLicenseFrontImage != null
                ? '✓ Uploaded'
                : '✗ Not uploaded',
          ),
          _buildReviewItem(
            'License Back',
            data.drivingLicenseBackImage != null
                ? '✓ Uploaded'
                : '✗ Not uploaded',
          ),
        ]),
        SizedBox(height: 16.h),
        _buildReviewSection('Vehicle Information', [
          _buildReviewItem('Vehicle Number', data.driverVehicleNumber),
          _buildReviewItem('Vehicle Type', data.vehicleType ?? 'Not selected'),
          _buildReviewItem(
            'Registration',
            data.driverVehicleRegistrationImage != null
                ? '✓ Uploaded'
                : '✗ Not uploaded',
          ),
        ]),
        SizedBox(height: 16.h),
        _buildReviewSection('Identity Documents', [
          _buildReviewItem(
            'NID Front',
            data.driverNidFrontImage != null ? '✓ Uploaded' : '✗ Not uploaded',
          ),
          _buildReviewItem(
            'NID Back',
            data.driverNidBackImage != null ? '✓ Uploaded' : '✗ Not uploaded',
          ),
          _buildReviewItem(
            'Passport',
            data.driverPassportImage != null ? '✓ Uploaded' : '(Optional)',
          ),
        ]),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<Widget> items) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: 12.h),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
