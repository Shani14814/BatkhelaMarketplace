import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

class RouteNavigationPreview extends StatelessWidget {
  final String originTitle;
  final String originAddress;
  final String destinationTitle;
  final String destinationAddress;
  final double distanceKm;
  final int estimatedMinutes;
  final VoidCallback? onSimulateNavigation;

  const RouteNavigationPreview({
    super.key,
    required this.originTitle,
    required this.originAddress,
    required this.destinationTitle,
    required this.destinationAddress,
    required this.distanceKm,
    required this.estimatedMinutes,
    this.onSimulateNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Map Graphic Canvas Representation
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight,
                  AppColors.softCyan.withAlpha(80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Stylized Road Grid Overlay
                CustomPaint(
                  size: const Size(double.infinity, 140),
                  painter: _MapRoadsPainter(),
                ),

                // Distance & ETA Floating Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_bike, size: 14, color: AppColors.softCyan),
                        const SizedBox(width: 6),
                        Text(
                          '${distanceKm.toStringAsFixed(1)} km • $estimatedMinutes mins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // GPS Telemetry Indicator
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.satellite_alt, size: 12, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Batkhela Route Node Active',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Waypoints Listing
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Pickup Point
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            originTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            originAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Connector
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 2,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),

                // Destination Point
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, size: 16, color: AppColors.coral),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destinationTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            destinationAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
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
}

class _MapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withAlpha(160)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(20, size.height * 0.7);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.2,
      size.width * 0.85,
      size.height * 0.35,
    );

    // Draw background road
    canvas.drawPath(path, roadPaint);

    // Draw active bike route path
    canvas.drawPath(path, routePaint);

    // Draw Start Marker
    final startPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(20, size.height * 0.7), 6, startPaint);

    // Draw End Marker
    final endPaint = Paint()..color = AppColors.coral;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.35), 6, endPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
