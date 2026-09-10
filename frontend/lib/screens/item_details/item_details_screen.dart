import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';

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

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  bool _isLoading = true;
  bool _isClaiming = false;
  bool _isLoadingClaims = false;
  bool _isReviewing = false;

  Map<String, dynamic>? _item;
  List<dynamic> _claims = [];

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  // =========================================================
  // LOAD ITEM
  // =========================================================

  Future<void> _loadItem() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final item = await ApiService.getItem(widget.itemId);

    if (!mounted) return;

    setState(() {
      _item = item;
      _isLoading = false;
    });

    if (item != null && _isReporter()) {
      await _loadClaims();
    }
  }

  // =========================================================
  // CHECK REPORTER
  // =========================================================

  bool _isReporter() {
    final currentUser = AuthService.userId;
    final reporterId =
        _item?['reporter_id']?.toString();

    if (currentUser == null ||
        reporterId == null ||
        reporterId.isEmpty) {
      return false;
    }

    return currentUser == reporterId;
  }

  // =========================================================
  // LOAD CLAIMS
  // =========================================================

  Future<void> _loadClaims() async {
    if (!mounted) return;

    setState(() {
      _isLoadingClaims = true;
    });

    final claims =
        await ApiService.getClaims(widget.itemId);

    if (!mounted) return;

    setState(() {
      _claims = claims;
      _isLoadingClaims = false;
    });
  }

  // =========================================================
  // GET CURRENT USER'S PENDING CLAIM
  // =========================================================

  Future<Map<String, dynamic>?> _getMyPendingClaim() async {
    final userId = AuthService.userId;

    if (userId == null) {
      return null;
    }

    final claims =
        await ApiService.getClaims(widget.itemId);

    for (final claim in claims) {
      final claimMap =
          Map<String, dynamic>.from(claim);

      final claimantId =
          claimMap['claimant_id']?.toString();

      final status =
          claimMap['status']?.toString();

      if (claimantId == userId &&
          status == 'Pending') {
        return claimMap;
      }
    }

    return null;
  }

  // =========================================================
  // CLAIM ITEM
  // =========================================================

  Future<void> _claimItem() async {
    final claimantId = AuthService.userId;

    if (claimantId == null) {
      _showMessage(
        'Please log in before claiming an item.',
      );
      return;
    }

    if (_item == null) {
      return;
    }

    final reporterId =
        _item!['reporter_id']?.toString();

    if (reporterId == null ||
        reporterId.isEmpty) {
      _showMessage(
        'Unable to identify the item reporter.',
      );
      return;
    }

    if (claimantId == reporterId) {
      _showMessage(
        'You cannot claim your own report.',
      );
      return;
    }

    setState(() {
      _isClaiming = true;
    });

    final result =
        await ApiService.createClaim(
      itemId: widget.itemId,
      claimantId: claimantId,
      reporterId: reporterId,
    );

    if (!mounted) return;

    setState(() {
      _isClaiming = false;
    });

    _showMessage(
      result['message'] ??
          'Claim request submitted.',
    );

    if (result['success'] == true) {
      await _loadItem();
    }
  }

  // =========================================================
  // SUBMIT VERIFICATION
  // =========================================================

  Future<void> _submitVerification(
    Map<String, dynamic> claim,
  ) async {
    final claimId = int.tryParse(
      claim['id']?.toString() ??
          claim['claim_id']?.toString() ??
          '',
    );

    if (claimId == null) {
      _showMessage(
        'Unable to identify this claim.',
      );
      return;
    }

    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool submitting = false;

        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Verify Ownership',
              ),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter private identifying details that only the real owner should know.',
                      style: TextStyle(
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText:
                            'Example: colour, brand, scratches, sticker, engraving, unique mark...',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? () {}
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? () {}
                      : () async {
                          final details =
                              controller.text.trim();

                          if (details.isEmpty) {
                            _showMessage(
                              'Please enter identifying details.',
                            );
                            return;
                          }

                          setDialogState(() {
                            submitting = true;
                          });

                          final result =
                              await ApiService
                                  .submitVerification(
                            claimId: claimId,
                            verificationDetails:
                                details,
                          );

                          if (!mounted) return;

                          Navigator.pop(
                            dialogContext,
                          );

                          _showMessage(
                            result['message'] ??
                                'Verification submitted.',
                          );

                          if (result['success'] == true) {
                            await _loadItem();
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Verification',
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  // =========================================================
  // REVIEW CLAIM
  // =========================================================

  Future<void> _reviewClaim(
    Map<String, dynamic> claim,
  ) async {
    final claimantId =
        claim['claimant_id']?.toString() ??
            'Unknown';

    final claimId = int.tryParse(
      claim['id']?.toString() ??
          claim['claim_id']?.toString() ??
          '',
    );

    final verificationId = int.tryParse(
      claim['verification_id']?.toString() ??
          '',
    );

    final verificationStatus =
        claim['verification_status']?.toString() ??
            'Pending';

    if (claimId == null) {
      _showMessage(
        'Unable to identify this claim.',
      );
      return;
    }

    // No verification submitted yet.
    if (verificationId == null) {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Verification Pending',
            ),
            content: Text(
              'Claim from $claimantId has been received, but the claimant has not submitted verification details yet.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );

      return;
    }

    // Load verification details.
    final verification =
        await ApiService.getVerification(
      verificationId,
    );

    if (!mounted) return;

    final details =
        verification?['verification_details']
                ?.toString() ??
            'No verification details available.';

    final status =
        verification?['status']?.toString() ??
            verificationStatus;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Review Claim',
          ),
          content: SizedBox(
            width: 550,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Claimant: $claimantId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Verification status: $status',
                  style: const TextStyle(
                    color: Color(0xFF686B78),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Private identifying details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4FA),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    details,
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isReviewing
                  ? () {}
                  : () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
              child: const Text('Close'),
            ),

            TextButton(
              onPressed: _isReviewing
                  ? () {}
                  : () async {
                      Navigator.pop(
                        dialogContext,
                      );

                      await _makeDecision(
                        verificationId:
                            verificationId,
                        decision: 'Rejected',
                      );
                    },
              child: const Text(
                'Reject',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: _isReviewing
                  ? () {}
                  : () async {
                      Navigator.pop(
                        dialogContext,
                      );

                      await _makeDecision(
                        verificationId:
                            verificationId,
                        decision: 'Approved',
                      );
                    },
              child: const Text(
                'Approve',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // APPROVE / REJECT
  // =========================================================

  Future<void> _makeDecision({
    required int verificationId,
    required String decision,
  }) async {
    final reviewerId = AuthService.userId;

    if (reviewerId == null) {
      _showMessage(
        'Please log in again.',
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isReviewing = true;
    });

    final result =
        await ApiService.reviewVerification(
      verificationId: verificationId,
      reviewerId: reviewerId,
      decision: decision,
    );

    if (!mounted) return;

    setState(() {
      _isReviewing = false;
    });

    // =======================================================
    // SUCCESS
    // =======================================================

    if (result['success'] == true) {
      if (decision == 'Approved') {
        _showMessage(
          'Verification approved and item resolved successfully.',
        );

        // The backend deletes the item after approval.
        // Therefore, do NOT reload the item.
        Navigator.pop(context);
        return;
      }

      // =====================================================
      // REJECTED
      // =====================================================

      _showMessage(
        'Claim rejected successfully.',
      );

      await _loadItem();
      return;
    }

    // =======================================================
    // FAILURE
    // =======================================================

    _showMessage(
      result['message'] ??
          'Review failed.',
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _item == null
                ? _buildError()
                : SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(24),
                    child: _buildContent(),
                  ),
      ),
    );
  }

  // =========================================================
  // CONTENT
  // =========================================================

  Widget _buildContent() {
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

    final isReporter = _isReporter();

    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 900,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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

            const SizedBox(height: 20),

            const Text(
              'Item Details',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF171A2B),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // ITEM CARD
            // =================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color:
                      const Color(0xFFE8E9F0),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFF0F1F6),
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 60,
                        color:
                            Color(0xFF9A9CAB),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    category,
                    style: const TextStyle(
                      color:
                          Color(0xFF686B78),
                    ),
                  ),

                  const SizedBox(height: 25),

                  _DetailRow(
                    icon: Icons
                        .location_on_outlined,
                    title: 'Location',
                    value: location,
                  ),

                  const SizedBox(height: 14),

                  _DetailRow(
                    icon: Icons
                        .calendar_today_outlined,
                    title: 'Date',
                    value: date,
                  ),

                  const SizedBox(height: 14),

                  _DetailRow(
                    icon: Icons
                        .access_time_outlined,
                    title:
                        'Approximate Time',
                    value: time,
                  ),

                  const SizedBox(height: 14),

                  _DetailRow(
                    icon: Icons
                        .info_outline_rounded,
                    title: 'Status',
                    value: status,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Public Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    publicDetails,
                    style: const TextStyle(
                      height: 1.5,
                      color:
                          Color(0xFF686B78),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // MATCH INFO
            // =================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFEDEBFF),
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons
                        .auto_awesome_rounded,
                    color:
                        Color(0xFF6C4EFF),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Potential Match',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'ReFind identified this as a possible match. A match score is not proof of ownership.',
                          style: TextStyle(
                            height: 1.5,
                            color:
                                Color(0xFF686B78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // PRIVACY
            // =================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color:
                      const Color(0xFFE8E9F0),
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons
                        .lock_outline_rounded,
                    color:
                        Color(0xFF6C4EFF),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Private identifying details remain hidden and are only used during ownership verification.',
                      style: TextStyle(
                        color:
                            Color(0xFF686B78),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            if (isReporter)
              _buildReporterSection()
            else
              _buildClaimantSection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CLAIMANT SECTION
  // =========================================================

  Widget _buildClaimantSection() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getMyPendingClaim(),
      builder: (
        context,
        snapshot,
      ) {
        final claim = snapshot.data;

        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        // Pending claim exists.
        if (claim != null) {
          return Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFF4F1FF),
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color:
                    const Color(0xFFE1DBFF),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons
                          .pending_actions_outlined,
                      color:
                          Color(0xFF6C4EFF),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Claim Request Submitted',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  'Your claim has been submitted. Complete ownership verification using private identifying details.',
                  style:
                      TextStyle(
                    height: 1.5,
                    color:
                        Color(0xFF686B78),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text:
                        'Verify Ownership',
                    icon: Icons
                        .verified_user_outlined,
                    fullWidth: true,
                    onPressed: () {
                      _submitVerification(
                        claim,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        // No claim yet.
        return SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: _isClaiming
                ? 'Submitting Claim...'
                : 'Claim This Item',
            icon: Icons
                .assignment_turned_in_outlined,
            fullWidth: true,
            onPressed: () {
              if (!_isClaiming) {
                _claimItem();
              }
            },
          ),
        );
      },
    );
  }

  // =========================================================
  // REPORTER SECTION
  // =========================================================

  Widget _buildReporterSection() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF4F1FF),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFE1DBFF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .notifications_active_outlined,
                color:
                    Color(0xFF6C4EFF),
              ),
              SizedBox(width: 10),
              Text(
                'Claim Requests',
                style:
                    TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'People claiming this item will appear here.',
            style:
                TextStyle(
              color:
                  Color(0xFF686B78),
            ),
          ),

          const SizedBox(height: 15),

          if (_isLoadingClaims)
            const Center(
              child:
                  CircularProgressIndicator(),
            )
          else if (_claims.isEmpty)
            const Text(
              'No claim requests yet.',
              style:
                  TextStyle(
                color:
                    Color(0xFF686B78),
              ),
            )
          else
            ..._claims.map(
              (claim) {
                final claimMap =
                    Map<String, dynamic>.from(
                  claim,
                );

                final claimant =
                    claimMap[
                            'claimant_id']
                        ?.toString() ??
                        'Unknown';

                final status =
                    claimMap['status']
                            ?.toString() ??
                        'Pending';

                final verificationId =
                    claimMap[
                            'verification_id']
                        ?.toString();

                final hasVerification =
                    verificationId != null &&
                        verificationId.isNotEmpty;

                return Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(
                    top: 12,
                  ),
                  padding:
                      const EdgeInsets.all(
                          16),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Claim from $claimant',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                          height: 6),

                      Text(
                        'Status: $status',
                        style:
                            const TextStyle(
                          color:
                              Color(
                                  0xFF686B78),
                        ),
                      ),

                      const SizedBox(
                          height: 12),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            PrimaryButton(
                          text:
                              hasVerification
                                  ? 'Review Claim'
                                  : 'Verification Pending',
                          icon:
                              hasVerification
                                  ? Icons
                                      .verified_user_outlined
                                  : Icons
                                      .hourglass_empty,
                          fullWidth:
                              true,
                          onPressed: () {
                            if (hasVerification) {
                              _reviewClaim(
                                claimMap,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Icon(
            Icons
                .error_outline_rounded,
            size: 50,
          ),

          const SizedBox(height: 15),

          const Text(
            'Unable to load item.',
            style:
                TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: _loadItem,
            child:
                const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// DETAIL ROW
// =========================================================

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
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color:
              const Color(0xFF686B78),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF171A2B),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: value,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF686B78),
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