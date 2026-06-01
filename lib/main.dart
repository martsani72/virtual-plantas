import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'plant_widget.dart';

class PlantaConfig {
  final String id;
  final String nombre;
  final int frames;
  final int rigidez;
  double escala;

  PlantaConfig({
    required this.id,
    required this.nombre,
    required this.frames,
    required this.rigidez,
    required this.escala,
  });
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  String? carpetaPlanta;
  int totalFrames = 9;
  int categoryRigidez = 3;
  double escala = 1.0;

  for (var arg in args) {
    if (arg.startsWith('--id=')) carpetaPlanta = arg.split('=')[1];
    if (arg.startsWith('--frames=')) totalFrames = int.tryParse(arg.split('=')[1]) ?? 9;
    if (arg.startsWith('--rigidez=')) categoryRigidez = int.tryParse(arg.split('=')[1]) ?? 3;
    if (arg.startsWith('--escala=')) escala = double.tryParse(arg.split('=')[1]) ?? 1.0;
  }

  bool esInstanciaPlanta = carpetaPlanta != null;

  Size tamanoInicial;
  Size minimoSize;
  Size maximoSize;

  if (esInstanciaPlanta) {
    double dimensionSincronizada = 360.0 * escala;
    tamanoInicial = Size(dimensionSincronizada, dimensionSincronizada);
    minimoSize = Size(dimensionSincronizada, dimensionSincronizada);
    maximoSize = Size(dimensionSincronizada, dimensionSincronizada);
  } else {
    tamanoInicial = const Size(280, 600);
    minimoSize = const Size(280, 500);
    maximoSize = const Size(280, 800);
  }

  WindowOptions windowOptions = WindowOptions(
    size: tamanoInicial,
    minimumSize: minimoSize,
    maximumSize: maximoSize,
    center: !esInstanciaPlanta,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setResizable(false);
    await windowManager.setHasShadow(false);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp(
    idPlanta: carpetaPlanta,
    frames: totalFrames,
    rigidez: categoryRigidez,
    escala: escala,
  ));
}

class MyApp extends StatefulWidget {
  final String? idPlanta;
  final int frames;
  final int rigidez;
  final double escala;

  const MyApp({
    Key? key,
    this.idPlanta,
    this.frames = 9,
    this.rigidez = 3,
    this.escala = 1.0,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<PlantaConfig> misPlantas = [
    PlantaConfig(id: 'plant_0001', nombre: 'Palmerita', frames: 9, rigidez: 2, escala: 0.9),
    PlantaConfig(id: 'plant_0002', nombre: 'Culandrillo', frames: 9, rigidez: 1, escala: 0.6),
    PlantaConfig(id: 'plant_0003', nombre: 'Begonia Red', frames: 9, rigidez: 3, escala: 0.8),
    PlantaConfig(id: 'plant_0004', nombre: 'Monstera', frames: 9, rigidez: 3, escala: 0.85),
    PlantaConfig(id: 'plant_0005', nombre: 'Lengua de Suegra', frames: 9, rigidez: 4, escala: 0.75),
    PlantaConfig(id: 'plant_0006', nombre: 'Bonsai Acer', frames: 9, rigidez: 4, escala: 0.75), 
    PlantaConfig(id: 'plant_0007', nombre: 'Calathea', frames: 9, rigidez: 4, escala: 0.75),
    PlantaConfig(id: 'plant_0008', nombre: 'Bonsai Junipero', frames: 9, rigidez: 4, escala: 0.75),
    PlantaConfig(id: 'plant_0009', nombre: 'Alocasia Marmolada', frames: 9, rigidez: 4, escala: 0.75),
    PlantaConfig(id: 'plant_0010', nombre: 'Gomero', frames: 9, rigidez: 4, escala: 0.8),       
    PlantaConfig(id: 'plant_0011', nombre: 'Helecho Azul', frames: 9, rigidez: 2, escala: 0.85),
    PlantaConfig(id: 'plant_0012', nombre: 'Bonsai Bosque Acer', frames: 9, rigidez: 2, escala: 0.85),  
  ];

  final List<String> proximasPremium = [
    "Orquídea Negra",
    "Bonsái Secuoya"
  ];

  static int cantidadLanzadas = 0;
  String queryBusqueda = "";

  void lanzarNuevaInstanciaPlanta(PlantaConfig planta) async {
    cantidadLanzadas++;
    String rutaEjecutable = Platform.resolvedExecutable;

    await Process.start(
      rutaEjecutable,
      [
        '--id=${planta.id}',
        '--frames=${planta.frames}',
        '--rigidez=${planta.rigidez}',
        '--escala=${planta.escala}',
      ],
      mode: ProcessStartMode.detached,
    );

    Future.delayed(const Duration(milliseconds: 250), () async {
      double despX = (cantidadLanzadas % 6) * 40.0;
      double despY = (cantidadLanzadas % 6) * 40.0;
      var pos = await windowManager.getPosition();
      await windowManager.setPosition(Offset(pos.dx + despX, pos.dy + despY));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.idPlanta != null) {
      double dimensionSincronizada = 360.0 * widget.escala;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: Colors.transparent),
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            width: dimensionSincronizada,
            height: dimensionSincronizada,
            child: PlantAnimator(
              carpetaPlanta: widget.idPlanta!,
              totalFrames: widget.frames,
              categoryRigidez: widget.rigidez,
              escala: widget.escala,
              dimensionFisica: dimensionSincronizada,
              onCerrar: () => windowManager.close(),
            ),
          ),
        ),
      );
    }

