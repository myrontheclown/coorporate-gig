import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../models/selected_location.dart';
import '../../models/worker.dart';
import '../../navigation/nav.dart';
import '../../theme/app_theme.dart';
import '../../widgets/circle_avatar.dart';
import '../../widgets/status_badge.dart';
import 'location_picker_screen.dart';
import 'request_service_photos_screen.dart';

class RequestServiceScreen extends StatefulWidget {
  final Worker worker;
  const RequestServiceScreen({super.key, required this.worker});

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  String _urgency = 'Normal';
  String _serviceType = 'Repair';
  final _descController = TextEditingController();
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: AppState.selectedLocation.value?.address ??
          'Flat 402, Royal Residency, Grant Road, Mumbai',
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await Nav.pushForResult<SelectedLocation>(
      context,
      LocationPickerScreen(initialLocation: AppState.selectedLocation.value),
    );
    if (result == null || !mounted) return;
    setState(() {
      AppState.selectedLocation.value = result;
      _addressController.text = result.address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatarImage(
                      initials: widget.worker.avatarInitials,
                      color: widget.worker.color,
                      size: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.worker.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${widget.worker.profession} • ${widget.worker.ratingLabel}★',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const StatusNote(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _Label('Service Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Repair', 'Installation', 'Maintenance', 'Other']
                  .map((t) => ChoiceChip(
                        label: Text(t),
                        selected: _serviceType == t,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _serviceType == t
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        onSelected: (_) =>
                            setState(() => _serviceType = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const _Label('Describe the work needed'),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. Kitchen sink is leaking and needs pipe replacement...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            const _Label('Service Address'),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              readOnly: true,
              onTap: _openLocationPicker,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined),
                suffixIcon: Icon(Icons.map_outlined),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to choose or search your service location on the map.',
              style: AppTextStyles.muted,
            ),
            const SizedBox(height: 20),
            const _Label('Urgency'),
            const SizedBox(height: 8),
            Row(
              children: [
                _UrgencyOption(
                  label: 'Normal',
                  icon: Icons.schedule,
                  selected: _urgency == 'Normal',
                  onTap: () => setState(() => _urgency = 'Normal'),
                ),
                const SizedBox(width: 8),
                _UrgencyOption(
                  label: 'Urgent',
                  icon: Icons.bolt,
                  selected: _urgency == 'Urgent',
                  onTap: () => setState(() => _urgency = 'Urgent'),
                ),
                const SizedBox(width: 8),
                _UrgencyOption(
                  label: 'Emergency',
                  icon: Icons.warning,
                  selected: _urgency == 'Emergency',
                  onTap: () => setState(() => _urgency = 'Emergency'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _navigateToPhotos(context),
                    child: const Text('Add Photos'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToPhotos(context),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPhotos(BuildContext context) {
    // Persist form values so PhotosScreen / job creation can read them.
    AppState.pendingServiceType = _serviceType;
    AppState.pendingDescription = _descController.text.trim();
    AppState.pendingAddress = _addressController.text.trim();
    AppState.pendingUrgency = _urgency;
    AppState.currentService.value = widget.worker.profession;

    Nav.push(
      context,
      RequestServicePhotosScreen(worker: widget.worker),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _UrgencyOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _UrgencyOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusNote extends StatelessWidget {
  const StatusNote({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatusBadge(
      label: 'Available',
      color: AppColors.success,
      icon: Icons.check_circle,
    );
  }
}
