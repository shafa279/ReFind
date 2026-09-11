import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

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

  final TextEditingController _itemNameController =
      TextEditingController();

  final TextEditingController _locationController =
      TextEditingController();

  final TextEditingController _lostDescriptionController =
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

  bool _isSubmitting = false;

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
    _lostDescriptionController.dispose();
    _publicDetailsController.dispose();
    _privateDetailsController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2020),
      lastDate: today,
      helpText: 'Select report date',
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate =
          '${pickedDate.day} ${_monthName(pickedDate.month)} ${pickedDate.year}';
    });
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

  // ============================================================
  // PHOTO
  // ============================================================

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

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImage = imageBytes;
        _selectedImageName = pickedFile.name;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

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

  // ============================================================
  // SUBMIT REPORT
  // ============================================================

  Future<void> _submitReport() async {
    if (_isSubmitting) {
      return;
    }

    final String? userId = AuthService.userId;

    if (userId == null || userId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in before submitting a report.',
          ),
        ),
      );

      return;
    }

    // Validate fields common to both Lost and Found reports.
    final bool commonFieldsMissing =
        _itemNameController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedDate == 'Select date';

    // Lost reports use ONE description.
    final bool lostDescriptionMissing =
        _isLost &&
        _lostDescriptionController.text.trim().isEmpty;

    // Found reports keep their existing public/private details.
    final bool foundDetailsMissing =
        !_isLost &&
        (_publicDetailsController.text.trim().isEmpty ||
            _privateDetailsController.text.trim().isEmpty);

    if (commonFieldsMissing ||
        lostDescriptionMissing ||
        foundDetailsMissing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required fields before submitting.',
          ),
        ),
      );

      return;
    }

    // Defensive date validation.
    if (!_isValidReportDate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report date cannot be in the future.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // For Lost reports, the single description is sent as
      // the public description. Private details remain empty.
      //
      // For Found reports, the existing public/private fields
      // are sent exactly as before.
      final String publicDetails = _isLost
          ? _lostDescriptionController.text.trim()
          : _publicDetailsController.text.trim();

      final String privateDetails = _isLost
          ? ''
          : _privateDetailsController.text.trim();

      final Map<String, dynamic> result =
          await ApiService.submitReport(
        userId: userId,
        itemType: _isLost ? 'Lost' : 'Found',
        itemName: _itemNameController.text.trim(),
        category: _selectedCategory,
        location: _locationController.text.trim(),
        date: _selectedDate,
        time: _selectedTime,
        publicDetails: publicDetails,
        privateDetails: privateDetails,
        imageName: _selectedImageName,
        imageBytes: _selectedImage,
      );

      if (!mounted) {
        return;
      }

      if (result['success'] == true) {
        _itemNameController.clear();
        _locationController.clear();
        _lostDescriptionController.clear();
        _publicDetailsController.clear();
        _privateDetailsController.clear();

        setState(() {
          _selectedCategory = 'Electronics';
          _selectedDate = 'Select date';
          _selectedTime = 'Morning';

          _selectedImage = null;
          _selectedImageName = null;

          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLost
                  ? 'Lost report submitted successfully.'
                  : 'Found report submitted successfully.',
            ),
          ),
        );
      } else {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Report submission failed.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not submit report: $e',
          ),
        ),
      );
    }
  }

  bool _isValidReportDate() {
    if (_selectedDate == 'Select date') {
      return false;
    }

    try {
      final parts = _selectedDate.split(' ');

      if (parts.length != 3) {
        return false;
      }

      final int day = int.parse(parts[0]);
      final int year = int.parse(parts[2]);

      const months = {
        'January': 1,
        'February': 2,
        'March': 3,
        'April': 4,
        'May': 5,
        'June': 6,
        'July': 7,
        'August': 8,
        'September': 9,
        'October': 10,
        'November': 11,
        'December': 12,
      };

      final int? month = months[parts[1]];

      if (month == null) {
        return false;
      }

      final DateTime selectedDate = DateTime(
        year,
        month,
        day,
      );

      final DateTime today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      return !selectedDate.isAfter(today);
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.of(context).size.width;

    final bool isMobile = screenWidth < 800;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, isMobile),

            Expanded(
              child: SingleChildScrollView(
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildIntro(
                          context,
                          isMobile,
                        ),

                        const SizedBox(height: 28),

                        _buildLostFoundSelector(),

                        const SizedBox(height: 30),

                        _buildBasicInformation(),

                        const SizedBox(height: 30),

                        _buildPhotoSection(),

                        const SizedBox(height: 30),

                        // Lost -> single Description
                        // Found -> existing Public + Private Details
                        if (_isLost)
                          _buildLostDescription()
                        else
                          _buildFoundDetails(),

                        const SizedBox(height: 35),

                        PrimaryButton(
                          text: _isSubmitting
                              ? 'Submitting...'
                              : (_isLost
                                  ? 'Submit Lost Report'
                                  : 'Submit Found Report'),
                          icon: _isSubmitting
                              ? Icons.hourglass_top_rounded
                              : Icons.send_rounded,
                          fullWidth: true,
                          onPressed: () {
                            if (!_isSubmitting) {
                              _submitReport();
                            }
                          },
                        ),

                        const SizedBox(height: 45),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(
    BuildContext context,
    bool isMobile,
  ) {
    return Container(
      height: isMobile ? 64 : 72,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 40,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8E9F0),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF171A2B),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Report an Item',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171A2B),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntro(
    BuildContext context,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us what happened.',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(
                fontSize: isMobile ? 30 : 36,
              ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Provide as much useful information as you can. '
          'Private details help us verify ownership later.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF686B78),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOST / FOUND
  // ============================================================

  Widget _buildLostFoundSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: _typeButton(
              label: 'I Lost Something',
              icon: Icons.search_rounded,
              selected: _isLost,
              onTap: () {
                setState(() {
                  _isLost = true;
                });
              },
            ),
          ),

          Expanded(
            child: _typeButton(
              label: 'I Found Something',
              icon: Icons.inventory_2_outlined,
              selected: !_isLost,
              onTap: () {
                setState(() {
                  _isLost = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(11),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? const Color(0xFF6C4EFF)
                  : const Color(0xFF686B78),
            ),

            const SizedBox(width: 8),

            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? const Color(0xFF171A2B)
                      : const Color(0xFF686B78),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  Widget _buildBasicInformation() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Basic Information',
            icon: Icons.info_outline_rounded,
            subtitle:
                'Tell us the basic public information about the item.',
          ),

          const SizedBox(height: 24),

          const _InputLabel(
            label: 'Item Name *',
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _itemNameController,
            decoration: _inputDecoration(
              hint:
                  'e.g. Black wireless headphones',
            ),
          ),

          const SizedBox(height: 20),

          const _InputLabel(
            label: 'Category *',
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: _inputDecoration(),
            items: _categories.map(
              (category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),

          const SizedBox(height: 20),

          const _InputLabel(
            label: 'Location *',
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _locationController,
            decoration: _inputDecoration(
              hint: 'e.g. Central Library',
            ),
          ),

          const SizedBox(height: 20),

          const _InputLabel(
            label: 'Date *',
          ),

          const SizedBox(height: 8),

          InkWell(
            onTap: _selectDate,
            borderRadius:
                BorderRadius.circular(12),
            child: InputDecorator(
              decoration: _inputDecoration(
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                ),
              ),
              child: Text(
                _selectedDate,
                style: TextStyle(
                  color: _selectedDate ==
                          'Select date'
                      ? const Color(0xFF9A9CA8)
                      : const Color(0xFF171A2B),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Report dates can be today or any date in the past.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8A8D99),
            ),
          ),

          const SizedBox(height: 20),

          const _InputLabel(
            label: 'Approximate Time',
          ),

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
        ],
      ),
    );
  }

  // ============================================================
  // PHOTO SECTION
  // ============================================================

  Widget _buildPhotoSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Photo',
            icon: Icons.photo_outlined,
            subtitle:
                'A photo can make matching easier.',
          ),

          const SizedBox(height: 20),

          if (_selectedImage == null)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFF9F9FC),
                borderRadius:
                    BorderRadius.circular(15),
                border: Border.all(
                  color:
                      const Color(0xFFE8E9F0),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFFF0EBFF),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons
                          .cloud_upload_outlined,
                      size: 29,
                      color:
                          Color(0xFF6C4EFF),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Add a photo of the item',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF171A2B),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Choose an image from your computer.',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          Color(0xFF8A8D99),
                    ),
                  ),

                  const SizedBox(height: 18),

                  OutlinedButton.icon(
                    onPressed: _choosePhoto,
                    icon: const Icon(
                      Icons
                          .add_photo_alternate_outlined,
                    ),
                    label: const Text(
                      'Choose Photo',
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFF9F9FC),
                borderRadius:
                    BorderRadius.circular(15),
                border: Border.all(
                  color:
                      const Color(0xFFE8E9F0),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12),
                    child: Image.memory(
                      _selectedImage!,
                      width:
                          double.infinity,
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
                        color:
                            Color(0xFF686B78),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          _selectedImageName ??
                              'Selected photo',
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 13,
                            color:
                                Color(0xFF686B78),
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed:
                            _choosePhoto,
                        child: const Text(
                          'Change',
                        ),
                      ),

                      TextButton(
                        onPressed:
                            _removePhoto,
                        child: const Text(
                          'Remove',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // LOST DESCRIPTION
  // ============================================================

  Widget _buildLostDescription() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Description',
            icon: Icons.description_outlined,
            subtitle:
                'Describe the lost item in as much useful detail as possible.',
          ),

          const SizedBox(height: 20),

          const _InputLabel(
            label: 'Description *',
          ),

          const SizedBox(height: 8),

          TextField(
            controller:
                _lostDescriptionController,
            maxLines: 7,
            decoration: _inputDecoration(
              hint:
                  'Describe the item, where you lost it, its appearance, unique marks, stickers, scratches, or any other useful details.',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOUND DETAILS
  // ============================================================

  Widget _buildFoundDetails() {
    return Column(
      children: [
        _buildPublicDetails(),

        const SizedBox(height: 30),

        _buildPrivateDetails(),
      ],
    );
  }

  // ============================================================
  // PUBLIC DETAILS
  // ============================================================

  Widget _buildPublicDetails() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Public Details 🌐',
            icon: Icons.public_rounded,
            subtitle:
                'Information that can be safely shown to other users.',
          ),

          const SizedBox(height: 20),

          TextField(
            controller:
                _publicDetailsController,
            maxLines: 4,
            decoration: _inputDecoration(
              hint:
                  'Describe information that is safe to show publicly.',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIVATE DETAILS
  // ============================================================

  Widget _buildPrivateDetails() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Private Details 🔒',
            icon:
                Icons.lock_outline_rounded,
            subtitle:
                'Details kept private and used to help verify ownership.',
          ),

          const SizedBox(height: 20),

          TextField(
            controller:
                _privateDetailsController,
            maxLines: 5,
            decoration: _inputDecoration(
              hint:
                  'Colour, stickers, scratches, engravings, unique marks, etc.',
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFFFF8E7),
              borderRadius:
                  BorderRadius.circular(13),
              border: Border.all(
                color:
                    const Color(0xFFF0DFAB),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color:
                      Color(0xFF8A6A00),
                ),

                SizedBox(width: 11),

                Expanded(
                  child: Text(
                    'Private details will never be displayed publicly. '
                    'They are only used to help verify ownership.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color:
                          Color(0xFF6B5700),
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

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFE8E9F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
    );
  }
}

// ================================================================
// INPUT LABEL
// ================================================================

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