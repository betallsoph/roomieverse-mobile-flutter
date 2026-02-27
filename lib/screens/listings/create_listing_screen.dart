import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../theme/neo_brutal.dart';
import '../../widgets/step_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../data/constants.dart';
import 'create_steps/step_basic_info.dart';
import 'create_steps/step_details.dart';
import 'create_steps/step_preferences.dart';
import 'create_steps/step_contact.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const CreateListingScreen({super.key, this.initialCategory});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  bool _isSubmitting = false;
  late String _category;

  // Step 1 - Basic Info
  String? _roommateType;
  final _titleController = TextEditingController();
  final _introController = TextEditingController();
  final _addressController = TextEditingController();
  final _buildingController = TextEditingController();
  final _priceController = TextEditingController();
  final _moveInController = TextEditingController();
  String? _selectedCity;
  String? _selectedDistrict;
  List<String> _selectedPropertyTypes = [];
  bool _locationNegotiable = false;
  bool _timeNegotiable = false;

  // Step 2 - Details
  List<String> _imagePaths = [];
  final _roomSizeController = TextEditingController();
  final _occupantsController = TextEditingController();
  final _contractController = TextEditingController();
  final _othersIntroController = TextEditingController();
  final _amenitiesOtherController = TextEditingController();
  List<String> _selectedAmenities = [];
  late Map<String, TextEditingController> _costControllers;

  // Step 3 - Preferences
  List<String> _prefGender = [];
  List<String> _prefStatus = [];
  List<String> _prefSchedule = [];
  int _cleanlinessLevel = 2;
  List<String> _prefHabits = [];
  List<String> _prefPets = [];
  List<String> _prefMoveInTime = [];
  final _prefOtherController = TextEditingController();

  // Step 4 - Contact
  final _phoneController = TextEditingController();
  final _zaloController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  bool _sameAsPhone = false;

  int get _totalSteps {
    // find-partner skips step 2 (details)
    if (_category == 'roommate' && _roommateType == 'find-partner') return 3;
    return 4;
  }

  Color get _accentColor {
    switch (_category) {
      case 'roomshare':
        return AppColors.pink;
      case 'short-term':
        return AppColors.emerald;
      case 'sublease':
        return AppColors.orange;
      case 'roommate':
      default:
        return AppColors.blue;
    }
  }

  Color get _accentColorDark {
    final hsl = HSLColor.fromColor(_accentColor);
    return hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();
  }

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? 'roommate';
    _pageController = PageController();
    _costControllers = {
      for (final field in costFields) field.$1: TextEditingController(),
    };
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _introController.dispose();
    _addressController.dispose();
    _buildingController.dispose();
    _priceController.dispose();
    _moveInController.dispose();
    _roomSizeController.dispose();
    _occupantsController.dispose();
    _contractController.dispose();
    _othersIntroController.dispose();
    _amenitiesOtherController.dispose();
    _prefOtherController.dispose();
    _phoneController.dispose();
    _zaloController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    for (final c in _costControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validateCurrentStep() {
    final skipDetails = _category == 'roommate' && _roommateType == 'find-partner';
    final actualStep = _currentStep;

    // Map step index to logical step based on whether details is skipped
    // With details: 0=Basic, 1=Details, 2=Preferences, 3=Contact
    // Without details: 0=Basic, 1=Preferences, 2=Contact
    if (actualStep == 0) {
      return _validateBasicInfo();
    } else if (!skipDetails && actualStep == 1) {
      return _validateDetails();
    } else if ((!skipDetails && actualStep == 2) || (skipDetails && actualStep == 1)) {
      return _validatePreferences();
    } else {
      return _validateContact();
    }
  }

  bool _validateBasicInfo() {
    if (_category == 'roommate' && _roommateType == null) {
      _showError('Vui lòng chọn loại tin');
      return false;
    }
    if (_titleController.text.trim().isEmpty) {
      _showError('Vui lòng nhập tiêu đề');
      return false;
    }
    if (_introController.text.trim().isEmpty) {
      _showError('Vui lòng nhập giới thiệu');
      return false;
    }
    if (_selectedCity == null || _selectedDistrict == null) {
      _showError('Vui lòng điền đầy đủ địa chỉ');
      return false;
    }
    if (_selectedPropertyTypes.isEmpty) {
      _showError('Vui lòng chọn loại hình nhà ở');
      return false;
    }
    if (_priceController.text.trim().isEmpty) {
      _showError('Vui lòng nhập giá');
      return false;
    }
    final isHaveRoom = _category == 'roommate' && _roommateType == 'have-room';
    if (!isHaveRoom && _moveInController.text.trim().isEmpty && !_timeNegotiable) {
      _showError('Vui lòng nhập thời gian dọn vào hoặc chọn "Linh hoạt"');
      return false;
    }
    if (_category == 'roomshare') {
      if (_roomSizeController.text.trim().isEmpty) {
        _showError('Vui lòng nhập diện tích phòng');
        return false;
      }
      if (_occupantsController.text.trim().isEmpty) {
        _showError('Vui lòng nhập số người hiện tại');
        return false;
      }
    }
    return true;
  }

  bool _validateDetails() {
    if (_imagePaths.isEmpty) {
      _showError('Vui lòng tải lên ít nhất 1 hình ảnh');
      return false;
    }
    if (_selectedAmenities.isEmpty) {
      _showError('Vui lòng chọn ít nhất 1 tiện ích');
      return false;
    }
    return true;
  }

  bool _validatePreferences() {
    if (_prefGender.isEmpty) {
      _showError('Vui lòng chọn giới tính mong muốn');
      return false;
    }
    if (_prefStatus.isEmpty) {
      _showError('Vui lòng chọn tình trạng mong muốn');
      return false;
    }
    if (_prefSchedule.isEmpty) {
      _showError('Vui lòng chọn giờ giấc');
      return false;
    }
    if (_prefHabits.isEmpty) {
      _showError('Vui lòng chọn thói quen');
      return false;
    }
    if (_prefPets.isEmpty) {
      _showError('Vui lòng chọn về thú cưng');
      return false;
    }
    if (_prefMoveInTime.isEmpty) {
      _showError('Vui lòng chọn thời gian dọn vào');
      return false;
    }
    return true;
  }

  bool _validateContact() {
    if (_phoneController.text.trim().isEmpty) {
      _showError('Vui lòng nhập số điện thoại');
      return false;
    }
    final phone = _phoneController.text.trim();
    if (phone.length < 9 || phone.length > 11) {
      _showError('Số điện thoại không hợp lệ');
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateAllSteps() {
    if (!_validateBasicInfo()) return false;
    final skipDetails = _category == 'roommate' && _roommateType == 'find-partner';
    if (!skipDetails && !_validateDetails()) return false;
    if (!_validatePreferences()) return false;
    if (!_validateContact()) return false;
    return true;
  }

  Future<void> _submit() async {
    if (!_validateAllSteps()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) return;

      final location = [
        getDistrictLabel(_selectedCity, _selectedDistrict),
        getCityLabel(_selectedCity),
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      final costs = <String, String>{};
      for (final entry in _costControllers.entries) {
        if (entry.value.text.trim().isNotEmpty) {
          costs[entry.key] = entry.value.text.trim();
        }
      }

      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'author': user.displayName ?? '',
        'authorName': user.displayName ?? '',
        'userId': user.uid,
        'category': _category,
        'price': _priceController.text.trim(),
        'location': location,
        'city': _selectedCity,
        'district': _selectedDistrict,
        'description': _introController.text.trim(),
        'introduction': _introController.text.trim(),
        'phone': _phoneController.text.trim(),
        'postedDate': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        'moveInDate': _moveInController.text.trim(),
        if (_roommateType != null) 'roommateType': _roommateType,
        if (_addressController.text.trim().isNotEmpty) 'specificAddress': _addressController.text.trim(),
        if (_buildingController.text.trim().isNotEmpty) 'buildingName': _buildingController.text.trim(),
        if (_selectedPropertyTypes.isNotEmpty) 'propertyTypes': _selectedPropertyTypes,
        'locationNegotiable': _locationNegotiable,
        'timeNegotiable': _timeNegotiable,
        if (_zaloController.text.trim().isNotEmpty) 'zalo': _zaloController.text.trim(),
        if (_sameAsPhone) 'zalo': _phoneController.text.trim(),
        if (_facebookController.text.trim().isNotEmpty) 'facebook': _facebookController.text.trim(),
        if (_instagramController.text.trim().isNotEmpty) 'instagram': _instagramController.text.trim(),
        // Details (step 2)
        if (_selectedAmenities.isNotEmpty) 'amenities': _selectedAmenities,
        if (_amenitiesOtherController.text.trim().isNotEmpty) 'amenitiesOther': _amenitiesOtherController.text.trim(),
        if (_roomSizeController.text.trim().isNotEmpty) 'roomSize': _roomSizeController.text.trim(),
        if (_occupantsController.text.trim().isNotEmpty) 'currentOccupants': _occupantsController.text.trim(),
        if (_contractController.text.trim().isNotEmpty) 'minContractDuration': _contractController.text.trim(),
        if (_othersIntroController.text.trim().isNotEmpty) 'othersIntro': _othersIntroController.text.trim(),
        if (costs.isNotEmpty) 'costs': costs,
        // Preferences (step 3)
        'preferences': {
          if (_prefGender.isNotEmpty) 'gender': _prefGender,
          if (_prefStatus.isNotEmpty) 'status': _prefStatus,
          if (_prefSchedule.isNotEmpty) 'schedule': _prefSchedule,
          'cleanliness': [cleanlinessValues[_cleanlinessLevel]],
          if (_prefHabits.isNotEmpty) 'habits': _prefHabits,
          if (_prefPets.isNotEmpty) 'pets': _prefPets,
          if (_prefMoveInTime.isNotEmpty) 'moveInTime': _prefMoveInTime,
          if (_prefOtherController.text.trim().isNotEmpty) 'other': _prefOtherController.text.trim(),
        },
        // Contact as sub-object too
        'contact': {
          'phone': _phoneController.text.trim(),
          if (_zaloController.text.trim().isNotEmpty) 'zalo': _zaloController.text.trim(),
          if (_sameAsPhone) 'zalo': _phoneController.text.trim(),
          if (_facebookController.text.trim().isNotEmpty) 'facebook': _facebookController.text.trim(),
          if (_instagramController.text.trim().isNotEmpty) 'instagram': _instagramController.text.trim(),
        },
      };

      await ref.read(listingServiceProvider).createListing(data);
      ref.invalidate(listingsProvider);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showError('Có lỗi xảy ra: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(LucideIcons.check, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đăng tin thành công!',
                style: TextStyle(fontFamily: 'Google Sans', fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tin đăng sẽ được duyệt trước khi hiển thị.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              NeoBrutalButton(
                label: 'Về trang chủ',
                backgroundColor: AppColors.blue,
                expanded: true,
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButtons(bool isLast) {
    final bottom = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottom > 0 ? 8 : 0),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: NeoBrutalButton(
                label: 'Quay lại',
                backgroundColor: Colors.white,
                onPressed: _prevStep,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: NeoBrutalButton(
              label: isLast ? 'Đăng tin' : 'Tiếp tục',
              backgroundColor: isLast ? _accentColorDark : _accentColor,
              expanded: true,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : (isLast ? _submit : _nextStep),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStepPages() {
    final skipDetails = _category == 'roommate' && _roommateType == 'find-partner';
    final totalSteps = _totalSteps;

    Widget navFor(int stepIndex) => _buildNavButtons(stepIndex == totalSteps - 1);

    final pages = <Widget>[
      StepBasicInfo(
        category: _category,
        roommateType: _roommateType,
        onRoommateTypeChanged: (v) => setState(() => _roommateType = v),
        titleController: _titleController,
        introController: _introController,
        addressController: _addressController,
        buildingController: _buildingController,
        priceController: _priceController,
        moveInController: _moveInController,
        selectedCity: _selectedCity,
        selectedDistrict: _selectedDistrict,
        onCityChanged: (v) => setState(() => _selectedCity = v),
        onDistrictChanged: (v) => setState(() => _selectedDistrict = v),
        selectedPropertyTypes: _selectedPropertyTypes,
        onPropertyTypesChanged: (v) => setState(() => _selectedPropertyTypes = v),
        locationNegotiable: _locationNegotiable,
        onLocationNegotiableChanged: (v) => setState(() => _locationNegotiable = v),
        timeNegotiable: _timeNegotiable,
        onTimeNegotiableChanged: (v) => setState(() => _timeNegotiable = v),
        bottomActions: navFor(0),
      ),
    ];

    if (!skipDetails) {
      pages.add(StepDetails(
        imagePaths: _imagePaths,
        onAddImages: _pickImages,
        onRemoveImage: (i) => setState(() => _imagePaths.removeAt(i)),
        roomSizeController: _roomSizeController,
        occupantsController: _occupantsController,
        contractController: _contractController,
        othersIntroController: _othersIntroController,
        amenitiesOtherController: _amenitiesOtherController,
        selectedAmenities: _selectedAmenities,
        onAmenitiesChanged: (v) => setState(() => _selectedAmenities = v),
        costControllers: _costControllers,
        bottomActions: navFor(1),
      ));
    }

    final prefStep = skipDetails ? 1 : 2;
    pages.add(StepPreferences(
      selectedGender: _prefGender,
      onGenderChanged: (v) => setState(() => _prefGender = v),
      selectedStatus: _prefStatus,
      onStatusChanged: (v) => setState(() => _prefStatus = v),
      selectedSchedule: _prefSchedule,
      onScheduleChanged: (v) => setState(() => _prefSchedule = v),
      cleanlinessLevel: _cleanlinessLevel,
      onCleanlinessChanged: (v) => setState(() => _cleanlinessLevel = v),
      selectedHabits: _prefHabits,
      onHabitsChanged: (v) => setState(() => _prefHabits = v),
      selectedPets: _prefPets,
      onPetsChanged: (v) => setState(() => _prefPets = v),
      selectedMoveInTime: _prefMoveInTime,
      onMoveInTimeChanged: (v) => setState(() => _prefMoveInTime = v),
      otherController: _prefOtherController,
      bottomActions: navFor(prefStep),
    ));

    final contactStep = skipDetails ? 2 : 3;
    pages.add(StepContact(
      phoneController: _phoneController,
      zaloController: _zaloController,
      facebookController: _facebookController,
      instagramController: _instagramController,
      sameAsPhone: _sameAsPhone,
      onSameAsPhoneChanged: (v) => setState(() {
        _sameAsPhone = v;
        if (v) _zaloController.text = _phoneController.text;
      }),
      bottomActions: navFor(contactStep),
    ));

    return pages;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (images.isNotEmpty) {
      setState(() {
        final remaining = 5 - _imagePaths.length;
        _imagePaths.addAll(
          images.take(remaining).map((f) => f.path),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepLabels = _category == 'roommate' && _roommateType == 'find-partner'
        ? ['Cơ bản', 'Yêu cầu', 'Liên hệ']
        : ['Cơ bản', 'Chi tiết', 'Yêu cầu', 'Liên hệ'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Đăng tin'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: StepIndicator(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              labels: stepLabels,
              activeColor: _accentColor,
              activeColorDark: _accentColorDark,
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _buildStepPages(),
      ),
    );
  }
}
