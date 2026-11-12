import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noor/core/colors.dart';
import 'package:noor/shared/background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qibla_direction/qibla_direction.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> with SingleTickerProviderStateMixin {
  double? _deviceHeading;
  double? _qiblaBearing;
  double? _distanceToKaaba;
  bool _isAligned = false;

  bool _isLoading = true;
  String _errorMessage = '';

  StreamSubscription<CompassEvent>? _compassSubscription;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _initQibla();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initQibla() async {
    try {
      PermissionStatus permissionStatus = await Permission.location.status;

      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.location.request();
      }

      if (!permissionStatus.isGranted) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'يجب السماح بالوصول إلى الموقع لتحديد القبلة.';
          _isLoading = false;
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'خدمات الموقع معطلة. يرجى تفعيل GPS.';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      final coordinate = Coordinate(
        position.latitude,
        position.longitude,
      );

      final bearing = QiblaDirection.find(coordinate);
      
      // Calculate distance to Kaaba (Makkah)
      final double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        21.4225, 
        39.8262,
      );

      if (!mounted) return;

      setState(() {
        _qiblaBearing = bearing;
        _distanceToKaaba = distance / 1000; // Convert to km
        _isLoading = false;
      });

      final compassEvents = FlutterCompass.events;
      if (compassEvents == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'حساس البوصلة غير متوفر في هذا الجهاز.';
        });
        return;
      }

      _compassSubscription = compassEvents.listen(
        (CompassEvent event) {
          if (!mounted) return;

          final heading = event.heading;
          if (heading == null) return;

          setState(() {
            _deviceHeading = heading;
          });

          // Haptic feedback and alignment logic
          if (_qiblaBearing != null) {
            double diff = (_qiblaBearing! - heading).abs();
            if (diff > 180) diff = 360 - diff;
            bool aligned = diff < 3;
            if (aligned && !_isAligned) {
              HapticFeedback.mediumImpact();
            }
            _isAligned = aligned;
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _errorMessage = 'خطأ في البوصلة: $error';
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
        _isLoading = false;
      });
    }
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _deviceHeading = null;
      _qiblaBearing = null;
      _isAligned = false;
    });
    await _initQibla();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _buildAppBar(),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Text(
            "اتجاه القبلة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    return Column(
      children: [
        _buildLocationBadge(),
        const SizedBox(height: 30),
        _buildCompassSection(),
        const SizedBox(height: 40),
        _buildInfoGrid(),
        const SizedBox(height: 30),
        _buildInstructionCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.only(top: 50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off_rounded, color: Colors.redAccent, size: 70),
          const SizedBox(height: 20),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("إعادة المحاولة", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.my_location, color: secondColor, size: 18),
            const SizedBox(width: 8),
            Text(
              _isLoading ? "تحديد الموقع..." : "الموقع مفعل بدقة عالية",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassSection() {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(color: secondColor, strokeWidth: 3),
        ),
      );
    }

    final double heading = _deviceHeading ?? 0;
    final double bearing = _qiblaBearing ?? 0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow for alignment
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _isAligned
                          ? secondColor.withValues(alpha: 0.3 * _pulseController.value)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: _isAligned ? 40 : 20,
                      spreadRadius: _isAligned ? 10 : 0,
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Outer Decorative Ring
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isAligned ? secondColor : Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),

          // Main Compass
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _degreesToRadians(-heading)),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, angle, child) {
              return Transform.rotate(
                angle: angle,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass Image (if exists, fallback to custom paint)
                    Image.asset(
                      'assets/images/compass.png',
                      width: 260,
                      height: 260,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackCompass(),
                    ),
                    
                    // Qibla Pointer
                    Transform.rotate(
                      angle: _degreesToRadians(bearing),
                      child: _buildQiblaPointer(),
                    ),
                  ],
                ),
              );
            },
          ),

          // Fixed Top Indicator
          Positioned(
            top: 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isAligned ? secondColor : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isAligned ? secondColor : Colors.black).withValues(alpha: 0.2),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Icon(
                FlutterIslamicIcons.kaaba,
                color: _isAligned ? Colors.white : mainColor,
                size: 30,
              ),
            ),
          ),
          
          // Center Ornament
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
              ],
            ),
            child: Icon(
              _isAligned ? Icons.check : Icons.explore,
              color: _isAligned ? mainColor : secondColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackCompass() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: cream,
        shape: BoxShape.circle,
        border: Border.all(color: secondColor.withValues(alpha: 0.5), width: 8),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(260, 260),
            painter: CompassTicksPainter(color: mainColor.withValues(alpha: 0.3)),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text("N", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text("S", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaPointer() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Icon(
                  Icons.navigation_rounded,
                  color: _isAligned ? secondColor : Colors.red,
                  size: 42,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "المسافة للكعبة",
            _distanceToKaaba == null ? "--" : "${_distanceToKaaba!.toStringAsFixed(0)} كم",
            Icons.straighten,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildInfoCard(
            "زاوية القبلة",
            _qiblaBearing == null ? "--" : "${_qiblaBearing!.toStringAsFixed(1)}°",
            FlutterIslamicIcons.qibla,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: mainColor, size: 24),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: textSecondary, fontSize: 13)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isAligned ? mainColor : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isAligned ? secondColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAligned ? Icons.verified_user : Icons.info_outline,
            color: _isAligned ? Colors.white : secondColor,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _isAligned
                  ? "أنت الآن باتجاه القبلة الصحيح، تقبل الله منك."
                  : "يرجى وضع الهاتف بشكل مسطح وتحريكه حتى يظهر رمز الكعبة في الأعلى.",
              style: TextStyle(
                color: _isAligned ? Colors.white : textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompassTicksPainter extends CustomPainter {
  final Color color;
  CompassTicksPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 72; i++) {
      final angle = i * 5 * math.pi / 180;
      final bool isMajor = i % 6 == 0;
      final double tickLength = isMajor ? 12 : 6;

      final start = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 10 - tickLength) * math.cos(angle),
        center.dy + (radius - 10 - tickLength) * math.sin(angle),
      );

      paint.strokeWidth = isMajor ? 2.5 : 1;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
