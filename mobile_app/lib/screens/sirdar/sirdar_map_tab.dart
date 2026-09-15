import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SirdarMapTab extends StatelessWidget {
  const SirdarMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search location or asset...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Mock Map Placeholder
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[200],
                child: Image.network(
                  "https://static.vecteezy.com/system/resources/previews/000/616/505/original/top-view-of-quarry-mining-flat-design-vector.jpg",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.map, size: 100, color: Colors.grey),
                  ),
                ),
              ),
              
              // Mock Markers
              Positioned(
                top: 100,
                left: 150,
                child: _buildMapMarker(context, "Face 4A", AppTheme.redDanger),
              ),
              Positioned(
                bottom: 200,
                right: 80,
                child: _buildMapMarker(context, "Stockpile 2", AppTheme.amberAccent),
              ),
              Positioned(
                top: 250,
                left: 80,
                child: _buildMapMarker(context, "Pump House", AppTheme.greenVerified),
              ),
              
              // Map Controls
              Positioned(
                bottom: 100,
                right: 16,
                child: Column(
                  children: [
                    _buildMapAction(Icons.my_location),
                    const SizedBox(height: 12),
                    _buildMapAction(Icons.layers),
                    const SizedBox(height: 12),
                    _buildMapAction(Icons.add),
                    const SizedBox(height: 2),
                    _buildMapAction(Icons.remove),
                  ],
                ),
              ),
              
              // Legend / Status Summary
              Positioned(
                bottom: 100,
                left: 16,
                right: 80,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(AppTheme.redDanger, "2 Hazards"),
                      _buildLegendItem(AppTheme.amberAccent, "5 Tasks"),
                      _buildLegendItem(AppTheme.greenVerified, "Safe"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapMarker(BuildContext context, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
          ),
          child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        Icon(Icons.location_on, color: color, size: 30),
      ],
    );
  }

  Widget _buildMapAction(IconData icon) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.blueGrey),
        onPressed: () {},
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
