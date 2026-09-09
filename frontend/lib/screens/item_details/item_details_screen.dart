import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

class ItemDetailsScreen extends StatefulWidget {
  final int itemId;

  const ItemDetailsScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<ItemDetailsScreen> createState() =>
      _ItemDetailsScreenState();
}

class _ItemDetailsScreenState
    extends State<ItemDetailsScreen> {
  bool _isLoading = true;
  bool _isClaiming = false;

  Map<String, dynamic>? _item;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    try {
      final item = await ApiService.getItem(widget.itemId);

      if (!mounted) {
        return;
      }

      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _claimItem() async {
    final claimantId = AuthService.userId;

    if (claimantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please log in before claiming an item.',
          ),
        ),
      );
      return;
    }

    if (_item == null) {
      return;
    }

    final reporterId =
        _item!['reporter_id']?.toString();

    if (reporterId == null || reporterId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to identify the item reporter.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isClaiming = true;
    });

    final result = await ApiService.createClaim(
      itemId: widget.itemId,
      claimantId: claimantId,
      reporterId: reporterId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isClaiming = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ??
              'Claim request submitted.',
        ),
      ),
    );

    if (result['success'] == true) {
      await _loadItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 22 : 70,
            vertical: 28,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 500,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _item == null
                  ? _buildError()
                  : _buildContent(isMobile),
        ),
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    final item = _item!;

    final itemName =
        item['item_name']?.toString() ??
            'Unknown item';

    final category =
        item['category']?.toString() ??
            'Unknown category';

    final location =
        item['location']?.toString() ??
            'Unknown location';

    final date =
        item['date']?.toString() ??
            'Unknown date';

    final time =
        item['time']?.toString() ??
            'Unknown time';

    final publicDetails =
        item['public_details']?.toString() ??
            'No public details available.';

    final status =
        item['status']?.toString() ??
            'Searching';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          label: const Text('Back'),
        ),

        const SizedBox(height: 25),

        Text(
          'Item Details',
          style: Theme.of(context)
              .textTheme
              .headlineLarge,
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE8E9F0),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: isMobile ? 220 : 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F1F6),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 55,
                    color: Color(0xFF9A9CAB),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                itemName,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF171A2B),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF686B78),
                ),
              ),

              const SizedBox(height: 25),

              _DetailRow(
                icon: Icons.location_on_outlined,
                title: 'Location',
                value: location,
              ),

              const SizedBox(height: 15),

              _DetailRow(
                icon: Icons.calendar_today_outlined,
                title: 'Date',
                value: date,
              ),

              const SizedBox(height: 15),

              _DetailRow(
                icon: Icons.access_time_outlined,
                title: 'Approximate Time',
                value: time,
              ),

              const SizedBox(height: 15),

              _DetailRow(
                icon: Icons.info_outline_rounded,
                title: 'Status',
                value: status,
              ),

              const SizedBox(height: 25),

              const SectionHeader(
                title: 'Public Details',
                icon: Icons.public_rounded,
                subtitle:
                    'Information that can be safely shown to other users.',
              ),

              const SizedBox(height: 12),

              Text(
                publicDetails,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF686B78),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEBFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF6C4EFF),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Potential Match',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF302A55),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              Text(
                'ReFind identified this item as a possible match based on the information provided in the reports.',
                style: TextStyle(
                  color: Color(0xFF4D4968),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 12),

              Text(
                'Potential match, not proof of ownership.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4D4968),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE8E9F0),
            ),
          ),
          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF6C4EFF),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Private identifying details are kept hidden and are only used during ownership verification.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF686B78),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: _isClaiming
                ? 'Submitting Claim...'
                : 'Claim This Item',
            icon: Icons.assignment_turned_in_outlined,
            fullWidth: true,
            onPressed: () {
              if (!_isClaiming) {
                _claimItem();
              }
            },
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 500,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Color(0xFF686B78),
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load item details.',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });

                _loadItem();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF686B78),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    color: Color(0xFF171A2B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Color(0xFF686B78),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}