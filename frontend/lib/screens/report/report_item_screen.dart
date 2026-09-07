import 'package:flutter/material.dart';

class ReportItemScreen extends StatefulWidget {
  const ReportItemScreen({super.key});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  bool isLost = true;

  final itemNameController = TextEditingController();
  final locationController = TextEditingController();
  final publicDetailsController = TextEditingController();
  final privateDetailsController = TextEditingController();

  String selectedCategory = 'Electronics';
  String selectedDate = 'Select date';
  String selectedTime = 'Select approximate time';

  final categories = [
    'Electronics',
    'Books',
    'ID / Cards',
    'Clothing',
    'Accessories',
    'Stationery',
    'Other',
  ];

  @override
  void dispose() {
    itemNameController.dispose();
    locationController.dispose();
    publicDetailsController.dispose();
    privateDetailsController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 22 : 70,
              vertical: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BACK BUTTON
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),

                const SizedBox(height: 25),

                // HEADER
                const Text(
                  'Report an Item',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171A2B),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Tell us about the item so ReFind can help connect it '
                  'with its possible owner.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFF686B78),
                  ),
                ),

                const SizedBox(height: 35),

                // LOST / FOUND
                const Text(
                  'What happened?',
                  style: _sectionTitleStyle,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _choiceButton(
                        title: 'I Lost It',
                        icon: Icons.search_rounded,
                        selected: isLost,
                        onTap: () {
                          setState(() => isLost = true);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _choiceButton(
                        title: 'I Found It',
                        icon: Icons.volunteer_activism_rounded,
                        selected: !isLost,
                        onTap: () {
                          setState(() => isLost = false);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // BASIC INFORMATION CARD
                _sectionCard(
                  title: 'Basic Information',
                  icon: Icons.inventory_2_outlined,
                  child: Column(
                    children: [
                      _textField(
                        controller: itemNameController,
                        label: 'Item name',
                        hint: 'e.g. Black Samsung Galaxy phone',
                      ),

                      const SizedBox(height: 18),

                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: _inputDecoration('Category'),
                        items: categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      _textField(
                        controller: locationController,
                        label: 'Location',
                        hint: 'e.g. Library, Block A',
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: _dateButton(
                              icon: Icons.calendar_today_outlined,
                              text: selectedDate,
                              onTap: pickDate,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _dateButton(
                              icon: Icons.access_time_rounded,
                              text: selectedTime,
                              onTap: () {
                                setState(() {
                                  selectedTime = 'Morning / Afternoon / Evening';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // PHOTO
                _sectionCard(
                  title: 'Photo',
                  icon: Icons.photo_camera_outlined,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 35),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFDCDDE6),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 42,
                          color: Color(0xFF6C4EFF),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Add a photo of the item',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'A clear photo can help with matching.',
                          style: TextStyle(
                            color: Color(0xFF686B78),
                          ),
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Photo upload will be connected later.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Choose Photo'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // PUBLIC DETAILS
                _sectionCard(
                  title: 'Public Details 🌐',
                  icon: Icons.public_rounded,
                  subtitle:
                      'Information that can be safely shown to other users.',
                  child: _textField(
                    controller: publicDetailsController,
                    label: 'What others can see',
                    hint:
                        'Add general details about the item without revealing unique identifiers.',
                    maxLines: 5,
                  ),
                ),

                const SizedBox(height: 24),

                // PRIVATE DETAILS
                _sectionCard(
                  title: 'Private Details 🔒',
                  icon: Icons.lock_outline_rounded,
                  subtitle:
                      'Details kept private and used to help verify ownership.',
                  child: Column(
                    children: [
                      _textField(
                        controller: privateDetailsController,
                        label: 'Ownership verification details',
                        hint:
                            'Colour, specific design, stickers, scratches, '
                            'engravings, unique marks, or other identifying details.',
                        maxLines: 6,
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEBFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: Color(0xFF6C4EFF),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Keep unique details here. These details '
                                'will not be displayed publicly and can '
                                'help verify who actually owns the item.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: Color(0xFF4D4968),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // SUBMIT
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Report saved locally for now. Backend connection comes later.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Submit Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF171A2B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 19),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _choiceButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF171A2B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF171A2B)
                : const Color(0xFFDCDDE6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF171A2B),
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF171A2B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E9F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF6C4EFF),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171A2B),
                ),
              ),
            ],
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF686B78),
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label).copyWith(
        hintText: hint,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9F9FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDCDDE6),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFDCDDE6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF6C4EFF),
          width: 2,
        ),
      ),
    );
  }

  Widget _dateButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFDCDDE6),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF6C4EFF),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF686B78),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _sectionTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w800,
  color: Color(0xFF171A2B),
);