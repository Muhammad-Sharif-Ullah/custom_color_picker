import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ColorMode { hex, rgb, hsb, hsl }

class CustomColorPicker extends StatefulWidget {
  final Color initialColor;

  const CustomColorPicker({
    super.key,
    this.initialColor = Colors.blue,
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  double _hue = 240.0; // Default hue
  double _opacity = 1.0; // Default opacity
  double _saturation = 1.0;
  double _brightness = 1.0;

  ColorMode _colorMode = ColorMode.hex;
  Color _currentColor = Colors.blue;

  // hex
  final TextEditingController _hexCodeController = TextEditingController();

  // rgb
  final TextEditingController _rgbRCodeController = TextEditingController();
  final TextEditingController _rgbGCodeController = TextEditingController();
  final TextEditingController _rgbBCodeController = TextEditingController();

  // hsb
  final TextEditingController _hsbHCodeController = TextEditingController();
  final TextEditingController _hsbSCodeController = TextEditingController();
  final TextEditingController _hsbBCodeController = TextEditingController();

  // hsl
  final TextEditingController _hslHCodeController = TextEditingController();
  final TextEditingController _hslSCodeController = TextEditingController();
  final TextEditingController _hslLCodeController = TextEditingController();

  @override
  void dispose() {
    _hexCodeController.dispose();
    _rgbRCodeController.dispose();
    _rgbGCodeController.dispose();
    _rgbBCodeController.dispose();
    _hsbHCodeController.dispose();
    _hsbSCodeController.dispose();
    _hsbBCodeController.dispose();
    _hslHCodeController.dispose();
    _hslSCodeController.dispose();
    _hslLCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Calculate the HSV values from the initial color
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _brightness = hsv.value;
    _opacity = widget.initialColor.opacity;

    _currentColor = widget.initialColor;
    _updateColor();
  }

  void _updateColor() {
    setState(() {
      _currentColor = HSVColor.fromAHSV(
        _opacity,
        _hue,
        _saturation,
        _brightness,
      ).toColor();

      _updateColorCode();
    });
  }

  void _updateColorCode() {
    String colorCode;
    switch (_colorMode) {
      case ColorMode.hex:
        colorCode =
            "#${_currentColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}";
        // hexCode with # and 6 digit
        _hexCodeController.text = "#${colorCode.substring(3, 9)}";
        break;
      case ColorMode.rgb:
        colorCode =
            "${_currentColor.red},${_currentColor.green},${_currentColor.blue}";
        _rgbRCodeController.text = "${_currentColor.red}";
        _rgbGCodeController.text = "${_currentColor.green}";
        _rgbBCodeController.text = "${_currentColor.blue}";
        break;
      case ColorMode.hsb:
        final hsv = HSVColor.fromColor(_currentColor);
        colorCode =
            "${hsv.hue.toInt()},${(_saturation * 100).toInt()},${(_brightness * 100).toInt()}";
        _hsbHCodeController.text = "${hsv.hue.toInt()}";
        _hsbSCodeController.text = "${(hsv.saturation * 100).toInt()}";
        _hsbBCodeController.text = "${(hsv.value * 100).toInt()}";
        break;
      case ColorMode.hsl:
        final hsl = HSLColor.fromColor(_currentColor);
        colorCode =
            "${hsl.hue.toInt()},${(hsl.saturation * 100).toInt()},${(hsl.lightness * 100).toInt()}";
        _hslHCodeController.text = "${hsl.hue.toInt()}";
        _hslSCodeController.text = "${(hsl.saturation * 100).toInt()}";
        _hslLCodeController.text = "${(hsl.lightness * 100).toInt()}";
        break;
    }
  }

  // The rest of the widget build method remains the same...

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color Gradient Picker (Saturation & Brightness)
            _buildColorGradient(),

            const SizedBox(height: 12),

            _buildHue(_hue),
            const SizedBox(height: 15),

            _buildOpacity(_opacity),
            const SizedBox(height: 10),
            // Color Mode, Code Input, Opacity Value
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ColorMode>(
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: SizedBox(
                          height: 24,
                          child: FittedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.chevron_up),
                                Icon(CupertinoIcons.chevron_down),
                              ],
                            ),
                          ),
                        ),
                      ),
                      value: _colorMode,
                      items: ColorMode.values.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(mode.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (mode) {
                        setState(() {
                          _colorMode = mode!;
                          _updateColorCode();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(child: _buildInputFieldWithBorder(_colorMode)),
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("${(_opacity * 100).toInt()}%"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // write a note that if you input custom code
            // by input field, the color picker type the done button
            const Text(
              "Note: If you input custom code, press done button on the keyboard to update the color",
              style: TextStyle(
                fontSize: 12,
              ),
            ),

            // Buttons cancel or ok
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("CANCEL"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_currentColor);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGradient() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth; // Full available width
        double height = 200; // Fixed height for the gradient square

        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _saturation = (details.localPosition.dx / width).clamp(0.0, 1.0);
              _brightness =
                  1 - (details.localPosition.dy / height).clamp(0.0, 1.0);
              _updateColor();
            });
          },
          child: SizedBox(
            width: width,
            height: height,
            child: CustomPaint(
              painter: _GradientPainter(hue: _hue),
              child: Stack(
                children: [
                  Positioned(
                    left:
                        (_saturation * width) - 10, // Adjust trackball position
                    top: ((1 - _brightness) * height) - 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        color: Colors.transparent,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildHue(double hue) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth; // Full available width
      double height = 15; // Fixed height for the gradient square
      return GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _hue = (details.localPosition.dx / width * 360).clamp(0.0, 360.0);
            _updateColor();
          });
        },
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _GradientHuePainter(hue: _hue),
            child: Stack(
              children: [
                Positioned(
                  left: (_hue / 360) * width - 10, // Adjust trackball position
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.transparent,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInputFieldWithBorder(ColorMode mode) {
    switch (mode) {
      case ColorMode.hex:
        return hexColorInput();
      case ColorMode.rgb:
        return rgbColorInput();
      case ColorMode.hsb:
        return hsbColorInput();
      default:
        return hslColorInput();
    }
  }

  Widget hslColorInput() {
    List hslCNT = [
      _hslHCodeController,
      _hslSCodeController,
      _hslLCodeController
    ];
    return Row(
      children: [
        // input for H S B
        for (int i = 0; i < 3; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextFormField(
                controller: hslCNT[i],
                textAlign: TextAlign.center,
                inputFormatters: [
                  if (i == 0)
                    FilteringTextInputFormatter.allow(RegExp(
                        r'^([0-9]|[1-9][0-9]|[1-2][0-9][0-9]|3[0-5][0-9]|360)$'))
                  else
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^([0-9]|[1-9][0-9]|100)$')),
                ],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) {
                  // Handle color input
                  // check if either one of the value is not

                  if (_hslHCodeController.text.isEmpty ||
                      _hslSCodeController.text.isEmpty ||
                      _hslLCodeController.text.isEmpty) {
                    _updateColor();
                    return;
                  }
                  final h = double.parse(_hslHCodeController.text);
                  final s = double.parse(_hslSCodeController.text) / 100;
                  final l = double.parse(_hslLCodeController.text) / 100;

                  setState(() {
                    _currentColor = HSLColor.fromAHSL(1.0, h, s, l).toColor();
                    _hue = HSLColor.fromColor(_currentColor).hue;
                    _saturation = HSLColor.fromColor(_currentColor).saturation;
                    _brightness = HSLColor.fromColor(_currentColor).lightness;
                    // update picker
                  });
                  _updateColor();
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget hsbColorInput() {
    List hsbCNT = [
      _hsbHCodeController,
      _hsbSCodeController,
      _hsbBCodeController
    ];
    return Row(
      children: [
        // input for H S B
        for (int i = 0; i < 3; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextFormField(
                controller: hsbCNT[i],
                textAlign: TextAlign.center,
                inputFormatters: [
                  if (i == 0)
                    FilteringTextInputFormatter.allow(RegExp(
                        r'^([0-9]|[1-9][0-9]|[1-2][0-9][0-9]|3[0-5][0-9]|360)$'))
                  else
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^([0-9]|[1-9][0-9]|100)$')),
                ],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) {
                  // Handle color input
                  // check if either one of the value is not

                  if (_hsbHCodeController.text.isEmpty ||
                      _hsbSCodeController.text.isEmpty ||
                      _hsbBCodeController.text.isEmpty) {
                    _updateColor();
                    return;
                  }
                  final h = double.parse(_hsbHCodeController.text);
                  final s = double.parse(_hsbSCodeController.text) / 100;
                  final b = double.parse(_hsbBCodeController.text) / 100;

                  setState(() {
                    _currentColor =
                        HSVColor.fromAHSV(h, s, b, _opacity).toColor();
                    _hue = HSVColor.fromColor(_currentColor).hue;
                    _saturation = HSVColor.fromColor(_currentColor).saturation;
                    _brightness = HSVColor.fromColor(_currentColor).value;
                    // update picker
                  });
                  _updateColor();
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget rgbColorInput() {
    List rgbCNT = [
      _rgbRCodeController,
      _rgbGCodeController,
      _rgbBCodeController
    ];
    return Row(
      children: [
        // input for R G B
        for (int i = 0; i < 3; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextFormField(
                controller: rgbCNT[i],
                onChanged: (value) {
                  // Handle color input
                  log("rgbCNT[i] ${rgbCNT[i].text}");

                  // final r = int.parse(_rgbRCodeController.text);
                  // final g = int.parse(_rgbGCodeController.text);
                  // final b = int.parse(_rgbBCodeController.text);
                  // _currentColor = Color.fromRGBO(r, g, b, _opacity);
                  // _updateColor();
                },
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(
                      r'^([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$')),
                ],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) {
                  // Handle color input
                  // check if either one of the value is not

                  if (_rgbRCodeController.text.isEmpty ||
                      _rgbGCodeController.text.isEmpty ||
                      _rgbBCodeController.text.isEmpty) {
                    _updateColor();
                    return;
                  }
                  final r = int.parse(_rgbRCodeController.text);
                  final g = int.parse(_rgbGCodeController.text);
                  final b = int.parse(_rgbBCodeController.text);

                  setState(() {
                    _currentColor = Color.fromRGBO(r, g, b, _opacity);
                    _hue = HSVColor.fromColor(_currentColor).hue;
                    _saturation = HSVColor.fromColor(_currentColor).saturation;
                    _brightness = HSVColor.fromColor(_currentColor).value;
                    // update picker
                  });
                  _updateColor();
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  TextFormField hexColorInput() {
    return TextFormField(
      controller: _hexCodeController,
      onChanged: (value) {
        if (value.isEmpty) {
          _hexCodeController.text = "#";
        } else if (!value.contains("#")) {
          _hexCodeController.text = "#$value";
        }
      },
      onFieldSubmitted: (value) {
        if (_hexCodeController.text.isEmpty ||
            _hexCodeController.text.length < 7) {
          _updateColor();
          return;
        }
        // log("hexCodeController ${_hexCodeController.text}");
        final hex = _hexCodeController.text;
        final color = Color(int.parse(hex.substring(1, 7), radix: 16));
        setState(() {
          _currentColor = color;
          _hue = HSVColor.fromColor(_currentColor).hue;
          _saturation = HSVColor.fromColor(_currentColor).saturation;
          _brightness = HSVColor.fromColor(_currentColor).value;
          // update picker
        });
        _updateColor();
      },
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^#?[0-9a-fA-F]{0,6}$')),
      ],
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
    );
  }

  _buildOpacity(double opacity) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth; // Full available width
      double height = 15; // Fixed height for the gradient square
      return GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _opacity = (details.localPosition.dx / width).clamp(0.0, 1.0);
            _updateColor();
          });
        },
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _GradientOpacityPainter(opacity: _opacity),
            child: Stack(
              children: [
                Positioned(
                  left: (_opacity * width) - 10, // Adjust trackball position
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.transparent,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _GradientOpacityPainter extends CustomPainter {
  final double opacity;

  _GradientOpacityPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Define the corner radius
    const double radius = 10.0;

    // Create the gradient from white -> hue color
    const gradient = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.black,
      ],
    );

    // Create a rounded rectangle
    final roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    // Draw the horizontal saturation gradient
    paint.shader =
        gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(roundedRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GradientHuePainter extends CustomPainter {
  final double hue;

  _GradientHuePainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Define the corner radius
    const double radius = 10.0;

    // Create the gradient from white -> hue color
    const gradient = LinearGradient(
      colors: [
        Colors.red,
        Colors.yellow,
        Colors.green,
        Colors.cyan,
        Colors.blue,
        Colors.purple,
        Colors.red,
      ],
    );

    // Create a rounded rectangle
    final roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    // Draw the horizontal saturation gradient
    paint.shader =
        gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(roundedRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GradientPainter extends CustomPainter {
  final double hue;

  _GradientPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Define the corner radius
    const double radius = 10.0;

    // Create the gradient from white -> hue color
    final gradient = LinearGradient(
      colors: [
        Colors.white,
        HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
      ],
    );

    const verticalGradient = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.black,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    // Create a rounded rectangle
    final roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    // Draw the horizontal saturation gradient
    paint.shader =
        gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(roundedRect, paint);

    // Draw the vertical brightness gradient
    paint.shader = verticalGradient
        .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(roundedRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
