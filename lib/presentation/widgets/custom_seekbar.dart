import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConcentricThumb extends SliderComponentShape {
  const ConcentricThumb({
    this.inner = 12,
    this.ring1 = 16,
    this.ring2 = 20,
    this.innerColor = const Color(0xFF0288D1),
    this.ring1Color = const Color(0x880288D1),
    this.ring2Color = const Color(0x330288D1),
  });

  final double inner, ring1, ring2;
  final Color innerColor, ring1Color, ring2Color;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(ring2);

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final c = context.canvas;
    c.drawCircle(center, ring2, Paint()..color = ring2Color);
    c.drawCircle(center, ring1, Paint()..color = ring1Color);
    c.drawCircle(center, inner, Paint()..color = innerColor);
  }
}
class FancySeekBar extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged; // Callback to notify parent

  FancySeekBar({
    super.key,
    required this.min,
    required this.value,
    required this.max,
    this.onChanged,
  });

  @override
  State<FancySeekBar> createState() => _FancySeekBarState();
}

class _FancySeekBarState extends State<FancySeekBar> {
  late double _currentValue; // Local state to track the slider value

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value; // Initialize with widget.value
  }

  @override
  void didUpdateWidget(FancySeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update _currentValue if widget.value changes externally
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaled sizes
    final double innerR = 12.r;
    final double ring1R = 16.r;
    final double ring2R = 20.r; // thumb outer radius
    final double trackH = 6.r; // track height
    final double labelH = 28.h; // space for value label
    final double sliderH = (ring2R * 2) + 8.h; // space for slider itself
    final double capDia = 24.r;
    final double capR = capDia / 2;

    final double totalH = labelH + sliderH; // <-- explicit height for the Stack

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Track geometry
          final double trackLeft = ring2R;
          final double trackRight = constraints.maxWidth - ring2R;
          final double trackWidth = trackRight - trackLeft;

          // Thumb X
          final double t = (_currentValue - widget.min) / (widget.max - widget.min);
          final double thumbX = trackLeft + t * trackWidth;

          // Track center Y
          final double trackCenterY = labelH + (sliderH / 2);

          return SizedBox(
            height: totalH,
            width: constraints.maxWidth,
            child: Stack(
              children: [
                // Value label
                Positioned(
                  top: 0,
                  left: (thumbX - 12.w).clamp(0, constraints.maxWidth - 24.w),
                  width: 24.w,
                  height: labelH,
                  child: Center(
                    child: Text(
                      _currentValue.toStringAsFixed(0),
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                // Slider
                // Start cap (centered on track)
                Positioned(
                  left: trackLeft - capR + 4,
                  top: trackCenterY - capR,
                  child: _endCap(capDia),
                ),
                // End cap
                Positioned(
                  left: trackRight - capR - 4,
                  top: trackCenterY - capR,
                  child: _endCap(capDia),
                ),
                Positioned(
                  top: labelH,
                  left: 0,
                  right: 0,
                  height: sliderH,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: trackH,
                      overlayShape: SliderComponentShape.noOverlay,
                      trackShape: const RoundedRectSliderTrackShape(),
                      activeTrackColor: Colors.grey.shade300,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbShape: ConcentricThumb(
                        inner: innerR,
                        ring1: ring1R,
                        ring2: ring2R,
                      ),
                    ),
                    child: Slider(
                      value: _currentValue,
                      min: widget.min,
                      max: widget.max,
                      divisions: (widget.max - widget.min).toInt(),
                      onChanged: (v) {
                        setState(() {
                          _currentValue = v.roundToDouble();
                        });
                        widget.onChanged?.call(_currentValue); // Notify parent
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _endCap(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      shape: BoxShape.circle,
    ),
  );
}