    const Color colorBosque = Color(0xFF44562F);
    const Color colorEsparrago = Color(0xFF83934D);
    const Color colorClaroPino = Color(0xFFB8C88D);
    const Color colorTextoBlanco = Color(0xFFF4F6F0);

    final plantasFiltradas = misPlantas.where((p) {
      return p.nombre.toLowerCase().contains(queryBusqueda.toLowerCase());
    }).toList();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorClaroPino,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, spreadRadius: 1)],
          ),
          child: Column(
            children: [
              // Barra superior integrada
              GestureDetector(
                onPanStart: (_) => windowManager.startDragging(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: const BoxDecoration(
                    color: colorEsparrago,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_florist_outlined, color: colorBosque, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Virtual Plantas', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorBosque, letterSpacing: -0.5),
                      ),
                      const Spacer(),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.remove, size: 16, color: colorBosque),
                        onPressed: () => windowManager.minimize(),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, size: 16, color: colorBosque),
                        onPressed: () => windowManager.close(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Buscador integrado
              Container(
                color: colorEsparrago,
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        queryBusqueda = val;
                      });
                    },
                    style: const TextStyle(fontSize: 12, color: colorBosque),
                    decoration: InputDecoration(
                      hintText: 'Buscar planta...',
                      hintStyle: const TextStyle(color: colorBosque, fontSize: 12),
                      prefixIcon: const Icon(Icons.search, size: 14, color: colorBosque),
                      prefixIconConstraints: const BoxConstraints(minWidth: 28),
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: colorClaroPino,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
              
              // Lista con Scrollbar y el rastreador de errores integrado de forma correcta
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    itemCount: plantasFiltradas.isEmpty ? 1 : plantasFiltradas.length,
                    itemBuilder: (context, index) {
                      if (plantasFiltradas.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "No se hallaron plantas", 
                              style: TextStyle(fontSize: 11, color: colorBosque, fontWeight: FontWeight.bold)
                            ),
                          ),
                        );
                      }

                      final planta = plantasFiltradas[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: colorEsparrago,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: colorClaroPino,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/plant_frames/${planta.id}/frame_000.png',
                                fit: BoxFit.contain,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                  // PRINTS CORRECTOS PARA DEPURAR EN CONSOLA
                                  print("❌ ERROR CARGANDO IMAGEN EN [${planta.id}]: $error");
                                  print("🔍 RUTA CORRUPTA DETECTADA: assets/plant_frames/${planta.id}/frame_000.png");
                                  return const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    planta.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: colorTextoBlanco, fontSize: 12, overflow: TextOverflow.ellipsis),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            trackHeight: 1.5,
                                            activeTrackColor: colorBosque,
                                            inactiveTrackColor: colorClaroPino,
                                            thumbColor: colorBosque,
                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                                          ),
                                          child: Slider(
                                            value: planta.escala,
                                            min: 0.4,
                                            max: 1.6,
                                            onChanged: (newValue) {
                                              setState(() {
                                                planta.escala = newValue;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Text("${(planta.escala * 100).round()}%", style: const TextStyle(fontSize: 9, color: colorBosque, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 22,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorBosque,
                                        foregroundColor: colorTextoBlanco,
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      onPressed: () => lanzarNuevaInstanciaPlanta(planta),
                                      child: const Text('Lanzar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // SECCIÓN ECOMMERCE FIJA ABAJO
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: colorEsparrago,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text("Mercado de Plantas", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorTextoBlanco)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: colorClaroPino, borderRadius: BorderRadius.circular(4)),
                          child: const Text("PRÓXIMAMENTE", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: colorBosque)),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    ...proximasPremium.map((nombrePlanta) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: colorClaroPino, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, size: 11, color: colorBosque),
                          const SizedBox(width: 6),
                          Text(nombrePlanta, style: const TextStyle(color: colorBosque, fontSize: 10, fontWeight: FontWeight.w500)),
                          const Spacer(),
                          const Text(r"$0.99", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorBosque)),
                        ],
                      ),
                    )).toList(),
                    
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_bag_outlined, size: 12),
                        label: const Text('Visitar Tienda', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorClaroPino,
                          foregroundColor: colorBosque,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Conectando con la tienda...'))
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}