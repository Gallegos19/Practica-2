import 'package:flutter/material.dart';
import 'package:xuma/core/services/firebase_service.dart';
import 'package:xuma/core/services/security_service.dart';

class SecurityTestWidget extends StatefulWidget {
  const SecurityTestWidget({Key? key}) : super(key: key);

  @override
  State<SecurityTestWidget> createState() => _SecurityTestWidgetState();
}

class _SecurityTestWidgetState extends State<SecurityTestWidget> {
  Map<String, dynamic>? _securityStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await SecurityService.getSecurityStatus();
      setState(() => _securityStatus = status);
    } catch (e) {
      print('Error loading security status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testEmergencyWipe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Prueba de Borrado'),
        content: const Text(
          '¿Estás seguro de que quieres probar el borrado de emergencia?\n\n'
          'Esto eliminará TODOS los datos de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      
      await SecurityService.emergencyDataWipe();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚨 Borrado de emergencia completado'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        
        await _loadSecurityStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: Colors.orange.shade50,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🛡️ Panel de Seguridad FCM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Información del estado
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_securityStatus != null) ...[
                _buildStatusRow('📱 Datos de usuario', 
                    _securityStatus!['hasUserData'] == true ? 'Presentes' : 'Ausentes',
                    _securityStatus!['hasUserData'] == true ? Colors.green : Colors.red),
                    
                _buildStatusRow('🔐 Datos de auth', 
                    _securityStatus!['hasAuthData'] == true ? 'Presentes' : 'Ausentes',
                    _securityStatus!['hasAuthData'] == true ? Colors.green : Colors.red),
                    
                _buildStatusRow('🗂️ Claves almacenadas', 
                    '${_securityStatus!['storedKeysCount']} claves',
                    Colors.blue),

                if (_securityStatus!['lastEmergencyWipe'] != null)
                  _buildStatusRow('🚨 Último borrado', 
                      _formatDate(_securityStatus!['lastEmergencyWipe']),
                      Colors.red),
              ],

              const SizedBox(height: 16),

              // Información de cómo enviar la notificación
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Para probar FCM, envía:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Title: "peligro"',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      'Message: "por seguridad tus datos seran borrados"',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Botones de acción
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadSecurityStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _testEmergencyWipe,
                    icon: const Icon(Icons.warning),
                    label: const Text('Test Borrado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final token = await FirebaseService.getToken();
                      if (mounted && token != null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('🔥 FCM Token'),
                            content: SelectableText(
                              token,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.token),
                    label: const Text('Ver Token'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Los mensajes FCM se procesan automáticamente',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade700,
                          fontStyle: FontStyle.italic,
                        ),
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

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }
}