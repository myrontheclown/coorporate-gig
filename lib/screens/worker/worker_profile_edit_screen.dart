import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../models/user_profile.dart';
import '../../models/worker_profile.dart';
import '../../services/user_profile_service.dart';
import '../../services/worker_profile_service.dart';

class WorkerEditProfileScreen extends StatefulWidget {
  const WorkerEditProfileScreen({super.key});

  @override
  State<WorkerEditProfileScreen> createState() =>
      _WorkerEditProfileScreenState();
}

class _WorkerEditProfileScreenState
    extends State<WorkerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  final _serviceAreaController = TextEditingController();
  final _workingAreaController = TextEditingController();

  final _skillController = TextEditingController();

  final List<String> _skills = [];

  bool _isSaving = false;
  bool _isLoading = true;

  UserProfile? _userProfile;
  WorkerProfile? _workerProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = AppState.currentUserProfile.value;
    final worker = AppState.currentWorkerProfile.value;

    _userProfile = user;
    _workerProfile = worker;

    if (user != null) {
      _nameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
    }

    if (worker != null) {
      _emergencyNameController.text =
          worker.emergencyContactName;

      _emergencyPhoneController.text =
          worker.emergencyContactPhone;

      _serviceAreaController.text =
          worker.serviceArea;

      _workingAreaController.text =
          worker.workingArea;
    }

    if (worker != null && worker.id.isNotEmpty) {
      final skills =
          await WorkerProfileService.getWorkerSkills(worker.id);

      if (mounted) {
        setState(() {
          _skills.addAll(skills);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();

    _serviceAreaController.dispose();
    _workingAreaController.dispose();

    _skillController.dispose();

    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();

    if (skill.isEmpty) return;

    if (_skills.any(
      (existing) =>
          existing.toLowerCase() == skill.toLowerCase(),
    )) {
      _skillController.clear();
      return;
    }

    setState(() {
      _skills.add(skill);
      _skillController.clear();
    });
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_userProfile == null || _workerProfile == null) {
      _showMessage(
        'Profile information could not be loaded.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ----------------------------------------------------------
      // 1. Update user_profile
      // ----------------------------------------------------------

      final updatedUser = _userProfile!.copyWith(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final userUpdated =
          await UserProfileService.updateProfile(updatedUser);

      if (userUpdated == null) {
        throw Exception(
          'Could not update personal information.',
        );
      }

      // ----------------------------------------------------------
      // 2. Update worker_profile
      // ----------------------------------------------------------

      final workerUpdated =
          await WorkerProfileService.updateWorkerDetails(
        workerId: _workerProfile!.id,
        emergencyContactName:
            _emergencyNameController.text.trim(),
        emergencyContactPhone:
            _emergencyPhoneController.text.trim(),
        serviceArea:
            _serviceAreaController.text.trim(),
        workingArea:
            _workingAreaController.text.trim(),
      );

      if (!workerUpdated) {
        throw Exception(
          'Could not update worker information.',
        );
      }

      // ----------------------------------------------------------
      // 3. Update worker skills
      // ----------------------------------------------------------

      final skillsUpdated =
          await WorkerProfileService.updateWorkerSkills(
        workerId: _workerProfile!.id,
        skills: _skills,
      );

      if (!skillsUpdated) {
        throw Exception(
          'Could not update skills.',
        );
      }

      // ----------------------------------------------------------
      // 4. Refresh data from Supabase
      // ----------------------------------------------------------

      final refreshedUser =
          await UserProfileService.getProfile(
        _userProfile!.id,
      );

      final refreshedWorker =
          await WorkerProfileService.getWorkerByUserId(
        _workerProfile!.userId,
      );

      // ----------------------------------------------------------
      // 5. Update AppState
      // ----------------------------------------------------------

      if (refreshedUser != null) {
        AppState.currentUserProfile.value =
            refreshedUser;
      }

      if (refreshedWorker != null) {
        AppState.currentWorkerProfile.value =
            refreshedWorker;
      }

      if (!mounted) return;

      _showMessage(
        'Profile updated successfully!',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to save profile: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: requiredField
            ? (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    requiredField: true,
                  ),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType:
                        TextInputType.emailAddress,
                    requiredField: true,
                  ),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType:
                        TextInputType.phone,
                    requiredField: true,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Emergency Contact',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller:
                        _emergencyNameController,
                    label: 'Emergency Contact Name',
                    icon:
                        Icons.contact_phone_outlined,
                  ),

                  _buildTextField(
                    controller:
                        _emergencyPhoneController,
                    label: 'Emergency Contact Phone',
                    icon:
                        Icons.phone_callback_outlined,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Work Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller:
                        _serviceAreaController,
                    label: 'Service Area',
                    icon: Icons.build_outlined,
                    hint:
                        'Example: Plumbing, Electrical',
                  ),

                  _buildTextField(
                    controller:
                        _workingAreaController,
                    label: 'Working Area',
                    icon:
                        Icons.location_on_outlined,
                    hint:
                        'Example: Panaji, Mapusa',
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Skills',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillController,
                          decoration:
                              InputDecoration(
                            labelText: 'Add a skill',
                            hintText:
                                'Example: Pipe fitting',
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          onSubmitted: (_) =>
                              _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _addSkill,
                        icon: const Icon(
                          Icons.add_circle,
                          size: 36,
                        ),
                        tooltip: 'Add skill',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (_skills.isEmpty)
                    const Text(
                      'No skills added yet.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                  if (_skills.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.map(
                        (skill) {
                          return Chip(
                            label: Text(skill),
                            deleteIcon:
                                const Icon(
                              Icons.close,
                              size: 18,
                            ),
                            onDeleted: () =>
                                _removeSkill(skill),
                          );
                        },
                      ).toList(),
                    ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          _isSaving
                              ? null
                              : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SAVE CHANGES',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}