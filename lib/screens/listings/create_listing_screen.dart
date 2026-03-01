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
import '../../utils/helpers.dart';
import 'create_steps/roommate_have_room_basic.dart';
import 'create_steps/roommate_have_room_details.dart';
import 'create_steps/roommate_find_partner_basic.dart';
import 'create_steps/roomshare_basic.dart';
import 'create_steps/roomshare_images.dart';
import 'create_steps/roomshare_costs.dart';
import 'create_steps/shared_preferences_step.dart';
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

  // ── Roommate basic ──
  String? _roommateType;
  final _titleController = TextEditingController();
  final _introController = TextEditingController();
  final _addressController = TextEditingController();
  final _buildingController = TextEditingController();
  final _priceController = TextEditingController();
  final _moveInController = TextEditingController();
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedPropertyType;
  bool _locationNegotiable = false;
  bool _timeNegotiable = false;

  // ── Roommate have-room details ──
  final List<String> _imagePaths = [];
  final _roomSizeController = TextEditingController();
  final _occupantsController = TextEditingController();
  final _contractController = TextEditingController();
  final _amenitiesOtherController = TextEditingController();
  List<String> _selectedAmenities = [];

  // ── Roomshare extra ──
  final _othersIntroController = TextEditingController();
  final _totalRoomsController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _minLeaseController = TextEditingController();
  late Map<String, TextEditingController> _costControllers;

  // ── Preferences (single-select) ──
  String? _prefGender;
  String? _prefStatus;
  String? _prefSchedule;
  String? _prefCleanliness;
  String? _prefHabits;
  String? _prefPets;
  String? _prefMoveInTime;
  final _prefOtherController = TextEditingController();

  // ── Contact ──
  final _phoneController = TextEditingController();
  final _zaloController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  bool _sameAsPhone = false;

  int get _totalSteps {
    if (_category == 'roommate' && _roommateType == 'find-partner') return 3;
    if (_category == 'roomshare') return 5;
    return 4; // roommate have-room
  }

  List<String> get _stepLabels {
    if (_category == 'roommate' && _roommateType == 'find-partner') {
      return ['Cơ bản', 'Yêu cầu', 'Liên hệ'];
    }
    if (_category == 'roomshare') {
      return ['Phòng', 'Hình ảnh', 'Chi phí', 'Yêu cầu', 'Liên hệ'];
    }
    return ['Cơ bản', 'Chi tiết', 'Yêu cầu', 'Liên hệ'];
  }

  Color get _accentColor {
    switch (_category) {
      case 'roomshare':
        return AppColors.pink;
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
      for (final field in roomshareCostFields) field.$1: TextEditingController(),
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
    _amenitiesOtherController.dispose();
    _othersIntroController.dispose();
    _totalRoomsController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _minLeaseController.dispose();
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

  // ── Validation ──

  bool _validateCurrentStep() {
    final isFindPartner = _category == 'roommate' && _roommateType == 'find-partner';
    final isRoomshare = _category == 'roomshare';

    if (_currentStep == 0) return _validateBasic();

    if (isFindPartner) {
      // 0=Basic, 1=Preferences, 2=Contact
      if (_currentStep == 1) return _validatePreferences();
      return _validateContact();
    }

    if (isRoomshare) {
      // 0=Basic, 1=Images, 2=Costs, 3=Preferences, 4=Contact
      if (_currentStep == 1) return _validateImages();
      if (_currentStep == 2) return true; // costs are optional
      if (_currentStep == 3) return _validatePreferences();
      return _validateContact();
    }

    // roommate have-room: 0=Basic, 1=Details, 2=Preferences, 3=Contact
    if (_currentStep == 1) return _validateImages();
    if (_currentStep == 2) return _validatePreferences();
    return _validateContact();
  }

  bool _validateBasic() {
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
      _showError('Vui lòng chọn khu vực');
      return false;
    }
    if (_selectedPropertyType == null) {
      _showError('Vui lòng chọn loại hình nhà ở');
      return false;
    }

    final isFindPartner = _category == 'roommate' && _roommateType == 'find-partner';
    if (isFindPartner) {
      if (_priceController.text.trim().isEmpty) {
        _showError('Vui lòng nhập ngân sách');
        return false;
      }
      if (_moveInController.text.trim().isEmpty && !_timeNegotiable) {
        _showError('Vui lòng nhập thời gian hoặc chọn "Linh hoạt"');
        return false;
      }
    } else if (_category == 'roommate') {
      if (_priceController.text.trim().isEmpty) {
        _showError('Vui lòng nhập giá');
        return false;
      }
    } else if (_category == 'roomshare') {
      if (_rentController.text.trim().isEmpty) {
        _showError('Vui lòng nhập giá thuê');
        return false;
      }
      if (_roomSizeController.text.trim().isEmpty) {
        _showError('Vui lòng nhập diện tích');
        return false;
      }
      if (_occupantsController.text.trim().isEmpty) {
        _showError('Vui lòng nhập số người');
        return false;
      }
    }
    return true;
  }

  bool _validateImages() {
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
    if (_prefGender == null) {
      _showError('Vui lòng chọn giới tính mong muốn');
      return false;
    }
    if (_prefStatus == null) {
      _showError('Vui lòng chọn tình trạng');
      return false;
    }
    if (_prefSchedule == null) {
      _showError('Vui lòng chọn giờ giấc');
      return false;
    }
    if (_prefCleanliness == null) {
      _showError('Vui lòng chọn mức độ sạch sẽ');
      return false;
    }
    if (_prefHabits == null) {
      _showError('Vui lòng chọn thói quen');
      return false;
    }
    if (_prefPets == null) {
      _showError('Vui lòng chọn về thú cưng');
      return false;
    }
    if (_prefMoveInTime == null) {
      _showError('Vui lòng chọn thời gian dọn vào');
      return false;
    }
    return true;
  }

  bool _validateContact() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showError('Vui lòng nhập số điện thoại');
      return false;
    }
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

  // ── Navigation ──

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

  // ── Submit ──

  Future<void> _submit() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) return;

      final location = [
        getDistrictLabel(_selectedCity, _selectedDistrict),
        getCityLabel(_selectedCity),
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'author': user.displayName ?? '',
        'authorName': user.displayName ?? '',
        'userId': user.uid,
        'category': _category,
        'location': location,
        'city': _selectedCity,
        'district': _selectedDistrict,
        'description': _introController.text.trim(),
        'introduction': _introController.text.trim(),
        'phone': _phoneController.text.trim(),
        'postedDate': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        if (_selectedPropertyType != null) ...{
          'propertyType': _selectedPropertyType,
          'propertyTypes': [_selectedPropertyType],
        },
        if (_addressController.text.trim().isNotEmpty) 'specificAddress': _addressController.text.trim(),
        if (_buildingController.text.trim().isNotEmpty) 'buildingName': _buildingController.text.trim(),
        if (_sameAsPhone)
          'zalo': _phoneController.text.trim()
        else if (_zaloController.text.trim().isNotEmpty)
          'zalo': _zaloController.text.trim(),
        if (_facebookController.text.trim().isNotEmpty) 'facebook': _facebookController.text.trim(),
        if (_instagramController.text.trim().isNotEmpty) 'instagram': _instagramController.text.trim(),
        if (_selectedAmenities.isNotEmpty) 'amenities': _selectedAmenities,
        if (_amenitiesOtherController.text.trim().isNotEmpty) 'amenitiesOther': _amenitiesOtherController.text.trim(),
        if (_roomSizeController.text.trim().isNotEmpty) 'roomSize': _roomSizeController.text.trim(),
        if (_occupantsController.text.trim().isNotEmpty) 'currentOccupants': _occupantsController.text.trim(),
        if (_othersIntroController.text.trim().isNotEmpty) 'othersIntro': _othersIntroController.text.trim(),
        'contact': {
          'phone': _phoneController.text.trim(),
          if (_sameAsPhone)
            'zalo': _phoneController.text.trim()
          else if (_zaloController.text.trim().isNotEmpty)
            'zalo': _zaloController.text.trim(),
          if (_facebookController.text.trim().isNotEmpty) 'facebook': _facebookController.text.trim(),
          if (_instagramController.text.trim().isNotEmpty) 'instagram': _instagramController.text.trim(),
        },
        'preferences': {
          if (_prefGender != null) 'gender': [_prefGender],
          if (_prefStatus != null) 'status': [_prefStatus],
          if (_prefSchedule != null) 'schedule': [_prefSchedule],
          if (_prefCleanliness != null) 'cleanliness': [_prefCleanliness],
          if (_prefHabits != null) 'habits': [_prefHabits],
          if (_prefPets != null) 'pets': [_prefPets],
          if (_prefMoveInTime != null) 'moveInTime': [_prefMoveInTime],
          if (_prefOtherController.text.trim().isNotEmpty) 'other': _prefOtherController.text.trim(),
        },
      };

      // Category-specific data (strip currency dots before saving)
      if (_category == 'roommate') {
        data['roommateType'] = _roommateType;
        data['price'] = stripCurrencyDots(_priceController.text.trim());
        if (_roommateType == 'find-partner') {
          data['moveInDate'] = _moveInController.text.trim();
          data['locationNegotiable'] = _locationNegotiable;
          data['timeNegotiable'] = _timeNegotiable;
        } else {
          data['moveInDate'] = '';
          if (_contractController.text.trim().isNotEmpty) {
            data['minContractDuration'] = _contractController.text.trim();
          }
        }
      } else if (_category == 'roomshare') {
        data['roommateType'] = 'have-room';
        data['price'] = stripCurrencyDots(_rentController.text.trim());
        data['moveInDate'] = 'Linh hoạt';
        if (_totalRoomsController.text.trim().isNotEmpty) {
          data['totalRooms'] = _totalRoomsController.text.trim();
        }
        if (_depositController.text.trim().isNotEmpty) {
          data['deposit'] = stripCurrencyDots(_depositController.text.trim());
        }
        if (_minLeaseController.text.trim().isNotEmpty) {
          data['minContractDuration'] = _minLeaseController.text.trim();
        }
        // Costs
        final costs = <String, String>{};
        costs['rent'] = stripCurrencyDots(_rentController.text.trim());
        if (_depositController.text.trim().isNotEmpty) {
          costs['deposit'] = stripCurrencyDots(_depositController.text.trim());
        }
        for (final entry in _costControllers.entries) {
          if (entry.value.text.trim().isNotEmpty) {
            costs[entry.key] = stripCurrencyDots(entry.value.text.trim());
          }
        }
        if (costs.isNotEmpty) data['costs'] = costs;
      }

      final listingService = ref.read(listingServiceProvider);
      final listingId = listingService.generateListingId(_category);

      // Upload images if any
      if (_imagePaths.isNotEmpty) {
        final uploadService = ref.read(imageUploadServiceProvider);
        final imageUrls = await uploadService.uploadImages(
          _imagePaths,
          'listings',
          listingId,
        );
        if (imageUrls.isNotEmpty) data['images'] = imageUrls;
      }

      await listingService.createListing(data, id: listingId);
      ref.invalidate(listingsProvider);

      if (mounted) _showSuccessDialog();
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
                backgroundColor: _accentColor,
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

  // ── Image picking ──

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
        _imagePaths.addAll(images.take(remaining).map((f) => f.path));
      });
    }
  }

  // ── Nav buttons ──

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

  // ── Build pages ──

  List<Widget> _buildStepPages() {
    final totalSteps = _totalSteps;
    Widget navFor(int stepIndex) => _buildNavButtons(stepIndex == totalSteps - 1);

    final isFindPartner = _category == 'roommate' && _roommateType == 'find-partner';
    final isRoomshare = _category == 'roomshare';

    final pages = <Widget>[];

    // Step 0: Basic info (varies per category)
    if (isRoomshare) {
      pages.add(RoomshareBasic(
        selectedPropertyType: _selectedPropertyType,
        onPropertyTypeChanged: (v) => setState(() => _selectedPropertyType = v),
        titleController: _titleController,
        introController: _introController,
        othersIntroController: _othersIntroController,
        addressController: _addressController,
        buildingController: _buildingController,
        selectedCity: _selectedCity,
        selectedDistrict: _selectedDistrict,
        onCityChanged: (v) => setState(() => _selectedCity = v),
        onDistrictChanged: (v) => setState(() => _selectedDistrict = v),
        totalRoomsController: _totalRoomsController,
        roomSizeController: _roomSizeController,
        occupantsController: _occupantsController,
        rentController: _rentController,
        depositController: _depositController,
        minLeaseController: _minLeaseController,
        bottomActions: navFor(0),
      ));
    } else if (isFindPartner) {
      pages.add(RoommateFindPartnerBasic(
        roommateType: _roommateType,
        onRoommateTypeChanged: (v) {
          if (v != _roommateType) {
            setState(() {
              _roommateType = v;
              _currentStep = 0;
            });
            _pageController.jumpToPage(0);
          }
        },
        titleController: _titleController,
        introController: _introController,
        addressOtherController: _addressController,
        priceController: _priceController,
        moveInController: _moveInController,
        selectedCity: _selectedCity,
        selectedDistrict: _selectedDistrict,
        onCityChanged: (v) => setState(() => _selectedCity = v),
        onDistrictChanged: (v) => setState(() => _selectedDistrict = v),
        selectedPropertyType: _selectedPropertyType,
        onPropertyTypeChanged: (v) => setState(() => _selectedPropertyType = v),
        locationNegotiable: _locationNegotiable,
        onLocationNegotiableChanged: (v) => setState(() => _locationNegotiable = v),
        timeNegotiable: _timeNegotiable,
        onTimeNegotiableChanged: (v) => setState(() => _timeNegotiable = v),
        bottomActions: navFor(0),
      ));
    } else {
      // roommate have-room
      pages.add(RoommateHaveRoomBasic(
        roommateType: _roommateType,
        onRoommateTypeChanged: (v) {
          if (v != _roommateType) {
            setState(() {
              _roommateType = v;
              _currentStep = 0;
            });
            _pageController.jumpToPage(0);
          }
        },
        titleController: _titleController,
        introController: _introController,
        addressController: _addressController,
        buildingController: _buildingController,
        priceController: _priceController,
        selectedCity: _selectedCity,
        selectedDistrict: _selectedDistrict,
        onCityChanged: (v) => setState(() => _selectedCity = v),
        onDistrictChanged: (v) => setState(() => _selectedDistrict = v),
        selectedPropertyType: _selectedPropertyType,
        onPropertyTypeChanged: (v) => setState(() => _selectedPropertyType = v),
        bottomActions: navFor(0),
      ));
    }

    // Images/details step (not for find-partner)
    if (!isFindPartner) {
      if (isRoomshare) {
        pages.add(RoomshareImages(
          imagePaths: _imagePaths,
          onAddImages: _pickImages,
          onRemoveImage: (i) => setState(() => _imagePaths.removeAt(i)),
          amenitiesOtherController: _amenitiesOtherController,
          selectedAmenities: _selectedAmenities,
          onAmenitiesChanged: (v) => setState(() => _selectedAmenities = v),
          bottomActions: navFor(1),
        ));
      } else {
        pages.add(RoommateHaveRoomDetails(
          imagePaths: _imagePaths,
          onAddImages: _pickImages,
          onRemoveImage: (i) => setState(() => _imagePaths.removeAt(i)),
          roomSizeController: _roomSizeController,
          occupantsController: _occupantsController,
          contractController: _contractController,
          amenitiesOtherController: _amenitiesOtherController,
          selectedAmenities: _selectedAmenities,
          onAmenitiesChanged: (v) => setState(() => _selectedAmenities = v),
          bottomActions: navFor(1),
        ));
      }
    }

    // Roomshare costs step
    if (isRoomshare) {
      pages.add(RoomshareCosts(
        isApartment: _selectedPropertyType == 'apartment',
        costControllers: _costControllers,
        bottomActions: navFor(2),
      ));
    }

    // Preferences step
    final prefStepIndex = isFindPartner ? 1 : (isRoomshare ? 3 : 2);
    pages.add(SharedPreferencesStep(
      selectedGender: _prefGender,
      onGenderChanged: (v) => setState(() => _prefGender = v),
      selectedStatus: _prefStatus,
      onStatusChanged: (v) => setState(() => _prefStatus = v),
      selectedSchedule: _prefSchedule,
      onScheduleChanged: (v) => setState(() => _prefSchedule = v),
      selectedCleanliness: _prefCleanliness,
      onCleanlinessChanged: (v) => setState(() => _prefCleanliness = v),
      selectedHabits: _prefHabits,
      onHabitsChanged: (v) => setState(() => _prefHabits = v),
      selectedPets: _prefPets,
      onPetsChanged: (v) => setState(() => _prefPets = v),
      selectedMoveInTime: _prefMoveInTime,
      onMoveInTimeChanged: (v) => setState(() => _prefMoveInTime = v),
      otherController: _prefOtherController,
      bottomActions: navFor(prefStepIndex),
    ));

    // Contact step
    final contactStepIndex = totalSteps - 1;
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
      bottomActions: navFor(contactStepIndex),
    ));

    return pages;
  }

  @override
  Widget build(BuildContext context) {
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
              labels: _stepLabels,
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
