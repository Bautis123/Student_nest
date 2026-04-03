import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final ApiService _api = ApiService();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  String? _error;

  // Schools
  List<Map<String, dynamic>> _schools = [];
  String? _selectedSchoolId;

  // Property details
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  // Amenities
  bool _hasWifi = false;
  bool _hasWater = true;
  bool _hasElectricity = true;
  bool _hasSecurity = false;

  // Location
  LatLng _selectedLocation = const LatLng(
    AppConstants.defaultLat,
    AppConstants.defaultLng,
  );
  GoogleMapController? _mapController;

  // Rooms
  List<Map<String, dynamic>> _rooms = [
    {
      'room_type': 'single',
      'price_per_month': '',
      'students_per_room': 1,
      'total_rooms': 1,
      'available_rooms': 1,
    },
  ];

  final List<String> _roomTypes = [
    'single',
    'double',
    'shared',
    'self-contained',
  ];

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _api.getSchools();
      setState(() => _schools = schools);
    } catch (e) {}
  }

  Future<void> _useMyLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _error = 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(
          () =>
              _error =
                  'Location permission permanently denied. Enable it in settings.',
        );
        return;
      }

      setState(() => _isLoading = true);
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = newLocation;
        _isLoading = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 17),
      );
    } catch (e) {
      setState(() {
        _error = 'Could not get location. Try tapping the map instead.';
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage == 0 && !_validateDetailsPage()) return;
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  bool _validateDetailsPage() {
    if (_titleController.text.isEmpty) {
      setState(() => _error = 'Please enter a title');
      return false;
    }
    if (_addressController.text.isEmpty) {
      setState(() => _error = 'Please enter an address');
      return false;
    }
    if (_selectedSchoolId == null) {
      setState(() => _error = 'Please select the nearest school');
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  bool _validateRoomsPage() {
    for (final room in _rooms) {
      if (room['price_per_month'].toString().isEmpty) {
        setState(() => _error = 'Please enter price for all room types');
        return false;
      }
    }
    setState(() => _error = null);
    return true;
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
        setState(() {
          _error = propertyResult['message'] ?? 'Failed to create listing';
          _isLoading = false;
        });
        return;
      }

      final propertyId = propertyResult['property']['id'];

      final roomsData =
          _rooms
              .map(
                (r) => {
                  'room_type': r['room_type'],
                  'price_per_month': double.parse(
                    r['price_per_month'].toString(),
                  ),
                  'students_per_room': r['students_per_room'],
                  'total_rooms': r['total_rooms'],
                  'available_rooms': r['available_rooms'],
                },
              )
              .toList();

      await _api.addRooms(propertyId, roomsData);

      setState(() => _isLoading = false);
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.success,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Listing Submitted!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your listing has been submitted for admin review. It will go live once approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Add Listing'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _stepIndicator(0, 'Details'),
                _stepDivider(),
                _stepIndicator(1, 'Location'),
                _stepDivider(),
                _stepIndicator(2, 'Rooms'),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_detailsPage(), _locationPage(), _roomsPage()],
            ),
          ),
          if (_error != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.error.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppTheme.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppTheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevPage,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : (_currentPage < 2 ? _nextPage : _submitListing),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              _currentPage < 2 ? 'Next' : 'Submit Listing',
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator(int step, String label) {
    final isActive = _currentPage >= step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppTheme.primary : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDivider() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.white.withOpacity(0.3),
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }

  Widget _detailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _fieldLabel('Property Title *'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'e.g. Chanda Boarding House',
              prefixIcon: Icon(Icons.home_work_outlined),
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Address *'),
          const SizedBox(height: 6),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: 'e.g. Plot 15, Olympia Park, Lusaka',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Nearest School *'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedSchoolId,
            decoration: const InputDecoration(
              hintText: 'Select nearest school',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items:
                _schools
                    .map(
                      (s) => DropdownMenuItem(
                        value: s['id'] as String,
                        child: Text(s['name']),
                      ),
                    )
                    .toList(),
            onChanged: (v) => setState(() => _selectedSchoolId = v),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Description'),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe your property...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          _fieldLabel('Amenities'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _amenitySwitch(
                  'WiFi',
                  Icons.wifi,
                  _hasWifi,
                  (v) => setState(() => _hasWifi = v),
                ),
                _amenitySwitch(
                  'Water',
                  Icons.water_drop_outlined,
                  _hasWater,
                  (v) => setState(() => _hasWater = v),
                ),
                _amenitySwitch(
                  'Electricity',
                  Icons.bolt_outlined,
                  _hasElectricity,
                  (v) => setState(() => _hasElectricity = v),
                ),
                _amenitySwitch(
                  'Security',
                  Icons.security_outlined,
                  _hasSecurity,
                  (v) => setState(() => _hasSecurity = v),
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationPage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: AppTheme.primaryLight,
          child: Row(
            children: [
              const Icon(
                Icons.touch_app_outlined,
                color: AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tap the map to pin your property or use your current location',
                  style: TextStyle(fontSize: 12, color: AppTheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _useMyLocation,
                icon: const Icon(Icons.my_location, size: 14),
                label: const Text(
                  'My Location',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: AppConstants.defaultZoom,
            ),
            onMapCreated: (c) => _mapController = c,
            onTap: (latLng) => setState(() => _selectedLocation = latLng),
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                infoWindow: const InfoWindow(title: 'Your property'),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.gray),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roomsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Room Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.dark,
                ),
              ),
              TextButton.icon(
                onPressed:
                    () => setState(
                      () => _rooms.add({
                        'room_type': 'single',
                        'price_per_month': '',
                        'students_per_room': 1,
                        'total_rooms': 1,
                        'available_rooms': 1,
                      }),
                    ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Type'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._rooms.asMap().entries.map((entry) {
            final i = entry.key;
            final room = entry.value;
            return _roomCard(i, room);
          }),
        ],
      ),
    );
  }

  Widget _roomCard(int index, Map<String, dynamic> room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room Type ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.dark,
                ),
              ),
              if (_rooms.length > 1)
                GestureDetector(
                  onTap: () => setState(() => _rooms.removeAt(index)),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppTheme.gray,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: room['room_type'],
            decoration: const InputDecoration(
              labelText: 'Type',
              prefixIcon: Icon(Icons.bed_outlined),
            ),
            items:
                _roomTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t[0].toUpperCase() + t.substring(1)),
                      ),
                    )
                    .toList(),
            onChanged: (v) => setState(() => _rooms[index]['room_type'] = v),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Price per month (K)',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            onChanged: (v) => _rooms[index]['price_per_month'] = v,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Students per room',
                      style: TextStyle(fontSize: 12, color: AppTheme.gray),
                    ),
                    const SizedBox(height: 6),
                    _counter(
                      value: room['students_per_room'],
                      min: 1,
                      max: 10,
                      onChanged:
                          (v) => setState(
                            () => _rooms[index]['students_per_room'] = v,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total rooms',
                      style: TextStyle(fontSize: 12, color: AppTheme.gray),
                    ),
                    const SizedBox(height: 6),
                    _counter(
                      value: room['total_rooms'],
                      min: 1,
                      max: 50,
                      onChanged:
                          (v) => setState(() {
                            _rooms[index]['total_rooms'] = v;
                            _rooms[index]['available_rooms'] = v;
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counter({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (value > min) onChanged(value - 1);
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.remove, size: 16, color: AppTheme.primary),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            if (value < max) onChanged(value + 1);
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 16, color: AppTheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _amenitySwitch(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
        title: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: value ? AppTheme.primary : AppTheme.gray,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: value ? AppTheme.dark : AppTheme.gray,
                fontWeight: value ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.dark,
      ),
    );
  }
}
