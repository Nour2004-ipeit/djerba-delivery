import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SliderCaptcha extends StatefulWidget {
  final VoidCallback onVerified;

  const SliderCaptcha({super.key, required this.onVerified});

  @override
  State<SliderCaptcha> createState() => _SliderCaptchaState();
}

class _SliderCaptchaState extends State<SliderCaptcha> with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isVerified = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    )..addListener(() {
        setState(() {
          _dragPosition = _slideAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        const double handleWidth = 56.0;
        final double maxDrag = maxWidth - handleWidth - 8.0; // 4px padding on each side

        return Container(
          width: maxWidth,
          height: 64,
          decoration: BoxDecoration(
            color: _isVerified ? DjerbaTheme.successLight : DjerbaTheme.primaryLight,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _isVerified ? DjerbaTheme.success.withOpacity(0.3) : DjerbaTheme.primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background Text
              Center(
                child: Text(
                  _isVerified ? "Vérifié" : "Glisser pour vérifier",
                  style: TextStyle(
                    color: _isVerified ? DjerbaTheme.success : DjerbaTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Success Fill Background
              if (_dragPosition > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _dragPosition + handleWidth / 2 + 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isVerified ? DjerbaTheme.successLight : DjerbaTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              // Draggable Handle
              Positioned(
                left: _dragPosition + 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isVerified) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isVerified) return;
                    if (_dragPosition > maxDrag * 0.9) {
                      setState(() {
                        _dragPosition = maxDrag;
                        _isVerified = true;
                      });
                      widget.onVerified();
                    } else {
                      _slideAnimation = Tween<double>(
                        begin: _dragPosition,
                        end: 0,
                      ).animate(
                        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
                      );
                      _animationController.forward(from: 0);
                    }
                  },
                  child: Container(
                    width: handleWidth,
                    height: handleWidth,
                    decoration: BoxDecoration(
                      color: _isVerified ? DjerbaTheme.success : DjerbaTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isVerified ? DjerbaTheme.success : DjerbaTheme.primaryColor).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      _isVerified ? Icons.check_rounded : Icons.keyboard_double_arrow_right_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
