import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFB02F00);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Acerca de Nosotros', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner/Header Image or Icon representing the restaurant
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.restaurant_menu_rounded, size: 56, color: primaryColor),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Restaurante SaaS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pasión por el buen sabor desde 2026',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Misión & Visión Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restaurant, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Nuestra Filosofía',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'En Restaurante SaaS nos dedicamos a transformar cada pedido en una experiencia culinaria premium. Combinamos ingredientes locales frescos con tecnologías ágiles para traerte lo mejor de la cocina directo a tu mesa o a la puerta de tu hogar.',
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Historia Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Nuestra Historia',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nacimos como un proyecto culinario enfocado en modernizar el servicio gastronómico. Con el compromiso inquebrantable por el sabor, la calidad y el servicio al cliente, nos hemos convertido en la opción preferida de miles de comensales locales.',
                      style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contacto Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_support_outlined, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Contacto y Soporte',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.location_on_outlined, color: primaryColor),
                      title: const Text('Dirección Principal'),
                      subtitle: const Text('Av. Principal de la Comida #123, Zona Culinaria'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.phone_outlined, color: primaryColor),
                      title: const Text('Teléfono de Pedidos'),
                      subtitle: const Text('+591 76543210'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.email_outlined, color: primaryColor),
                      title: const Text('Correo Electrónico'),
                      subtitle: const Text('soporte@restaurantesaas.com'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Footer version
            const Center(
              child: Text(
                'Versión 1.0.0 (BETA)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
