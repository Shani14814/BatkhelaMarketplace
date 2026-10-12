import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:marketplace_core/marketplace_core.dart';

/// Soft, Professional Real-Time Map & Route Navigation Widget
/// Supports:
/// - Interactive Slippy Map Tiles (Street Map & Satellite Hybrid View)
/// - Pan, Drag, Zoom In/Out, Tap-to-Pin Exact Customer Location
/// - Real OSRM Road-Following Route Polyline + Distance (KM) & ETA
/// - Live Moving Rider / Vendor Self-Delivery GPS Marker
class RouteNavigationPreview extends StatefulWidget {
  final String originTitle;
  final String originAddress;
  final String destinationTitle;
  final String destinationAddress;
  final double distanceKm;
  final int estimatedMinutes;
  final LocationCoordinates? currentCoordinates;
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;
  final double? riderLat;
  final double? riderLng;
  final bool isGpsActive;
  final bool isOutForDelivery;
  final bool enablePinPicker;
  final bool showRouteDetailsFooter;
  final void Function(double lat, double lng, String address)? onLocationPicked;
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
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    this.riderLat,
    this.riderLng,
    this.isGpsActive = true,
    this.isOutForDelivery = false,
    this.enablePinPicker = false,
    this.showRouteDetailsFooter = true,
    this.onLocationPicked,
    this.onSimulateNavigation,
  });

  @override
  State<RouteNavigationPreview> createState() => _RouteNavigationPreviewState();
}

class _RouteNavigationPreviewState extends State<RouteNavigationPreview> {
  static const Color _brandRed = Color(0xFFC8102E);
  static const Color _textDark = Color(0xFF1E1915);
  static const Color _textMuted = Color(0xFF6E655F);
  static const Color _softBorder = Color(0xFFEDE6DC);
  static const Color _bgCream = Color(0xFFFAF6F0);

  late double _centerLat;
  late double _centerLng;
  int _zoom = 15;
  bool _satelliteMode = false;
  bool _isDetectingGps = false;

  late double _storeLat;
  late double _storeLng;
  late double _custLat;
  late double _custLng;
  double? _riderLat;
  double? _riderLng;

  List<LocationCoordinates> _routePolyline = const [];
  late double _liveDistanceKm;
  late int _liveEtaMinutes;

  @override
  void initState() {
    super.initState();
    _syncCoordinatesFromWidget();
    _loadRealRoadRoute();
  }

  @override
  void didUpdateWidget(covariant RouteNavigationPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final coordsChanged =
        oldWidget.currentCoordinates?.latitude != widget.currentCoordinates?.latitude ||
        oldWidget.currentCoordinates?.longitude != widget.currentCoordinates?.longitude ||
        oldWidget.destinationLat != widget.destinationLat ||
        oldWidget.destinationLng != widget.destinationLng ||
        oldWidget.riderLat != widget.riderLat ||
        oldWidget.riderLng != widget.riderLng ||
        oldWidget.isOutForDelivery != widget.isOutForDelivery;
    if (coordsChanged) {
      _syncCoordinatesFromWidget();
      _loadRealRoadRoute();
    }
  }

  void _syncCoordinatesFromWidget() {
    _storeLat = widget.originLat ?? 34.6175;
    _storeLng = widget.originLng ?? 71.9712;
    _custLat = widget.destinationLat ?? 34.6212;
    _custLng = widget.destinationLng ?? 71.9765;

    _riderLat = widget.riderLat ?? widget.currentCoordinates?.latitude;
    _riderLng = widget.riderLng ?? widget.currentCoordinates?.longitude;

    if (widget.enablePinPicker) {
      _centerLat = _custLat;
      _centerLng = _custLng;
    } else if (_riderLat != null && _riderLng != null) {
      _centerLat = (_riderLat! + _custLat) / 2;
      _centerLng = (_riderLng! + _custLng) / 2;
    } else {
      _centerLat = (_storeLat + _custLat) / 2;
      _centerLng = (_storeLng + _custLng) / 2;
    }

    _liveDistanceKm = widget.distanceKm;
    _liveEtaMinutes = widget.estimatedMinutes;
  }

