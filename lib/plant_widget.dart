import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class PlantAnimator extends StatefulWidget {
  final String carpetaPlanta;
  final int totalFrames;
  final int categoryRigidez;
  final double escala;
  final VoidCallback onCerrar; // Renombrado a onCerrar

  const PlantAnimator({
    Key? key,
    required this.carpetaPlanta,
    required this.totalFrames,
    required this.categoryRigidez,
    required this.escala,
    required this.onCerrar,
  }) : super(key: key);

  @override
  State<PlantAnimator> createState() => _PlantAnimatorState();
}

class _PlantAnimatorState extends State<PlantAnimator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;
  bool _mostrarMenuCerrar = false;
  late double _escalaActual;

  @override
  void initState() {
    super.initState();
    _escalaActual = widget.escala;

    Duration duracionAnimacion;
    switch (widget.categoryRigidez) {
      case 1: duracionAnimacion = const Duration(milliseconds: 1200); break;
      case 2: duracionAnimacion = const Duration(milliseconds: 800); break;
      case 3: duracionAnimacion = const Duration(milliseconds: 550); break;
      case 4: default: duracionAnimacion = const Duration(milliseconds: 250); break;
    }

    _controller = AnimationController(vsync: this, duration: duracionAnimacion);
    _controller.addListener(() {
      setState(() {
        _currentFrame = (_controller.value * (widget.totalFrames - 1)).round();
      });
    });
    _controller.drive(CurveTween(curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dispararBamboleo() {
    if (!_controller.isAnimating) {
      _controller.forward(from: 0.0).then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    String frameFormateado = _currentFrame.toString().padLeft(3, '0');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MouseRegion(
        onEnter: (_) => _dispararBamboleo(),
        child: GestureDetector(
          onPanStart: (_) => windowManager.startDragging(), 
          onSecondaryTap: () {
            setState(() {
              _mostrarMenuCerrar = !_mostrarMenuCerrar;
            });
          },
          onTap: () {
            if (_mostrarMenuCerrar) {
              setState(() {
                _mostrarMenuCerrar = false;
              });
            }
          },
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  'assets/plant_frames/${widget.carpetaPlanta}/frame_$frameFormateado.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.red.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                      ),
                    );
                  },
                ),
              ),
              
              if (_mostrarMenuCerrar)
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 165,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF83934D), // colorEsparrago
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Text("Tamaño", style: TextStyle(color: Color(0xFFF4F6F0), fontSize: 11, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text("${(_escalaActual * 100).round()}%", style: const TextStyle(fontSize: 9, color: Color(0xFF44562F), fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _mostrarMenuCerrar = false;
                                });
                              },
                              child: const Icon(Icons.cancel, color: Color(0xFF44562F), size: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 1.5,
                            activeTrackColor: const Color(0xFF44562F), // colorBosque
                            inactiveTrackColor: const Color(0xFFB8C88D), // colorClaroPino
                            thumbColor: const Color(0xFF44562F),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                          ),
                          child: Slider(
                            value: _escalaActual,
                            min: 0.5,
                            max: 1.6,
                            onChanged: (newValue) async {
                              setState(() {
                                _escalaActual = newValue;
                              });
                              double nuevaDimension = 360.0 * _escalaActual;
                              await windowManager.setSize(Size(nuevaDimension, nuevaDimension));
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 24,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.close, color: Color(0xFFF4F6F0), size: 14),
                            label: const Text("Quitar Planta", style: TextStyle(color: Color(0xFFF4F6F0), fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF44562F), // colorBosque
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: widget.onCerrar,
                          ),
                        ),
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
}