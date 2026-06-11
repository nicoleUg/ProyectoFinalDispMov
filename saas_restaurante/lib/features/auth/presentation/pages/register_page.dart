import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFB02F00);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // Max width para web/tablet
          child: Card(
            elevation: 8,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Si la pantalla es ancha (Web/Tablet), dividimos en 2 columnas
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(child: _buildBrandPanel(primaryColor)),
                      Expanded(child: _buildFormPanel(primaryColor)),
                    ],
                  );
                }
                // Si es celular, solo mostramos el formulario
                return _buildFormPanel(primaryColor);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandPanel(Color primaryColor) {
    return Container(
      color: primaryColor,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Restaurante X',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Unete',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPanel(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text('entra', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          
          TextFormField(decoration: const InputDecoration(labelText: 'Full Name', border: UnderlineInputBorder())),
          const SizedBox(height: 16),
          TextFormField(decoration: const InputDecoration(labelText: 'Email Address', border: UnderlineInputBorder())),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', border: UnderlineInputBorder()),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
              onPressed: () {},
              child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}