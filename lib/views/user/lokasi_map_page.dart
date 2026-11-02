import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LokasiMapPage extends StatefulWidget {
  const LokasiMapPage({super.key});

  @override
  State<LokasiMapPage> createState() => _LokasiMapPageState();
}

class _LokasiMapPageState extends State<LokasiMapPage> {
  final MapController _mapController = MapController();

  final LatLng _lokasiGoldenPhysio = const LatLng(
    -6.976748026405756,
    109.63140580264606,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 2,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A8E8), Color(0xFF006699)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              width: 40,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.healing, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'LOKASI GOLDEN PHYSIO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _lokasiGoldenPhysio,
              initialZoom: 16.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.golden_physio',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _lokasiGoldenPhysio,
                    width: 80.0,
                    height: 80.0,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 45,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'btnZoomIn',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0083b0),
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_lokasiGoldenPhysio, currentZoom + 1);
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'btnZoomOut',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0083b0),
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_lokasiGoldenPhysio, currentZoom - 1);
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
