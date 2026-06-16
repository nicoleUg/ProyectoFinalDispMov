import 'package:flutter/material.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFB02F00);
    final background = const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const Icon(Icons.menu, color: Colors.black87),
        title: Text('BurgerDash', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
        actions: const [
          Icon(Icons.shopping_basket, color: Colors.black87),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              children: [
                // --- Status Hero Card ---
                _buildStatusHero(primary),
                const SizedBox(height: 24),
                
                // --- MD3 Timeline Card ---
                _buildTimelineCard(primary),
                const SizedBox(height: 24),

                // --- Order Summary Card ---
                _buildOrderSummary(primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHero(Color primary) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=500'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
          const Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preparing Order', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Estimated arrival: 7:45 PM', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineCard(Color primary) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE4BEB4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Línea de fondo
            Container(height: 4, color: Colors.grey.shade200),
            // Línea activa (Progreso al 50% como el HTML)
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.5,
              child: Container(height: 4, color: primary),
            ),
            // Nodos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNode(Icons.check, 'Received', true, primary),
                _buildNode(Icons.skillet, 'Preparing', true, primary, isActive: true),
                _buildNode(Icons.directions_bike, 'Ready', false, primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(IconData icon, String label, bool isCompleted, Color primary, {bool isActive = false}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted ? primary : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: primary, width: 2) : null,
          ),
          child: Icon(icon, color: isCompleted ? Colors.white : Colors.grey, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildOrderSummary(Color primary) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE4BEB4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ORDER NUMBER', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
                    Text('#1234', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton(onPressed: () {}, child: Text('Receipt', style: TextStyle(color: primary))),
              ],
            ),
            const Divider(height: 32),
            _buildItemRow('1x', 'Smokehouse Burger'),
            _buildItemRow('1x', 'Crispy Fries'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE4E2E1), foregroundColor: Colors.black87),
                onPressed: () {},
                icon: const Icon(Icons.call),
                label: const Text('Call Restaurant'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String qty, String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
            child: Text(qty, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}