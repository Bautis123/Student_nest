import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../utils/theme.dart';

class ManageListingScreen extends StatefulWidget {
  final Property property;

  const ManageListingScreen({super.key, required this.property});

  @override
  State<ManageListingScreen> createState() => _ManageListingScreenState();
}

class _ManageListingScreenState extends State<ManageListingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();
  late Property _property;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _property = widget.property;
    _loadFullProperty();
  }

  Future<void> _loadFullProperty() async {
    try {
      final p = await _api.getPropertyById(_property.id);
      setState(() => _property = p);
    } catch (e) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleActive() async {
    try {
      await _api.togglePropertyActive(_property.id, !_property.isActive);
      await _loadFullProperty();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _property.isActive ? 'Listing deactivated' : 'Listing activated',
            ),
          ),
        );
      }
    } catch (e) {}
  }

  Future<void> _deleteListing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Listing'),
            content: const Text(
              'Are you sure you want to delete this listing? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _api.deleteProperty(_property.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _property.title,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          _property.isActive
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(_property.isActive ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppTheme.error,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Delete Listing',
                          style: TextStyle(color: AppTheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              if (value == 'toggle') _toggleActive();
              if (value == 'delete') _deleteListing();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Photos'),
            Tab(text: 'Rooms'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _DetailsTab(
                    property: _property,
                    onUpdated: _loadFullProperty,
                  ),
                  _PhotosTab(property: _property, onUpdated: _loadFullProperty),
                  _RoomsTab(property: _property, onUpdated: _loadFullProperty),
                ],
              ),
    );
  }
}

// ── DETAILS TAB ───────────────────────────────────────────────

class _DetailsTab extends StatefulWidget {
  final Property property;
  final VoidCallback onUpdated;

  const _DetailsTab({required this.property, required this.onUpdated});

  @override
  State<_DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<_DetailsTab> {
  final ApiService _api = ApiService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late bool _hasWifi;
  late bool _hasWater;
  late bool _hasElectricity;
  late bool _hasSecurity;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property.title);
    _descriptionController = TextEditingController(
      text: widget.property.description ?? '',
    );
    _addressController = TextEditingController(text: widget.property.address);
    _hasWifi = widget.property.amenities['wifi'] == true;
    _hasWater = widget.property.amenities['water'] == true;
    _hasElectricity = widget.property.amenities['electricity'] == true;
    _hasSecurity = widget.property.amenities['security'] == true;
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await _api.updateProperty(widget.property.id, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'amenities': {
          'wifi': _hasWifi,
          'water': _hasWater,
          'electricity': _hasElectricity,
          'security': _hasSecurity,
        },
      });
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
      widget.onUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        widget.property.isApproved
                            ? AppTheme.success
                            : AppTheme.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.property.isApproved
                      ? 'Live — visible to students'
                      : 'Pending admin approval',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        widget.property.isApproved
                            ? AppTheme.success
                            : AppTheme.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.property.viewCount} views',
                  style: const TextStyle(fontSize: 12, color: AppTheme.gray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Title'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            onChanged: (_) => setState(() => _hasChanges = true),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.home_work_outlined),
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Address'),
          const SizedBox(height: 6),
          TextField(
            controller: _addressController,
            onChanged: (_) => setState(() => _hasChanges = true),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Description'),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            onChanged: (_) => setState(() => _hasChanges = true),
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
                  (v) => setState(() {
                    _hasWifi = v;
                    _hasChanges = true;
                  }),
                ),
                _amenitySwitch(
                  'Water',
                  Icons.water_drop_outlined,
                  _hasWater,
                  (v) => setState(() {
                    _hasWater = v;
                    _hasChanges = true;
                  }),
                ),
                _amenitySwitch(
                  'Electricity',
                  Icons.bolt_outlined,
                  _hasElectricity,
                  (v) => setState(() {
                    _hasElectricity = v;
                    _hasChanges = true;
                  }),
                ),
                _amenitySwitch(
                  'Security',
                  Icons.security_outlined,
                  _hasSecurity,
                  (v) => setState(() {
                    _hasSecurity = v;
                    _hasChanges = true;
                  }),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_hasChanges)
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
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
                      : const Text('Save Changes'),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppTheme.dark,
    ),
  );

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
}

// ── PHOTOS TAB ────────────────────────────────────────────────

class _PhotosTab extends StatefulWidget {
  final Property property;
  final VoidCallback onUpdated;

  const _PhotosTab({required this.property, required this.onUpdated});

