import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

class RouteNavigationPreview extends StatelessWidget {
  final String originTitle;
  final String originAddress;
  final String destinationTitle;
  final String destinationAddress;
  final double distanceKm;
  final int estimatedMinutes;
  final LocationCoordinates? currentCoordinates;
  final bool isGpsActive;
  final VoidCallback? onSimulateNavigation;

  const RouteNavigationPreview({
    super.key,
    required this.originTitle,
    required this.originAddress,
    required this.destinationTitle,
    required this.destinationAddress,
    required this.distanceKm,
    required this.estimatedMinutes,
    this.currentCoordinates,
    this.isGpsActive = true,
    this.onSimulateNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final lat = currentCoordinates?.latitude ?? 34.6186;
    final lng = currentCoordinates?.longitude ?? 71.9723;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Enhanced Stylized Batkhela Map Canvas
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F1F2),
            ),
            child: Stack(
              children: [
                // Stylized Multi-Road Network & Terrain Canvas
                CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _BatkhelaMapPainter(),
                ),

                // Live Navigation Instruction Floating Bar
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withAlpha(240),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.softCyan.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.turn_right_rounded, color: AppColors.softCyan, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Turn Right in 250m onto Main GT Road',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Fastest route via Clock Tower Chowk • Low traffic',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$estimatedMinutes min',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Distance & Live GPS Telemetry Floating Badge
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(235),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withAlpha(30)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGpsActive ? Icons.satellite_alt_rounded : Icons.gps_off,
                          size: 12,
                          color: isGpsActive ? AppColors.primary : AppColors.error,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${distanceKm.toStringAsFixed(1)} KM • GPS ${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Batkhela Bazaar Active Node Badge
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(235),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withAlpha(30)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation_rounded, size: 12, color: AppColors.coral),
                        SizedBox(width: 4),
                        Text(
                          'Batkhela Central Node',
                          style: TextStyle(
                            color: AppColors.textPrimary,
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

/// Custom Vector Painter generating a rich Batkhela Road Topology with terrain and route nodes
class _BatkhelaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Terrain & Urban Blocks
    final blockPaint = Paint()
      ..color = const Color(0xFFDCEAE9)
      ..style = PaintingStyle.fill;

    // Block 1 (North-West)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 30, size.width * 0.28, size.height * 0.35),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    // Block 2 (North-East)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, 20, size.width * 0.38, size.height * 0.3),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    // Block 3 (South-Central)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.32, size.height * 0.58, size.width * 0.3, size.height * 0.35),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    // 2. Swat River Ribbon (South curved blue vector)
    final riverPaint = Paint()
      ..color = const Color(0xFFBFDBFE).withAlpha(150)
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.95);
    riverPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.82,
      size.width,
      size.height * 0.98,
    );
    canvas.drawPath(riverPath, riverPaint);

    // 3. Arterial Roads Network
    final secondaryRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Secondary Cross Street (Hospital Road)
    final crossRoad = Path();
    crossRoad.moveTo(size.width * 0.25, 0);
    crossRoad.lineTo(size.width * 0.25, size.height);
    canvas.drawPath(crossRoad, secondaryRoadPaint);

    // Secondary Street (College Road Link)
    final collegeRoad = Path();
    collegeRoad.moveTo(size.width * 0.75, 0);
    collegeRoad.lineTo(size.width * 0.75, size.height);
    canvas.drawPath(collegeRoad, secondaryRoadPaint);

    // Secondary Connector (Thana Link)
    final thanaRoad = Path();
    thanaRoad.moveTo(0, size.height * 0.45);
    thanaRoad.lineTo(size.width, size.height * 0.45);
    canvas.drawPath(thanaRoad, secondaryRoadPaint);

    // 4. Main Arterial Highway (Main GT Road)
    final mainRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mainRoadPath = Path();
    mainRoadPath.moveTo(25, size.height * 0.82);
    mainRoadPath.cubicTo(
      size.width * 0.32,
      size.height * 0.86,
      size.width * 0.52,
      size.height * 0.32,
      size.width * 0.88,
      size.height * 0.42,
    );
    canvas.drawPath(mainRoadPath, mainRoadPaint);

    // Road Centerline dashes
    final dashPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(mainRoadPath, dashPaint);

    // 5. Active Dynamic Delivery Route (Teal polyline with shadow glow)
    final routeGlowPaint = Paint()
      ..color = AppColors.primary.withAlpha(60)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeRoutePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeRoutePath = Path();
    activeRoutePath.moveTo(28, size.height * 0.82);
    activeRoutePath.cubicTo(
      size.width * 0.32,
      size.height * 0.86,
      size.width * 0.52,
      size.height * 0.32,
      size.width * 0.88,
      size.height * 0.42,
    );

    canvas.drawPath(activeRoutePath, routeGlowPaint);
    canvas.drawPath(activeRoutePath, activeRoutePaint);

    // 6. Waypoint Markers
    // Start / Store Pickup Marker (Teal with white center)
    final pickupOffset = Offset(28, size.height * 0.82);
    canvas.drawCircle(pickupOffset, 9, Paint()..color = Colors.white);
    canvas.drawCircle(pickupOffset, 7, Paint()..color = AppColors.primary);
    canvas.drawCircle(pickupOffset, 3, Paint()..color = Colors.white);

    // Destination / Customer Drop-off Marker (Coral with halo)
    final dropoffOffset = Offset(size.width * 0.88, size.height * 0.42);
    canvas.drawCircle(dropoffOffset, 12, Paint()..color = AppColors.coral.withAlpha(50));
    canvas.drawCircle(dropoffOffset, 9, Paint()..color = Colors.white);
    canvas.drawCircle(dropoffOffset, 7, Paint()..color = AppColors.coral);
    canvas.drawCircle(dropoffOffset, 3, Paint()..color = Colors.white);

    // 7. Live Pulsating Rider Position Marker (Along route)
    final riderOffset = Offset(size.width * 0.46, size.height * 0.60);
    // Outer pulse ring
    canvas.drawCircle(riderOffset, 14, Paint()..color = AppColors.softCyan.withAlpha(90));
    canvas.drawCircle(riderOffset, 10, Paint()..color = Colors.white);
    canvas.drawCircle(riderOffset, 8, Paint()..color = AppColors.primaryDark);
    canvas.drawCircle(riderOffset, 3, Paint()..color = AppColors.softCyan);

    // Road label texts
    _drawRoadLabel(canvas, 'MAIN GT ROAD', Offset(size.width * 0.36, size.height * 0.74));
    _drawRoadLabel(canvas, 'BYPASS ROAD', Offset(size.width * 0.68, size.height * 0.28));
  }

  void _drawRoadLabel(Canvas canvas, String text, Offset position) {
    const textStyle = TextStyle(
      color: Color(0xFF64748B),
      fontSize: 8,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
