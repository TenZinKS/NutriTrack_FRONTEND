import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/auth_user.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});

  final AuthUser user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  String _selectedGender = 'Male';
  bool _seededProfile = false;

  static const _genders = ['Male', 'Female', 'Other'];
  static const _defaultHeightCm = 170;
  static const _defaultWeightKg = 60;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _heightCtrl = TextEditingController(text: _defaultHeightCm.toString());
    _weightCtrl = TextEditingController(text: _defaultWeightKg.toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        getUserProfileUsecase: sl(),
        updateUserProfileUsecase: sl(),
      )..loadProfile(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
          if (state.status == ProfileStatus.ready && !_seededProfile) {
            final profile = state.profile;
            if (profile != null) {
              final gender = _genders.contains(profile.gender) ? profile.gender : _genders.first;
              final heightValue = profile.heightCm > 0 ? profile.heightCm : _defaultHeightCm;
              final weightValue = profile.weightKg > 0 ? profile.weightKg : _defaultWeightKg;
              if (!mounted) return;
              setState(() {
                _nameCtrl.text = profile.name.isNotEmpty ? profile.name : widget.user.name;
                _emailCtrl.text = profile.email.isNotEmpty ? profile.email : widget.user.email;
                _selectedGender = gender;
                _heightCtrl.text = heightValue.toStringAsFixed(0);
                _weightCtrl.text = weightValue.toStringAsFixed(0);
                _seededProfile = true;
              });
            } else {
              _seededProfile = true;
            }
          }
          if (state.status == ProfileStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile saved')),
            );
          }
        },
        builder: (context, state) {
          final isSaving = state.status == ProfileStatus.submitting;
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildAvatar(),
                    const SizedBox(height: 24),
                    _ProfileField(
                      label: 'Name',
                      controller: _nameCtrl,
                    ),
                    const SizedBox(height: 16),
                    _ProfileField(
                      label: 'Email',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            'Gender',
                            _genders,
                            _selectedGender,
                            (value) => setState(() => _selectedGender = value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ProfileField(
                            label: 'Height (cm)',
                            controller: _heightCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileField(
                            label: 'Weight (kg)',
                            controller: _weightCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : () => _onSave(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DD06C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: Text(
                          isSaving ? 'Saving...' : 'Save',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: const Color(0xFF1DD06C),
        backgroundImage: widget.user.photoUrl != null ? NetworkImage(widget.user.photoUrl!) : null,
        child: widget.user.photoUrl == null
            ? Text(
                _initials(widget.user.name.isNotEmpty ? widget.user.name : widget.user.email),
                style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
              )
            : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              dropdownColor: const Color(0xFF111111),
              iconEnabledColor: Colors.white70,
              items: options
                  .map((option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onSave(BuildContext context) {
    final heightCm = _parseMetricValue(_heightCtrl.text);
    final weightKg = _parseMetricValue(_weightCtrl.text);

    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gender: _selectedGender,
      heightCm: heightCm,
      weightKg: weightKg,
    );

    context.read<ProfileCubit>().save(profile);
  }

  double _parseMetricValue(String input) {
    return double.tryParse(input.trim()) ?? 0;
  }

  String _initials(String input) {
    final parts = input.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF111111),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1DD06C), width: 2),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
