import 'package:flutter/material.dart';

import '../../../auth/domain/entities/auth_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});

  final AuthUser user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _dobCtrl;
  String _selectedGender = 'Male';
  String _selectedHeight = '5.0 ft';
  String _selectedWeight = '60 kg';

  static const _genders = ['Male', 'Female', 'Other'];
  static const _heights = [
    '4.6 ft',
    '4.8 ft',
    '5.0 ft',
    '5.2 ft',
    '5.4 ft',
    '5.6 ft',
    '5.8 ft',
    '6.0 ft',
    '6.2 ft',
  ];
  static const _weights = [
    '45 kg',
    '50 kg',
    '55 kg',
    '60 kg',
    '65 kg',
    '70 kg',
    '75 kg',
    '80 kg',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _dobCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _ProfileField(
                label: 'DOB',
                controller: _dobCtrl,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Gender', _genders, _selectedGender,
                      (value) => setState(() => _selectedGender = value))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown('Height', _heights, _selectedHeight,
                      (value) => setState(() => _selectedHeight = value))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Weight', _weights, _selectedWeight,
                      (value) => setState(() => _selectedWeight = value))),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DD06C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1DD06C),
              onPrimary: Colors.black,
              surface: Color(0xFF111111),
              onSurface: Colors.white,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      _dobCtrl.text = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
    }
  }

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
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
