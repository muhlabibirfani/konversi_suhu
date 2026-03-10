import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TemperatureApp());
}

class TemperatureApp extends StatelessWidget {
  const TemperatureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Konversi Suhu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.dark,
        ),
      ),
      home: const TemperatureConverterPage(),
    );
  }
}

enum TempUnit { celsius, fahrenheit, kelvin, rankine }

extension TempUnitExt on TempUnit {
  String get symbol {
    switch (this) {
      case TempUnit.celsius:
        return '°C';
      case TempUnit.fahrenheit:
        return '°F';
      case TempUnit.kelvin:
        return 'K';
      case TempUnit.rankine:
        return '°R';
    }
  }

  String get name {
    switch (this) {
      case TempUnit.celsius:
        return 'Celsius';
      case TempUnit.fahrenheit:
        return 'Fahrenheit';
      case TempUnit.kelvin:
        return 'Kelvin';
      case TempUnit.rankine:
        return 'Rankine';
    }
  }

  Color get color {
    switch (this) {
      case TempUnit.celsius:
        return const Color(0xFF4FC3F7);
      case TempUnit.fahrenheit:
        return const Color(0xFFFF7043);
      case TempUnit.kelvin:
        return const Color(0xFFAB47BC);
      case TempUnit.rankine:
        return const Color(0xFF66BB6A);
    }
  }

  IconData get icon {
    switch (this) {
      case TempUnit.celsius:
        return Icons.ac_unit;
      case TempUnit.fahrenheit:
        return Icons.local_fire_department;
      case TempUnit.kelvin:
        return Icons.science;
      case TempUnit.rankine:
        return Icons.thermostat;
    }
  }
}

class TemperatureConverter {
  static double toCelsius(double value, TempUnit from) {
    switch (from) {
      case TempUnit.celsius:
        return value;
      case TempUnit.fahrenheit:
        return (value - 32) * 5 / 9;
      case TempUnit.kelvin:
        return value - 273.15;
      case TempUnit.rankine:
        return (value - 491.67) * 5 / 9;
    }
  }

  static double fromCelsius(double celsius, TempUnit to) {
    switch (to) {
      case TempUnit.celsius:
        return celsius;
      case TempUnit.fahrenheit:
        return celsius * 9 / 5 + 32;
      case TempUnit.kelvin:
        return celsius + 273.15;
      case TempUnit.rankine:
        return (celsius + 273.15) * 9 / 5;
    }
  }

  static double convert(double value, TempUnit from, TempUnit to) {
    final celsius = toCelsius(value, from);
    return fromCelsius(celsius, to);
  }
}

class TemperatureConverterPage extends StatefulWidget {
  const TemperatureConverterPage({super.key});

  @override
  State<TemperatureConverterPage> createState() =>
      _TemperatureConverterPageState();
}

