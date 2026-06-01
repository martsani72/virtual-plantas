import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class PlantAnimator extends StatefulWidget {
  final String carpetaPlanta;
  final int totalFrames;
  final int categoryRigidez;
  final double escala;
  final double dimensionFisica;
  final VoidCallback onCerrar; // Renombrado a onCerrar

  const PlantAnimator({
    Key? key,
    required this.carpetaPlanta,
    required this.totalFrames,
    required this.categoryRigidez,
    required this.escala,
    required this.dimensionFisica,
    required this.onCerrar,
  }) : super(key: key);

  @override
  State<PlantAnimator> createState() => _PlantAnimatorState();
}

class _PlantAnimatorState extends State<PlantAnimator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;
  bool _mostrarMenuCerrar = false;

  @override
  void initState() {
    super.initState();

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
          onLongPress: () {
            setState(() {
              _mostrarMenuCerrar = !_mostrarMenuCerrar;
            });
          },
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: widget.dimensionFisica,
                  height: widget.dimensionFisica,
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
              ),
              
              // Menú flotante transformado en "Quitar Planta"
              if (_mostrarMenuCerrar)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A2C2C).withOpacity(0.95), // Color un toque más rojizo/oscuro de alerta
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 18),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: widget.onCerrar, // Ejecuta el windowManager.close() de esa ventana
                        ),
                        const SizedBox(width: 8),
                        const Text("Quitar Planta", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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