  Future<void> _loadRealRoadRoute() async {
    final startLat = (_riderLat != null && widget.isOutForDelivery) ? _riderLat! : _storeLat;
    final startLng = (_riderLng != null && widget.isOutForDelivery) ? _riderLng! : _storeLng;

    final route = await HostingerApiClient.instance.fetchRoadRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: _custLat,
      endLng: _custLng,
    );
    if (!mounted) return;
    setState(() {
      _routePolyline = route.polyline;
      _liveDistanceKm = route.distanceKm;
      _liveEtaMinutes = route.durationMinutes;
    });
  }

  Future<void> _detectMyExactGpsLocation() async {
    setState(() => _isDetectingGps = true);
    try {
      final gps = await HostingerApiClient.instance.getCurrentDeviceGps();
      if (gps != null && mounted) {
        final addr = await HostingerApiClient.instance.reverseGeocode(
          gps.latitude,
          gps.longitude,
        );
        if (!mounted) return;
        setState(() {
          _custLat = gps.latitude;
          _custLng = gps.longitude;
          _centerLat = gps.latitude;
          _centerLng = gps.longitude;
          _zoom = 16;
        });
        widget.onLocationPicked?.call(gps.latitude, gps.longitude, addr);
        unawaited(_loadRealRoadRoute());
      }
    } finally {
      if (mounted) {
        setState(() => _isDetectingGps = false);
      }
    }
  }

  Future<void> _handleMapTap(TapUpDetails details, BoxConstraints constraints) async {
    if (!widget.enablePinPicker) return;
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    final tapped = _screenOffsetToLatLng(details.localPosition, size);
    setState(() {
      _custLat = tapped.dx;
      _custLng = tapped.dy;
      _centerLat = tapped.dx;
      _centerLng = tapped.dy;
    });
    final addr = await HostingerApiClient.instance.reverseGeocode(tapped.dx, tapped.dy);
    if (!mounted) return;
    widget.onLocationPicked?.call(tapped.dx, tapped.dy, addr);
    unawaited(_loadRealRoadRoute());
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final scale = 256.0 * math.pow(2.0, _zoom);
    final dLng = -details.delta.dx * 360.0 / scale;
    final cosLat = math.cos(_centerLat * math.pi / 180.0);
    final dLat = details.delta.dy * 360.0 * cosLat / scale;

    setState(() {
      _centerLat = (_centerLat + dLat).clamp(-85.0, 85.0);
      _centerLng = (_centerLng + dLng).clamp(-180.0, 180.0);
    });
  }

  Offset _latLngToGlobalPixel(double lat, double lng) {
    final n = math.pow(2.0, _zoom) * 256.0;
    final x = (lng + 180.0) / 360.0 * n;
    final latRad = lat * math.pi / 180.0;
    final y = (1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n;
    return Offset(x, y);
  }

  Offset _latLngToScreenOffset(double lat, double lng, Size size) {
    final centerPx = _latLngToGlobalPixel(_centerLat, _centerLng);
    final ptPx = _latLngToGlobalPixel(lat, lng);
    return Offset(
      size.width / 2.0 + (ptPx.dx - centerPx.dx),
      size.height / 2.0 + (ptPx.dy - centerPx.dy),
    );
  }

  Offset _screenOffsetToLatLng(Offset localPos, Size size) {
    final centerPx = _latLngToGlobalPixel(_centerLat, _centerLng);
    final targetPxX = centerPx.dx + (localPos.dx - size.width / 2.0);
    final targetPxY = centerPx.dy + (localPos.dy - size.height / 2.0);
    final n = math.pow(2.0, _zoom) * 256.0;
    final lng = targetPxX / n * 360.0 - 180.0;
    final latRad = math.atan(_sinh(math.pi * (1.0 - 2.0 * targetPxY / n)));
    final lat = latRad * 180.0 / math.pi;
    return Offset(lat, lng);
  }

  double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2.0;

  @override
  Widget build(BuildContext context) {
    final mapHeight = widget.enablePinPicker ? 225.0 : 210.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _softBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Interactive Map Viewport (Clean & Uncluttered)
          SizedBox(
            height: mapHeight,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final storeScreen = _latLngToScreenOffset(_storeLat, _storeLng, size);
                final custScreen = _latLngToScreenOffset(_custLat, _custLng, size);
                final riderScreen = (_riderLat != null && _riderLng != null)
                    ? _latLngToScreenOffset(_riderLat!, _riderLng!, size)
                    : Offset(
                        (storeScreen.dx + custScreen.dx) / 2,
                        (storeScreen.dy + custScreen.dy) / 2,
                      );

                final routeScreenPoints = _routePolyline.isNotEmpty
                    ? _routePolyline
                        .map((c) => _latLngToScreenOffset(c.latitude, c.longitude, size))
                        .toList()
                    : [storeScreen, riderScreen, custScreen];

                return GestureDetector(
                  onPanUpdate: _handlePanUpdate,
                  onTapUp: (d) => _handleMapTap(d, constraints),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // 1. Soft Vector Fallback Canvas
                      CustomPaint(
                        size: size,
                        painter: _BatkhelaMapPainter(),
                      ),

                      // 2. Real Live Slippy Map Tiles (Google Street / Satellite Hybrid)
                      if (!HostingerApiClient.instance.isTestEnvironment)
                        ..._buildMapTiles(size),

                      // 3. Smooth Road Route Polyline Overlay
                      CustomPaint(
                        size: size,
                        painter: _LiveRouteOverlayPainter(
                          routePoints: routeScreenPoints,
                          isOutForDelivery: widget.isOutForDelivery,
                        ),
                      ),

                      // 4. Store Pickup Marker
                      Positioned(
                        left: storeScreen.dx - 18,
                        top: storeScreen.dy - 36,
                        child: _buildMapPin(
                          icon: Icons.storefront_rounded,
                          color: _textDark,
                          label: 'Shop',
                        ),
                      ),

                      // 5. Customer Drop-off Location Marker
                      Positioned(
                        left: custScreen.dx - 22,
                        top: custScreen.dy - 46,
                        child: _buildMapPin(
                          icon: Icons.location_on_rounded,
                          color: _brandRed,
                          label: widget.enablePinPicker ? 'Drop-off Pin' : 'Delivery',
                          isLarge: true,
                        ),
                      ),

                      // 6. Live Rider GPS Marker (Shown when Out for Delivery)
                      if (widget.isOutForDelivery || _riderLat != null)
                        Positioned(
                          left: riderScreen.dx - 22,
                          top: riderScreen.dy - 22,
                          child: _buildRiderLiveMarker(),
                        ),

                      // 7. Sleek Compact Top-Left Floating Status & ETA Pill
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(242),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _softBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(22),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: widget.isOutForDelivery
                                      ? const Color(0xFF15803D)
                                      : _brandRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                widget.isOutForDelivery
                                    ? 'Live Tracking • $_liveEtaMinutes min'
                                    : '$_liveEtaMinutes min • ${_liveDistanceKm.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  color: _textDark,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 8. Compact Floating Right Map Controls
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(242),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _softBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(18),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMapControlBtn(
                                icon: _satelliteMode
                                    ? Icons.map_rounded
                                    : Icons.layers_outlined,
                                tooltip: _satelliteMode ? 'Street Map' : 'Satellite View',
                                onTap: () => setState(() => _satelliteMode = !_satelliteMode),
                              ),
                              Container(width: 22, height: 1, color: _softBorder),
                              _buildMapControlBtn(
                                icon: Icons.add_rounded,
                                tooltip: 'Zoom In',
                                onTap: () => setState(() => _zoom = (_zoom + 1).clamp(11, 18)),
                              ),
                              Container(width: 22, height: 1, color: _softBorder),
                              _buildMapControlBtn(
                                icon: Icons.remove_rounded,
                                tooltip: 'Zoom Out',
                                onTap: () => setState(() => _zoom = (_zoom - 1).clamp(11, 18)),
                              ),
                              Container(width: 22, height: 1, color: _softBorder),
                              _buildMapControlBtn(
                                icon: Icons.center_focus_strong_rounded,
                                tooltip: 'Recenter',
                                onTap: () => setState(_syncCoordinatesFromWidget),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 9. Bottom Helper Hint Pill (Left)
                      Positioned(
                        bottom: 10,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(235),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _softBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.enablePinPicker
                                    ? Icons.touch_app_rounded
                                    : Icons.navigation_rounded,
                                size: 13,
                                color: _brandRed,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.enablePinPicker
                                    ? 'Tap anywhere on map to move pin'
                                    : (_satelliteMode ? 'Satellite View' : 'Batkhela Live Map'),
                                style: const TextStyle(
                                  color: _textDark,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 10. Bottom-Right "Locate Me" GPS Pill (in Pin Picker mode)
                      if (widget.enablePinPicker)
                        Positioned(
                          bottom: 10,
                          right: 12,
                          child: Material(
                            color: _brandRed,
                            borderRadius: BorderRadius.circular(16),
                            elevation: 3,
                            shadowColor: _brandRed.withAlpha(90),
                            child: InkWell(
                              onTap: _isDetectingGps ? null : _detectMyExactGpsLocation,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isDetectingGps)
                                      const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    else
                                      const Icon(Icons.my_location_rounded, size: 13, color: Colors.white),
                                    const SizedBox(width: 5),
                                    Text(
                                      _isDetectingGps ? 'Locating...' : 'Locate Me',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Compact Route Summary Footer (Only shown when showRouteDetailsFooter is true)
          if (widget.showRouteDetailsFooter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _softBorder)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _bgCream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.storefront_rounded, size: 17, color: _textDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.originTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'To: ${widget.destinationAddress}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isOutForDelivery)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.two_wheeler_rounded, size: 13, color: Color(0xFF15803D)),
                          SizedBox(width: 4),
                          Text(
                            'ON THE WAY',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMapTiles(Size size) {
    final centerPx = _latLngToGlobalPixel(_centerLat, _centerLng);
    final topLeftPx = Offset(centerPx.dx - size.width / 2.0, centerPx.dy - size.height / 2.0);
    final bottomRightPx = Offset(centerPx.dx + size.width / 2.0, centerPx.dy + size.height / 2.0);

    final minTileX = (topLeftPx.dx / 256.0).floor();
    final maxTileX = (bottomRightPx.dx / 256.0).floor();
    final minTileY = (topLeftPx.dy / 256.0).floor();
    final maxTileY = (bottomRightPx.dy / 256.0).floor();
    final maxTileIndex = (1 << _zoom) - 1;

    final tiles = <Widget>[];
    final lyrs = _satelliteMode ? 'y' : 'm';

    for (var tx = minTileX; tx <= maxTileX; tx++) {
      for (var ty = minTileY; ty <= maxTileY; ty++) {
        if (ty < 0 || ty > maxTileIndex) continue;
        final wrappedX = ((tx % (maxTileIndex + 1)) + (maxTileIndex + 1)) % (maxTileIndex + 1);
        final tileLeft = tx * 256.0 - topLeftPx.dx;
        final tileTop = ty * 256.0 - topLeftPx.dy;
        final tileUrl = 'https://mt1.google.com/vt/lyrs=$lyrs&x=$wrappedX&y=$ty&z=$_zoom';

        tiles.add(
          Positioned(
            key: ValueKey('tile_${_zoom}_${wrappedX}_${ty}_$lyrs'),
            left: tileLeft,
            top: tileTop,
            width: 256.5,
            height: 256.5,
            child: Image.network(
              tileUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        );
      }
    }
    return tiles;
  }

  Widget _buildMapControlBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Icon(icon, size: 16, color: _textDark),
      ),
    );
  }

  Widget _buildMapPin({
    required IconData icon,
    required Color color,
    required String label,
    bool isLarge = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: isLarge ? 32 : 26,
          height: isLarge ? 32 : 26,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(95),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: isLarge ? 17 : 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRiderLiveMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: _textDark,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: const Text(
            '🛵 Live',
            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _brandRed.withAlpha(55),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _brandRed,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.two_wheeler_rounded, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _LiveRouteOverlayPainter extends CustomPainter {
  final List<Offset> routePoints;
  final bool isOutForDelivery;

  const _LiveRouteOverlayPainter({
    required this.routePoints,
    required this.isOutForDelivery,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (routePoints.length < 2) return;

    final path = Path()..moveTo(routePoints.first.dx, routePoints.first.dy);
    for (var i = 1; i < routePoints.length; i++) {
      path.lineTo(routePoints[i].dx, routePoints[i].dy);
    }

    const brandRed = Color(0xFFC8102E);
    const liveGreen = Color(0xFF15803D);
    final activeColor = isOutForDelivery ? liveGreen : brandRed;

    final glowPaint = Paint()
      ..color = activeColor.withAlpha(65)
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LiveRouteOverlayPainter oldDelegate) => true;
}

/// Soft Warm Fallback Vector Painter when offline or running in unit tests
class _BatkhelaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF3EFEA);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final blockPaint = Paint()
      ..color = const Color(0xFFE7E0D6)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 30, size.width * 0.28, size.height * 0.35),
        const Radius.circular(10),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, 20, size.width * 0.38, size.height * 0.3),
        const Radius.circular(10),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.32, size.height * 0.58, size.width * 0.3, size.height * 0.35),
        const Radius.circular(10),
      ),
      blockPaint,
    );

    final secondaryRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final crossRoad = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.25, size.height);
    canvas.drawPath(crossRoad, secondaryRoadPaint);

    final mainRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mainRoadPath = Path()
      ..moveTo(25, size.height * 0.82)
      ..cubicTo(
        size.width * 0.32,
        size.height * 0.86,
        size.width * 0.52,
        size.height * 0.32,
        size.width * 0.88,
        size.height * 0.42,
      );
    canvas.drawPath(mainRoadPath, mainRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