class _TemperatureConverterPageState extends State<TemperatureConverterPage>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  TempUnit _fromUnit = TempUnit.celsius;
  TempUnit _toUnit = TempUnit.fahrenheit;
  double? _result;
  late AnimationController _pulseController;
  late AnimationController _swapController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _swapAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _swapAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _pulseController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  void _convert() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() => _result = null);
      return;
    }
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value != null) {
      setState(() {
        _result = TemperatureConverter.convert(value, _fromUnit, _toUnit);
      });
    }
  }

  void _swapUnits() async {
    await _swapController.forward();
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _convert();
    _swapController.reset();
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  String _getTemperatureDescription(double celsius) {
    if (celsius <= -40) return '❄️ Sangat Dingin Ekstrem';
    if (celsius <= 0) return '🧊 Di Bawah Titik Beku';
    if (celsius <= 10) return '🌨️ Dingin';
    if (celsius <= 20) return '🌤️ Sejuk';
    if (celsius <= 30) return '☀️ Nyaman';
    if (celsius <= 40) return '🌡️ Hangat';
    if (celsius <= 60) return '🔥 Panas';
    return '🌋 Sangat Panas Ekstrem';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D1A),
              Color(0xFF1A0D2E),
              Color(0xFF0D1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildThermometerVisual(),
                      const SizedBox(height: 32),
                      _buildConverterCard(),
                      const SizedBox(height: 24),
                      _buildResultCard(),
                      const SizedBox(height: 24),
                      _buildQuickReference(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.thermostat, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'ThermoConvert',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Konversi suhu dengan mudah & cepat',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildThermometerVisual() {
    final celsius = _result != null
        ? TemperatureConverter.convert(_result!, _toUnit, TempUnit.celsius)
        : (_inputController.text.isNotEmpty
            ? TemperatureConverter.convert(
                double.tryParse(_inputController.text.replaceAll(',', '.')) ?? 0,
                _fromUnit,
                TempUnit.celsius)
            : 0.0);

    final clampedTemp = celsius.clamp(-40.0, 100.0);
    final fillPercent = (clampedTemp + 40) / 140;

    Color tempColor;
    if (celsius <= 0) {
      tempColor = const Color(0xFF4FC3F7);
    } else if (celsius <= 30) {
      tempColor = const Color(0xFF66BB6A);
    } else if (celsius <= 60) {
      tempColor = const Color(0xFFFFB74D);
    } else {
      tempColor = const Color(0xFFFF5722);
    }

    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _result != null ? _pulseAnimation.value : 1.0,
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tempColor.withOpacity(0.15),
                    tempColor.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: tempColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Fill bar
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Container(
                      height: 100,
                      width: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          height: 100 * fillPercent,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                tempColor,
                                tempColor.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Text info
                  Positioned(
                    left: 60,
                    top: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _result != null
                              ? '${_formatResult(_result!)} ${_toUnit.symbol}'
                              : '-- ${_toUnit.symbol}',
                          style: TextStyle(
                            color: _result != null ? tempColor : Colors.white.withOpacity(0.3),
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_result != null)
                          Text(
                            _getTemperatureDescription(celsius),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          Text(
                            'Masukkan suhu untuk melihat hasil',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConverterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          // From unit selector
          _buildUnitSelector('Dari', _fromUnit, (unit) {
            setState(() => _fromUnit = unit!);
            _convert();
          }),
          const SizedBox(height: 16),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _fromUnit.color.withOpacity(0.4)),
            ),
            child: TextField(
              controller: _inputController,
              onChanged: (_) => _convert(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              style: TextStyle(
                color: _fromUnit.color,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                suffixText: _fromUnit.symbol,
                suffixStyle: TextStyle(
                  color: _fromUnit.color.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Swap button
          GestureDetector(
            onTap: _swapUnits,
            child: AnimatedBuilder(
              animation: _swapAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _swapAnimation.value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // To unit selector
          _buildUnitSelector('Ke', _toUnit, (unit) {
            setState(() => _toUnit = unit!);
            _convert();
          }),
        ],
      ),
    );
  }

  Widget _buildUnitSelector(
      String label, TempUnit selected, ValueChanged<TempUnit?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: TempUnit.values.map((unit) {
            final isSelected = unit == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(unit),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? unit.color.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? unit.color
                          : Colors.white.withOpacity(0.1),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        unit.icon,
                        color: isSelected
                            ? unit.color
                            : Colors.white.withOpacity(0.3),
                        size: 18,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit.symbol,
                        style: TextStyle(
                          color: isSelected
                              ? unit.color
                              : Colors.white.withOpacity(0.3),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _result != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _toUnit.color.withOpacity(0.15),
              _toUnit.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _toUnit.color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _toUnit.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_toUnit.icon, color: _toUnit.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hasil Konversi',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatResult(_result!)} ${_toUnit.symbol}',
                    style: TextStyle(
                      color: _toUnit.color,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    _toUnit.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // All conversions mini
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: TempUnit.values
                  .where((u) => u != _toUnit)
                  .map((u) {
                final val = TemperatureConverter.convert(
                  double.tryParse(_inputController.text.replaceAll(',', '.')) ?? 0,
                  _fromUnit,
                  u,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${_formatResult(val)}${u.symbol}',
                    style: TextStyle(
                      color: u.color.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
// buat referensi untuk konversi suhu secara langsung:D
  Widget _buildQuickReference() {
    final references = [
      {'name': 'Air Membeku', 'celsius': 0.0, 'emoji': '🧊'},
      {'name': 'Suhu Ruangan', 'celsius': 22.0, 'emoji': '🏠'},
      {'name': 'Suhu Tubuh', 'celsius': 37.0, 'emoji': '🌡️'},
      {'name': 'Air Mendidih', 'celsius': 100.0, 'emoji': '♨️'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REFERENSI CEPAT',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        ...references.map((ref) {
          final celsius = ref['celsius'] as double;
          final fromVal = TemperatureConverter.fromCelsius(celsius, _fromUnit);
          final toVal = TemperatureConverter.fromCelsius(celsius, _toUnit);

          return GestureDetector(
            onTap: () {
              _inputController.text = _formatResult(fromVal);
              _convert();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Text(ref['emoji'] as String, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ref['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${_formatResult(fromVal)}${_fromUnit.symbol}',
                    style: TextStyle(
                      color: _fromUnit.color.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatResult(toVal)}${_toUnit.symbol}',
                    style: TextStyle(
                      color: _toUnit.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}