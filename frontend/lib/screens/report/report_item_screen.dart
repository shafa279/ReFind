import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ReportItemScreen extends StatefulWidget {
  final bool initialIsLost;

  const ReportItemScreen({
    super.key,
    this.initialIsLost = true,
  });

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  late bool _isLost;
  bool _isSubmitting = false;

  final TextEditingController _itemNameController =
      TextEditingController();

  final TextEditingController _locationController =
      TextEditingController();

  final TextEditingController _publicDetailsController =
      TextEditingController();

  final TextEditingController _privateDetailsController =
      TextEditingController();

  String _selectedCategory = 'Electronics';
  String _selectedDate = 'Select date';
  String _selectedTime = 'Morning';

  Uint8List? _selectedImage;
  String? _selectedImageName;

  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    'Electronics',
    'Books',
    'ID / Cards',
    'Clothing',
    'Accessories',
    'Stationery',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _isLost = widget.initialIsLost;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _locationController.dispose();
    _publicDetailsController.dispose();
    _privateDetailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate =
            '${pickedDate.day} ${_monthName(pickedDate.month)} ${pickedDate.year}';
      });
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  Future<void> _choosePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final Uint8List imageBytes = await pickedFile.readAsBytes();

      setState(() {
        _selectedImage = imageBytes;
        _selectedImageName = pickedFile.name;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not select the photo. Please try again.',
          ),
        ),
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
      _selectedImageName = null;
    });
  }

  Future<void> _submitReport() async {
    // Check required fields
    if (_itemNameController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedDate == 'Select date') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in the item name, location, and date.',
          ),
        ),
      );
      return;
    }

    // Make sure a user is logged in
    if (AuthService.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in before submitting a report.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await ApiService.submitReport(
      userId: AuthService.userId!,
      itemType: _isLost ? 'Lost' : 'Found',
      itemName: _itemNameController.text.trim(),
      category: _selectedCategory,
      location: _locationController.text.trim(),
      date: _selectedDate,
      time: _selectedTime,
      publicDetails: _publicDetailsController.text.trim(),
      privateDetails: _privateDetailsController.text.trim(),
      imageName: _selectedImageName,
      imageBytes: _selectedImage,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Report submitted successfully!',
          ),
        ),
      );

      // Return to the previous screen after successful submission
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Could not submit report.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF171A2B),
          ),
        ),
        title: const Text(
          'Report an Item',
          style: TextStyle(
            color: Color(0xFF171A2B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 70,
          vertical: 30,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 850,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tell us what happened.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171A2B),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Provide as much useful information as you can.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF686B78),
                  ),
                ),

                const SizedBox(height: 30),

                // LOST / FOUND SELECTOR
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEEF4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLost = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: _isLost
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'I Lost Something',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _isLost
                                    ? const Color(0xFF171A2B)
                                    : const Color(0xFF686B78),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLost = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: !_isLost
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'I Found Something',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: !_isLost
                                    ? const Color(0xFF171A2B)
                                    : const Color(0xFF686B78),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const _SectionTitle(
                  title: 'Basic Information',
                  icon: Icons.info_outline_rounded,
                ),

                const SizedBox(height: 15),

                const _InputLabel(label: 'Item Name'),

                const SizedBox(height: 8),

                TextField(
                  controller: _itemNameController,
                  decoration: _inputDecoration(
                    hint: 'e.g. Black wireless headphones',
                  ),
                ),

                const SizedBox(height: 20),

                const _InputLabel(label: 'Category'),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: _inputDecoration(),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                const _InputLabel(label: 'Location'),

                const SizedBox(height: 8),

                TextField(
                  controller: _locationController,
                  decoration: _inputDecoration(
                    hint: 'e.g. Central Library',
                  ),
                ),

                const SizedBox(height: 20),

                const _InputLabel(label: 'Date'),

                const SizedBox(height: 8),

                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                      ),
                    ),
                    child: Text(
                      _selectedDate,
                      style: TextStyle(
                        color: _selectedDate == 'Select date'
                            ? const Color(0xFF9A9CA8)
                            : const Color(0xFF171A2B),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const _InputLabel(label: 'Approximate Time'),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: _selectedTime,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: 'Morning',
                      child: Text('Morning'),
                    ),
                    DropdownMenuItem(
                      value: 'Afternoon',
                      child: Text('Afternoon'),
                    ),
                    DropdownMenuItem(
                      value: 'Evening',
                      child: Text('Evening'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTime = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 25),

                // PHOTO
                const _SectionTitle(
                  title: 'Photo',
                  icon: Icons.photo_outlined,
                ),

                const SizedBox(height: 15),

                if (_selectedImage == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE8E9F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: Color(0xFF6C4EFF),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Add a photo of the item',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF171A2B),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Choose an image from your computer.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8A8D99),
                          ),
                        ),

                        const SizedBox(height: 18),

                        OutlinedButton.icon(
                          onPressed: _choosePhoto,
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                          ),
                          label: const Text('Choose Photo'),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE8E9F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _selectedImage!,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 20,
                              color: Color(0xFF686B78),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                _selectedImageName ?? 'Selected photo',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF686B78),
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: _choosePhoto,
                              child: const Text('Change'),
                            ),

                            TextButton(
                              onPressed: _removePhoto,
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // PUBLIC DETAILS
                const _SectionTitle(
                  title: 'Public Details 🌐',
                  icon: Icons.public_rounded,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Information that can be safely shown to other users.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF686B78),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: _publicDetailsController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    hint:
                        'Describe information that is safe to show publicly.',
                  ),
                ),

                const SizedBox(height: 30),

                // PRIVATE DETAILS
                const _SectionTitle(
                  title: 'Private Details 🔒',
                  icon: Icons.lock_outline_rounded,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Details kept private and used to help verify ownership.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF686B78),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: _privateDetailsController,
                  maxLines: 5,
                  decoration: _inputDecoration(
                    hint:
                        'Colour, stickers, scratches, engravings, unique marks, etc.',
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF8A6A00),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Private details will not be displayed publicly. '
                          'They are intended to help verify ownership.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF6B5700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171A2B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isLost
                                ? 'Submit Lost Report'
                                : 'Submit Found Report',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE8E9F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE8E9F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF6C4EFF),
          width: 1.5,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF6C4EFF),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF171A2B),
          ),
        ),
      ],
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;

  const _InputLabel({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF171A2B),
      ),
    );
  }
}