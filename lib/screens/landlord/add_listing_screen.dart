import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/api_service.dart';
import 'package:student_nest/core/constants/app_constants.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'add_listing/add_listing_success_dialog.dart';
import 'add_listing/widgets/add_listing_action_bar.dart';
import 'add_listing/widgets/add_listing_error_banner.dart';
import 'add_listing/widgets/add_listing_location_page.dart';
import 'add_listing/widgets/add_listing_rooms_page.dart';
import 'add_listing/widgets/add_listing_step_header.dart';
import 'add_listing/widgets/add_listing_details_page.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final ApiService _api = ApiService();
  final PageController _pageController = PageController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  int _currentPage = 0;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _schools = [];
  String? _selectedSchoolId;
  bool _hasWifi = false;
  bool _hasWater = true;
  bool _hasElectricity = true;
  bool _hasSecurity = false;
  LatLng _selectedLocation = const LatLng(
    AppConstants.defaultLat,
    AppConstants.defaultLng,
  );
  GoogleMapController? _mapController;

  final List<Map<String, dynamic>> _rooms = [_createDefaultRoom()];

  static const List<String> _roomTypes = [
    'single',
    'double',
    'shared',
    'self-contained',
  ];

  static Map<String, dynamic> _createDefaultRoom() => {
    'room_type': 'single',
    'price_per_month': '',
    'students_per_room': 1,
    'total_rooms': 1,
    'available_rooms': 1,
  };

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _api.getSchools();
      if (!mounted) return;
      setState(() => _schools = schools);
    } catch (_) {}
  }

  Future<void> _useMyLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return _setError('Location permission denied');
      }

      if (permission == LocationPermission.deniedForever) {
        return _setError(
          'Location permission permanently denied. Enable it in settings.',
        );
      }

      setState(() => _isLoading = true);
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() {
        _selectedLocation = newLocation;
        _isLoading = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 17),
      );
    } catch (_) {
      _setError('Could not get location. Try tapping the map instead.');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setError(String? message) {
    if (!mounted) return;
    setState(() => _error = message);
  }

  void _nextPage() {
    if (_currentPage == 0 && !_validateDetailsPage()) return;
    if (_currentPage >= 2) return;

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _prevPage() {
    if (_currentPage == 0) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage--);
  }

  bool _validateDetailsPage() {
    if (_titleController.text.isEmpty) return _fail('Please enter a title');
    if (_addressController.text.isEmpty) {
      return _fail('Please enter an address');
    }
    if (_selectedSchoolId == null) {
      return _fail('Please select the nearest school');
    }

    _setError(null);
    return true;
  }

  bool _validateRoomsPage() {
    for (final room in _rooms) {
      if (room['price_per_month'].toString().isEmpty) {
        return _fail('Please enter price for all room types');
      }
    }

    _setError(null);
    return true;
  }

  bool _fail(String message) {
    _setError(message);
    return false;
  }

  Future<void> _submitListing() async {
    if (!_validateRoomsPage()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final propertyResult = await _api.createProperty({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'nearest_school_id': _selectedSchoolId,
        'amenities': {
          'wifi': _hasWifi,
          'water': _hasWater,
          'electricity': _hasElectricity,
          'security': _hasSecurity,
        },
      });

      if (propertyResult['property'] == null) {
        _setError(propertyResult['message'] ?? 'Failed to create listing');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final propertyId = propertyResult['property']['id'];
      final roomsData =
          _rooms
              .map(
                (room) => {
                  'room_type': room['room_type'],
                  'price_per_month': double.parse(
                    room['price_per_month'].toString(),
                  ),
                  'students_per_room': room['students_per_room'],
                  'total_rooms': room['total_rooms'],
                  'available_rooms': room['available_rooms'],
                },
              )
              .toList();

      await _api.addRooms(propertyId, roomsData);
      if (!mounted) return;

      setState(() => _isLoading = false);
      AddListingSuccessDialog.show(context);
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.page(context),
      appBar: AppBar(
        title: const Text('Add Listing'),
        backgroundColor: AppDesign.surface(context),
        foregroundColor: AppDesign.text(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppDesign.text(context),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppDesign.surface(context),
            hintStyle: TextStyle(color: AppDesign.subtle(context)),
            labelStyle: TextStyle(color: AppDesign.muted(context)),
            prefixIconColor: AppDesign.muted(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppDesign.border(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppDesign.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppDesign.accent, width: 1.4),
            ),
          ),
        ),
        child: Column(
          children: [
            AddListingStepHeader(currentPage: _currentPage),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AddListingDetailsPage(
                    titleController: _titleController,
                    addressController: _addressController,
                    descriptionController: _descriptionController,
                    schools: _schools,
                    selectedSchoolId: _selectedSchoolId,
                    hasWifi: _hasWifi,
                    hasWater: _hasWater,
                    hasElectricity: _hasElectricity,
                    hasSecurity: _hasSecurity,
                    onSchoolChanged:
                        (value) => setState(() => _selectedSchoolId = value),
                    onWifiChanged: (value) => setState(() => _hasWifi = value),
                    onWaterChanged:
                        (value) => setState(() => _hasWater = value),
                    onElectricityChanged:
                        (value) => setState(() => _hasElectricity = value),
                    onSecurityChanged:
                        (value) => setState(() => _hasSecurity = value),
                  ),
                  AddListingLocationPage(
                    selectedLocation: _selectedLocation,
                    isLoading: _isLoading,
                    onUseMyLocation: _useMyLocation,
                    onMapCreated: (controller) => _mapController = controller,
                    onLocationSelected: (location) {
                      setState(() => _selectedLocation = location);
                    },
                  ),
                  AddListingRoomsPage(
                    rooms: _rooms,
                    roomTypes: _roomTypes,
                    onAddRoom:
                        () => setState(() => _rooms.add(_createDefaultRoom())),
                    onRemoveRoom:
                        (index) => setState(() => _rooms.removeAt(index)),
                    onRoomTypeChanged: (index, value) {
                      setState(() => _rooms[index]['room_type'] = value);
                    },
                    onPriceChanged: (index, value) {
                      _rooms[index]['price_per_month'] = value;
                    },
                    onStudentsChanged: (index, value) {
                      setState(
                        () => _rooms[index]['students_per_room'] = value,
                      );
                    },
                    onTotalRoomsChanged: (index, value) {
                      setState(() {
                        _rooms[index]['total_rooms'] = value;
                        _rooms[index]['available_rooms'] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            AddListingErrorBanner(message: _error),
            AddListingActionBar(
              currentPage: _currentPage,
              isLoading: _isLoading,
              onBack: _prevPage,
              onNext: _nextPage,
              onSubmit: _submitListing,
            ),
          ],
        ),
      ),
    );
  }
}