  @override
  State<_PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends State<_PhotosTab> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isEmpty) return;
    setState(() => _isUploading = true);
    try {
      await _api.uploadPhotos(
        widget.property.id,
        images.map((x) => File(x.path)).toList(),
      );
      widget.onUpdated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Try again.')),
        );
      }
    }
    setState(() => _isUploading = false);
  }

  Future<void> _deletePhoto(String photoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Photo'),
            content: const Text('Are you sure you want to delete this photo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    try {
      await _api.deletePhoto(photoId);
      widget.onUpdated();
    } catch (e) {}
  }

  Future<void> _setCover(String photoId) async {
    try {
      await _api.setCoverPhoto(widget.property.id, photoId);
      widget.onUpdated();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cover photo updated')));
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.property.photos;
    final coverPhoto =
        photos.isNotEmpty
            ? photos.firstWhere((p) => p.isCover, orElse: () => photos.first)
            : null;
    final otherPhotos = photos.where((p) => p.id != coverPhoto?.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cover Photo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.dark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is the main photo students see on listing cards',
            style: TextStyle(fontSize: 12, color: AppTheme.gray),
          ),
          const SizedBox(height: 12),
          if (coverPhoto != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    coverPhoto.url,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Cover',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => _deletePhoto(coverPhoto.id),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: _pickAndUpload,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppTheme.primary,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to add cover photo',
                      style: TextStyle(color: AppTheme.primary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Photos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.dark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUpload,
                icon:
                    _isUploading
                        ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.add, size: 16),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Add Photos',
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap a photo to set it as cover',
            style: TextStyle(fontSize: 12, color: AppTheme.gray),
          ),
          const SizedBox(height: 12),
          if (otherPhotos.isEmpty && coverPhoto == null)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 48,
                      color: AppTheme.gray,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No photos yet',
                      style: TextStyle(
                        color: AppTheme.gray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap Add Photos to upload',
                      style: TextStyle(color: AppTheme.gray, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: otherPhotos.length,
              itemBuilder: (_, i) {
                final photo = otherPhotos[i];
                return GestureDetector(
                  onTap: () => _setCover(photo.id),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photo.url,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Set as cover',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _deletePhoto(photo.id),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ── ROOMS TAB ─────────────────────────────────────────────────

class _RoomsTab extends StatefulWidget {
  final Property property;
  final VoidCallback onUpdated;

  const _RoomsTab({required this.property, required this.onUpdated});

  @override
  State<_RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<_RoomsTab> {
  final ApiService _api = ApiService();

  Future<void> _addRoomDialog() async {
    final priceController = TextEditingController();
    int studentsPerRoom = 1;
    int totalRooms = 1;
    final roomTypes = ['single', 'double', 'shared', 'self-contained'];
    String selectedType = 'single';

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (ctx, setModalState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Add Room Type'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Room Type',
                          ),
                          items:
                              roomTypes
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        t[0].toUpperCase() + t.substring(1),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setModalState(
                                () => selectedType = v ?? 'single',
                              ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price per month (K)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Students/room',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.gray,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (studentsPerRoom > 1) {
                                            setModalState(
                                              () => studentsPerRoom--,
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.remove),
                                      ),
                                      Text('$studentsPerRoom'),
                                      IconButton(
                                        onPressed:
                                            () => setModalState(
                                              () => studentsPerRoom++,
                                            ),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total rooms',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.gray,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (totalRooms > 1) {
                                            setModalState(() => totalRooms--);
                                          }
                                        },
                                        icon: const Icon(Icons.remove),
                                      ),
                                      Text('$totalRooms'),
                                      IconButton(
                                        onPressed:
                                            () => setModalState(
                                              () => totalRooms++,
                                            ),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (priceController.text.isEmpty) return;
                        Navigator.pop(ctx);
                        await _api.addRooms(widget.property.id, [
                          {
                            'room_type': selectedType,
                            'price_per_month': double.parse(
                              priceController.text,
                            ),
                            'students_per_room': studentsPerRoom,
                            'total_rooms': totalRooms,
                            'available_rooms': totalRooms,
                          },
                        ]);
                        widget.onUpdated();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = widget.property.rooms;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: _addRoomDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Room Type'),
          ),
          const SizedBox(height: 16),
          if (rooms.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.bed_outlined, size: 48, color: AppTheme.gray),
                    SizedBox(height: 12),
                    Text(
                      'No room types yet',
                      style: TextStyle(
                        color: AppTheme.gray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...rooms.map(
              (room) => Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.bed_outlined,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.roomType[0].toUpperCase() +
                                    room.roomType.substring(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${room.studentsPerRoom} student${room.studentsPerRoom > 1 ? 's' : ''}/room · K${room.pricePerMonth.toStringAsFixed(0)}/mo',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available rooms',
                          style: TextStyle(fontSize: 13, color: AppTheme.gray),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (room.availableRooms > 0) {
                                  await _api.updateRoomAvailability(
                                    room.id,
                                    room.availableRooms - 1,
                                  );
                                  widget.onUpdated();
                                }
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${room.availableRooms}/${room.totalRooms}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.dark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                if (room.availableRooms < room.totalRooms) {
                                  await _api.updateRoomAvailability(
                                    room.id,
                                    room.availableRooms + 1,
                                  );
                                  widget.onUpdated();
                                }
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:
                            room.totalRooms > 0
                                ? room.availableRooms / room.totalRooms
                                : 0,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          room.availableRooms == 0
                              ? AppTheme.error
                              : room.availableRooms < room.totalRooms
                              ? AppTheme.warning
                              : AppTheme.success,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.availableRooms == 0
                          ? 'Full — no rooms available'
                          : room.availableRooms == room.totalRooms
                          ? 'All rooms available'
                          : '${room.totalRooms - room.availableRooms} room${room.totalRooms - room.availableRooms > 1 ? 's' : ''} occupied',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            room.availableRooms == 0
                                ? AppTheme.error
                                : room.availableRooms == room.totalRooms
                                ? AppTheme.success
                                : AppTheme.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
