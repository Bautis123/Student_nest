import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/property.dart';
import '../../../services/api_service.dart';
import 'package:student_nest/core/constants/app_strings.dart';
import 'package:student_nest/core/theme/app_colors.dart';
import 'package:student_nest/core/widgets/sn_button.dart';
import 'widgets/manage_listing_cover_photo_card.dart';
import 'widgets/manage_listing_empty_photos.dart';
import 'widgets/manage_listing_photo_grid_item.dart';

class ManageListingPhotosTab extends StatefulWidget {
  final Property property;
  final VoidCallback onUpdated;

  const ManageListingPhotosTab({
    super.key,
    required this.property,
    required this.onUpdated,
  });

  @override
  State<ManageListingPhotosTab> createState() => _ManageListingPhotosTabState();
}

class _ManageListingPhotosTabState extends State<ManageListingPhotosTab> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUpload({bool asCover = false}) async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      final shouldUseAsCover = asCover || widget.property.photos.isEmpty;
      await _api.uploadPhotos(
        widget.property.id,
        images.map((image) => File(image.path)).toList(),
        isCover: shouldUseAsCover,
      );
      widget.onUpdated();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deletePhoto(String photoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Photo'),
            content: const Text('Are you sure you want to delete this photo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(AppStrings.cancel),
              ),
              SNButton(
                label: AppStrings.delete,
                onPressed: () => Navigator.pop(dialogContext, true),
                variant: SNButtonVariant.danger,
                fullWidth: false,
                height: 36,
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await _api.deletePhoto(photoId);
      widget.onUpdated();
    } catch (_) {}
  }

  Future<void> _setCover(String photoId) async {
    try {
      await _api.setCoverPhoto(widget.property.id, photoId);
      widget.onUpdated();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cover photo updated')));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.property.photos;
    final coverPhoto = _resolveCoverPhoto(photos);
    final otherPhotos =
        photos.where((photo) => photo.id != coverPhoto?.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cover Photo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppDesign.text(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is the main photo students see on listing cards',
            style: TextStyle(fontSize: 12, color: AppDesign.muted(context)),
          ),
          const SizedBox(height: 12),
          ManageListingCoverPhotoCard(
            coverPhoto: coverPhoto,
            onAddTap: () => _pickAndUpload(asCover: true),
            onDeleteTap:
                coverPhoto == null ? null : () => _deletePhoto(coverPhoto.id),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Photos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppDesign.text(context),
                ),
              ),
              SNButton(
                label:
                    _isUploading ? AppStrings.uploading : AppStrings.addPhotos,
                onPressed: _isUploading ? null : () => _pickAndUpload(),
                leadingIcon: _isUploading ? null : Icons.add,
                isLoading: _isUploading,
                fullWidth: false,
                height: 36,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a photo to set it as cover',
            style: TextStyle(fontSize: 12, color: AppDesign.muted(context)),
          ),
          const SizedBox(height: 12),
          if (otherPhotos.isEmpty && coverPhoto == null)
            const ManageListingEmptyPhotos()
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
              itemBuilder: (_, index) {
                final photo = otherPhotos[index];
                return ManageListingPhotoGridItem(
                  photo: photo,
                  onTap: () => _setCover(photo.id),
                  onDeleteTap: () => _deletePhoto(photo.id),
                );
              },
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Photo? _resolveCoverPhoto(List<Photo> photos) {
    if (photos.isEmpty) return null;
    for (final photo in photos) {
      if (photo.isCover) return photo;
    }
    return photos.first;
  }
}
