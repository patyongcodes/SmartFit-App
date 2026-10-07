import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/ai_coach/plan_generator.dart';
import '../../data/ai_coach/ai_coach_storage.dart';

class BodyScannerScreen extends StatefulWidget {
  const BodyScannerScreen({super.key});

  @override
  State<BodyScannerScreen> createState() => _BodyScannerScreenState();
}

class _BodyScannerScreenState extends State<BodyScannerScreen> {
  final _picker = ImagePicker();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _timelineController = TextEditingController();
  final _planGenerator = PlanGenerator();

  Uint8List? _imageBytes;
  bool? _isMale;
  final Set<String> _selectedMuscles = {};
  bool _isLoading = false;
  String? _errorText;

  static const _muscleOptions = ['Biceps', 'Chest', 'Shoulders', 'Back'];

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _errorText = null;
    });
  }

  void _showImageSourceSheet() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
                title: Text('Take Photo', style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: colorScheme.primary),
                title: Text('Choose from Gallery', style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleGenerate() async {
    if (_imageBytes == null) {
      setState(() => _errorText = 'Please upload a full-body photo');
      return;
    }
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      setState(() => _errorText = 'Please enter a valid weight in kg');
      return;
    }
    final height = double.tryParse(_heightController.text.trim());
    if (height == null || height <= 0) {
      setState(() => _errorText = 'Please enter a valid height in cm');
      return;
    }
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age <= 0) {
      setState(() => _errorText = 'Please enter a valid age');
      return;
    }
    if (_isMale == null) {
      setState(() => _errorText = 'Please select a biological sex (used for the body composition formula)');
      return;
    }
    if (_selectedMuscles.isEmpty) {
      setState(() => _errorText = 'Please select at least one target muscle group');
      return;
    }
    final months = int.tryParse(_timelineController.text.trim());
    if (months == null || months <= 0) {
      setState(() => _errorText = 'Please enter a valid timeline in months');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final result = await _planGenerator.generatePlan(
        targetMuscles: _selectedMuscles.toList(),
        timelineMonths: months,
        weightKg: weight,
        heightCm: height,
        age: age,
        isMale: _isMale!,
      );

      await AiCoachStorage.savePlan(result);
      if (!mounted) return;
      context.push('/plan-result', extra: result);
    } catch (e) {
      debugPrint('=== PLAN GENERATION ERROR ===');
      debugPrint(e.toString());
      debugPrint('==============================');
      if (!mounted) return;
      setState(() => _errorText = 'Something went wrong generating your plan. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Body Scanner')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Body Assessment',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload a full-body photo to get a personalized plan',
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.65)),
              ),
              const SizedBox(height: 20),
              _buildImagePicker(context),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildLabeledField(context, 'Weight (kg)', _weightController, 'e.g. 65')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLabeledField(context, 'Height (cm)', _heightController, 'e.g. 170')),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildLabeledField(context, 'Age', _ageController, 'e.g. 25')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSexSelector(context)),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'What do you want to build?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Select one or more',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.65)),
              ),
              const SizedBox(height: 12),
              _buildMuscleChips(context),
              const SizedBox(height: 24),
              _buildLabeledField(context, 'Target timeline (months)', _timelineController, 'e.g. 3'),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(_errorText!, style: TextStyle(fontSize: 13, color: colorScheme.error)),
              ],
              const SizedBox(height: 32),
              _buildGenerateButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imageBytes != null
            ? Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: colorScheme.onSurface.withValues(alpha: 0.65)),
                  const SizedBox(height: 10),
                  Text('Upload', style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.65))),
                ],
              ),
      ),
    );
  }

  Widget _buildSexSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sex', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSexChip(context, 'Male', true)),
            const SizedBox(width: 8),
            Expanded(child: _buildSexChip(context, 'Female', false)),
          ],
        ),
      ],
    );
  }

  Widget _buildSexChip(BuildContext context, String label, bool value) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _isMale == value;

    return GestureDetector(
      onTap: () => setState(() => _isMale = value),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _muscleOptions.map((muscle) {
        final isSelected = _selectedMuscles.contains(muscle);
        return FilterChip(
          label: Text(muscle),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedMuscles.add(muscle);
              } else {
                _selectedMuscles.remove(muscle);
              }
            });
          },
          selectedColor: colorScheme.primary,
          backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          checkmarkColor: colorScheme.onPrimary,
          labelStyle: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.2),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }

  Widget _buildLabeledField(
    BuildContext context,
    String label,
    TextEditingController controller,
    String hint,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleGenerate,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2.5),
              )
            : Text(
                'Generate Plan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
              ),
      ),
    );
  }
}