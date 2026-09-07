import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace_core/marketplace_core.dart';
import '../../data/rider_demo_data.dart';
import '../../widgets/route_navigation_preview.dart';

class RiderDeliveryDetailScreen extends StatelessWidget {
  final RiderDeliveryAssignment delivery;

  const RiderDeliveryDetailScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RiderDemoController.instance,
      builder: (context, _) {
        final liveDelivery = RiderDemoController.instance.assignments.firstWhere(
          (d) => d.id == delivery.id,
          orElse: () => delivery,
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            title: Text(
              'Delivery #${liveDelivery.orderNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _stageColor(liveDelivery.stage).withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      liveDelivery.stage.displayName,
                      style: TextStyle(
                        color: _stageColor(liveDelivery.stage),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Route & Map Navigation Preview Card
              RouteNavigationPreview(
                originTitle: liveDelivery.storeName,
                originAddress: liveDelivery.pickupAddress,
                destinationTitle: liveDelivery.customerArea,
                destinationAddress: liveDelivery.customerAddress,
                distanceKm: liveDelivery.distanceKm,
                estimatedMinutes: liveDelivery.estimatedMinutes,
              ),
              const SizedBox(height: 16),

              // Cash Collection & Earnings Highlight
              _buildEarningsCard(context, liveDelivery),
              const SizedBox(height: 16),

              // Pickup Store Details Card
              _buildStorePickupCard(context, liveDelivery),
              const SizedBox(height: 16),

              // Customer Drop-off Card
              _buildCustomerDropoffCard(context, liveDelivery),
              const SizedBox(height: 16),

              // Package Item Checklist
              _buildItemChecklistCard(context, liveDelivery),
              const SizedBox(height: 80),
            ],
          ),
          bottomSheet: _buildContextualActionBar(context, liveDelivery),
        );
      },
    );
  }

  Widget _buildEarningsCard(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(20)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cash to Collect', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    'PKR ${liveDelivery.cashToCollect.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Cash on Delivery (Batkhela)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rider Earnings', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(
                    'PKR ${liveDelivery.totalEarnings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('Fee + Tip included', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorePickupCard(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(20)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup Store',
                        style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        liveDelivery.storeName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${liveDelivery.storeName}...')),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    liveDelivery.pickupAddress,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDropoffCard(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.coral.withAlpha(30)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_pin_circle_outlined, color: AppColors.coral, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Drop-off Destination',
                        style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        liveDelivery.customerArea,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.coral),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling customer via marketplace proxy...')),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    liveDelivery.customerAddress,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
            if (liveDelivery.customerNotes != null && liveDelivery.customerNotes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.coral.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notes, size: 16, color: AppColors.coral),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Instructions: ${liveDelivery.customerNotes}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemChecklistCard(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(20)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Package Item Checklist',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Verify package seal and items with store merchant before leaving.',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const Divider(height: 20),
            ...liveDelivery.itemNames.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_box_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget? _buildContextualActionBar(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    if (liveDelivery.stage == DeliveryStage.delivered || liveDelivery.stage == DeliveryStage.declined) {
      return null;
    }

    if (liveDelivery.stage == DeliveryStage.offered) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    RiderDemoController.instance.declineAssignment(liveDelivery.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delivery offer declined.')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    RiderDemoController.instance.acceptAssignment(liveDelivery.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Assignment Accepted! Head to store for pickup.')),
                    );
                  },
                  child: const Text('Accept Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _stageActionColor(liveDelivery.stage),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              if (liveDelivery.stage == DeliveryStage.arrivedAtPickup) {
                _showPickupChecklistSheet(context, liveDelivery);
              } else if (liveDelivery.stage == DeliveryStage.onTheWay) {
                _showProofOfDeliverySheet(context, liveDelivery);
              } else {
                RiderDemoController.instance.progressDeliveryStage(liveDelivery.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status updated: ${liveDelivery.stage.nextActionLabel}')),
                );
              }
            },
            icon: Icon(_stageActionIcon(liveDelivery.stage)),
            label: Text(
              liveDelivery.stage.nextActionLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  void _showPickupChecklistSheet(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Store Pickup Verification',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          Text(
                            liveDelivery.storeName,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  'Verify items with merchant before leaving:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                ...liveDelivery.itemNames.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ensure package is sealed and food/groceries are intact.',
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      RiderDemoController.instance.confirmPickupItems(liveDelivery.id);
                      Navigator.pop(modalCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pickup confirmed! Proceeding with delivery to customer.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: const Text('Confirm Items & Start Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProofOfDeliverySheet(BuildContext context, RiderDeliveryAssignment liveDelivery) {
    String selectedProof = 'Handed Directly to Customer';
    bool cashVerified = true;
    Uint8List? proofBytes;
    String? proofFileName;
    bool isUploading = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickProof(ImageSource source) async {
              try {
                final picker = ImagePicker();
                final file = await picker.pickImage(
                  source: source,
                  maxWidth: 1200,
                  maxHeight: 1200,
                  imageQuality: 85,
                );
                if (file != null) {
                  final bytes = await file.readAsBytes();
                  final validation = StorageValidator.validate(
                    bytes: bytes,
                    fileName: file.name,
                    bucket: StorageBucket.deliveryProofs,
                  );
                  if (!validation.isValid) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(validation.errorMessage ?? 'Invalid proof image.')),
                      );
                    }
                    return;
                  }
                  setModalState(() {
                    proofBytes = bytes;
                    proofFileName = file.name;
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not access media: $e')),
                  );
                }
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline, color: AppColors.success),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Proof of Delivery & Handover',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              Text(
                                'Confirm handover and payment receipt',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Cash Collection Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withAlpha(30)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payments_outlined, color: AppColors.primary, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cash to Collect (COD)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                                Text(
                                  'PKR ${liveDelivery.cashToCollect.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: cashVerified,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setModalState(() => cashVerified = val ?? true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Delivery Handover Method:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    ...[
                      'Handed Directly to Customer',
                      'Left at Doorstep / Front Gate',
                      'Received by Family Member',
                      'Photo Proof (Camera / Gallery)',
                    ].map((method) {
                      final isSel = selectedProof == method;
                      return InkWell(
                        onTap: () {
                          setModalState(() => selectedProof = method);
                          if (method == 'Photo Proof (Camera / Gallery)' && proofBytes == null) {
                            pickProof(ImageSource.camera);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: isSel ? AppColors.primary : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                method,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? AppColors.primary : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Photo Proof Section if selected
                    if (selectedProof == 'Photo Proof (Camera / Gallery)') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: proofBytes != null
                            ? Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      proofBytes!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                            SizedBox(width: 4),
                                            Text('Photo Captured', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          proofFileName ?? 'proof.jpg',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => pickProof(ImageSource.camera),
                                    icon: const Icon(Icons.refresh, size: 14),
                                    label: const Text('Retake', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    onPressed: () => pickProof(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                                    label: const Text('Capture Camera', style: TextStyle(fontSize: 12)),
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.indigo,
                                      side: const BorderSide(color: AppColors.indigo),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    onPressed: () => pickProof(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                                    label: const Text('Device Gallery', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isUploading
                            ? null
                            : () async {
                                String? proofUrl;
                                if (proofBytes != null) {
                                  setModalState(() => isUploading = true);
                                  try {
                                    proofUrl = await MarketplaceDataService.instance.storageRepo.uploadDeliveryProof(
                                      deliveryId: liveDelivery.id,
                                      riderId: 'rider_active_bk',
                                      bytes: proofBytes!,
                                      fileName: proofFileName ?? 'proof.jpg',
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to upload proof: $e')),
                                      );
                                    }
                                    setModalState(() => isUploading = false);
                                    return;
                                  }
                                }

                                RiderDemoController.instance.completeDeliveryWithProof(
                                  id: liveDelivery.id,
                                  proofType: selectedProof,
                                  proofPhotoUrl: proofUrl,
                                );
                                if (context.mounted) {
                                  Navigator.pop(modalCtx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Order #${liveDelivery.orderNumber} successfully delivered! PKR ${liveDelivery.totalEarnings.toStringAsFixed(0)} credited to earnings.'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                        child: isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Confirm Handover & Complete Trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _stageColor(DeliveryStage stage) {
    switch (stage) {
      case DeliveryStage.offered:
        return AppColors.coral;
      case DeliveryStage.accepted:
      case DeliveryStage.arrivedAtPickup:
      case DeliveryStage.pickedUp:
      case DeliveryStage.onTheWay:
        return AppColors.primary;
      case DeliveryStage.delivered:
        return AppColors.success;
      case DeliveryStage.declined:
        return AppColors.error;
    }
  }

  Color _stageActionColor(DeliveryStage stage) {
    switch (stage) {
      case DeliveryStage.accepted:
        return AppColors.indigo;
      case DeliveryStage.arrivedAtPickup:
        return AppColors.primary;
      case DeliveryStage.pickedUp:
        return AppColors.indigo;
      case DeliveryStage.onTheWay:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _stageActionIcon(DeliveryStage stage) {
    switch (stage) {
      case DeliveryStage.accepted:
        return Icons.navigation;
      case DeliveryStage.arrivedAtPickup:
        return Icons.shopping_bag_outlined;
      case DeliveryStage.pickedUp:
        return Icons.two_wheeler;
      case DeliveryStage.onTheWay:
        return Icons.check_circle_outline;
      default:
        return Icons.arrow_forward;
    }
  }
}
