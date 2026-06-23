import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFB02F00);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Términos y Condiciones', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Términos y Condiciones de Uso del Servicio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: 23 de Junio, 2026',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Aceptación de los Términos',
              'Al descargar, instalar o utilizar la aplicación móvil de Restaurante SaaS, el usuario acepta de manera expresa y sin reservas los presentes Términos y Condiciones. Si no está de acuerdo con alguna de las cláusulas, por favor absténgase de utilizar el servicio.',
            ),
            _buildSection(
              '2. Registro y Seguridad de la Cuenta',
              'El usuario es responsable de mantener la confidencialidad de sus credenciales de inicio de sesión y de todas las actividades realizadas en su cuenta. El restaurante no se hace responsable por pérdidas resultantes del uso no autorizado de su información de acceso.',
            ),
            _buildSection(
              '3. Pedidos, Precios y Pagos',
              'Todos los precios mostrados en la aplicación están expresados en Bolivianos (Bs.) e incluyen impuestos correspondientes. El restaurante se reserva el derecho de modificar el menú y los precios sin previo aviso. Los pagos se procesan de forma local en la mesa o contra entrega según el flujo establecido en la app.',
            ),
            _buildSection(
              '4. Entregas y Tiempos de Espera',
              'Los tiempos de preparación y entrega indicados son estimaciones aproximadas basadas en la carga actual de la cocina. Hacemos nuestro mejor esfuerzo para cumplir con los tiempos establecidos, sin embargo, retrasos fortuitos ajenos a nuestro control no darán derecho a reembolsos totales automáticos.',
            ),
            _buildSection(
              '5. Política de Cancelaciones y Devoluciones',
              'Una vez que el pedido ingresa a la fase de "En Preparación" en la cocina, no se aceptarán cancelaciones ni modificaciones. Cualquier disconformidad con el producto final deberá ser comunicada inmediatamente al personal de servicio en el restaurante o al transportista para su evaluación y resolución.',
            ),
            _buildSection(
              '6. Protección de Datos y Privacidad',
              'Toda la información personal ingresada en la app, incluyendo el nombre de usuario y almacenamiento de mesa local (en SecureStorage), se almacena de forma segura y se utiliza únicamente para proveer un servicio de pedido rápido y personalizado. No compartimos sus datos con terceros con fines publicitarios.',
            ),
            _buildSection(
              '7. Modificaciones a los Términos',
              'Nos reservamos el derecho de actualizar estos términos en cualquier momento. La continuación del uso del servicio después de dichos cambios constituye la aceptación del usuario de las nuevas condiciones.',
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '© 2026 Restaurante SaaS. Todos los derechos reservados.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
