import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/app_state.dart';
import '../../models/job.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../services/job_service.dart';
import '../../theme/app_theme.dart';
import 'matching_engine_screen.dart';

class RequestServicePhotosScreen extends StatefulWidget {
  final Worker worker;
  const RequestServicePhotosScreen({super.key, required this.worker});

  @override
  State<RequestServicePhotosScreen> createState() =>
      _RequestServicePhotosScreenState();
}

class _RequestServicePhotosScreenState
    extends State<RequestServicePhotosScreen> {
  final List<XFile> _photos = [];
  final _picker = ImagePicker();
  bool _submitting = false;

  // ── helpers ──────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() => _photos.addAll(picked));
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _photos.add(picked));
    }
  }

  void _showPickSource() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  // ── submit ───────────────────────────────────────────────────────────

  Future<void> _submitJob() async {
    if (_submitting) return;

    final customerId = AppState.currentUserProfile.value?.id ?? '';
    if (customerId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to request a service.')),
      );
      return;
    }

    setState(() => _submitting = true);

    final job = Job(
      id: '', // Supabase will generate UUID
      workerId: widget.worker.id,
      customerId: customerId,
      jobTitle: AppState.pendingServiceType,
      description: [
        AppState.pendingDescription,
        if (AppState.pendingAddress.isNotEmpty)
          'Address: ${AppState.pendingAddress}',
        if (AppState.pendingUrgency.isNotEmpty)
          'Urgency: ${AppState.pendingUrgency}',
      ].join('\n'),
      status: 'pending',
    );

    final created = await JobService.createJobWithPhotos(
      job: job,
      photos: _photos,
    );

    if (!mounted) return;

    if (created == null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create job. Please try again.'),
        ),
      );
      return;
    }

    // Job created – proceed to matching engine.
    Nav.pushReplacement(
      context,
      MatchingEngineScreen(worker: widget.worker),
    );
  }

  // ── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Photos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add photos to help the worker understand the work needed',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // ── Photo grid ─────────────────────────────────────────────
            _buildPhotoGrid(),

            const SizedBox(height: 24),

            // ── Info tip ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Photos help matching engine recommend the right worker faster',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit button ──────────────────────────────────────────
            if (_submitting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ElevatedButton(
                onPressed: _submitJob,
                child: const Text('Submit & Find Best Match'),
              ),
          ],
        ),
      ),
    );
  }

  // ── Photo grid builder ─────────────────────────────────────────────

  Widget _buildPhotoGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Existing photos
        for (int i = 0; i < _photos.length; i++)
          _PhotoTile(
            file: _photos[i],
            onRemove: () => _removePhoto(i),
          ),

        // Add-photo button
        _AddPhotoTile(onTap: _showPickSource),
      ],
    );
  }
}

// ── Internal widgets ───────────────────────────────────────────────────

class _PhotoTile extends StatefulWidget {
  final XFile file;
  final VoidCallback onRemove;
  const _PhotoTile({required this.file, required this.onRemove});

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  Future<void> _loadBytes() async {
    final bytes = await widget.file.readAsBytes();
    if (mounted) setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _bytes != null
              ? Image.memory(
                  _bytes!,
                  width: 150,
                  height: 120,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 150,
                  height: 120,
                  color: AppColors.background,
                  child: const Center(child: CircularProgressIndicator()),
                ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPhotoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 150,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 30),
            SizedBox(height: 6),
            Text(
              'Add photo',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
