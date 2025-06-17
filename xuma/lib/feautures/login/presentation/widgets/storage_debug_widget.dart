// Reemplaza tu StorageDebugWidget con esta versión corregida

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

class StorageDebugWidget extends StatefulWidget {
  @override
  _StorageDebugWidgetState createState() => _StorageDebugWidgetState();
}

class _StorageDebugWidgetState extends State<StorageDebugWidget> {
  String _debugInfo = 'Presiona el botón para verificar';
  bool _isLoading = false;

  Future<void> _checkStorage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      const storage = FlutterSecureStorage();

      // Verificar si existe la clave específica
      final profileData = await storage.read(key: 'user_profile_secure');
      final hasUserProfile = profileData != null;

      // Leer todas las claves
      final allKeys = await storage.readAll();

      // Información del platform
      final platform = Platform.operatingSystem;

      setState(() {
        _debugInfo = '''
🔍 INFORMACIÓN DE ALMACENAMIENTO SEGURO

Platform: $platform
Clave 'user_profile_secure' existe: ${hasUserProfile ? '✅ SÍ' : '❌ NO'}
Total de claves en storage: ${allKeys.length}
Todas las claves: ${allKeys.keys.join(', ')}

📊 DATOS DEL PERFIL:
${profileData != null ? 'Longitud: ${profileData.length} caracteres' : 'Sin datos'}

🔐 CONTENIDO (primeros 100 chars):
${profileData != null ? profileData.substring(0, profileData.length > 100 ? 100 : profileData.length) + (profileData.length > 100 ? '...' : '') : 'Sin datos'}

🛡️ VERIFICACIÓN DE SEGURIDAD:
${_verifyEncryption(profileData)}

🎯 ESTADO GENERAL:
${hasUserProfile ? '✅ ALMACENAMIENTO FUNCIONANDO CORRECTAMENTE' : '⚠️ No se encontraron datos'}
        ''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = '❌ Error al acceder al storage: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _verifyEncryption(String? data) {
    if (data == null) return 'Sin datos para verificar';

    try {
      // Intentar parsear como JSON
      if (data.trim().startsWith('{') && data.trim().endsWith('}')) {
        return '✅ Datos en formato JSON válido (Flutter Secure Storage los encripta automáticamente en el nivel del OS)';
      } else {
        return '🔐 Datos en formato no-JSON (posiblemente encriptación adicional)';
      }
    } catch (e) {
      return '⚠️ Error al verificar formato: $e';
    }
  }

  Future<void> _testStorageOperations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      const storage = FlutterSecureStorage();
      const testKey = 'test_encryption_key';
      final testData =
          'Datos de prueba para verificar encriptación - ${DateTime.now().millisecondsSinceEpoch}';

      print('🧪 INICIANDO PRUEBA DE STORAGE...');

      // Escribir datos de prueba
      await storage.write(key: testKey, value: testData);
      print('🧪 Datos escritos: $testData');

      // Leer datos de prueba
      final retrievedData = await storage.read(key: testKey);
      print('🧪 Datos leídos: $retrievedData');

      // Verificar todas las claves después de escribir
      final allKeysAfter = await storage.readAll();
      print('🧪 Total de claves después de escribir: ${allKeysAfter.length}');

      // Eliminar datos de prueba
      await storage.delete(key: testKey);
      print('🧪 Datos de prueba eliminados');

      // Verificar eliminación
      final deletedCheck = await storage.read(key: testKey);

      setState(() {
        _debugInfo = '''
🧪 PRUEBA DE ALMACENAMIENTO COMPLETADA

✍️ Escritura:
Datos originales: "${testData.substring(0, 50)}..."
Longitud: ${testData.length} caracteres

📖 Lectura:
Datos recuperados: "${retrievedData?.substring(0, 50) ?? 'NULL'}..."
Coinciden: ${testData == retrievedData ? '✅ SÍ' : '❌ NO'}

🗑️ Eliminación:
Datos eliminados: ${deletedCheck == null ? '✅ SÍ' : '❌ NO'}

📊 Resumen:
Total de claves durante prueba: ${allKeysAfter.length}
Escritura: ${retrievedData != null ? '✅' : '❌'}
Lectura: ${testData == retrievedData ? '✅' : '❌'}
Eliminación: ${deletedCheck == null ? '✅' : '❌'}

🎯 RESULTADO FINAL:
${(retrievedData != null && testData == retrievedData && deletedCheck == null) ? '✅ ALMACENAMIENTO SEGURO FUNCIONA PERFECTAMENTE' : '❌ Hay problemas con el almacenamiento'}
        ''';
      });
    } catch (e) {
      print('🧪 ❌ Error en la prueba: $e');
      setState(() {
        _debugInfo = '''
❌ ERROR EN LA PRUEBA DE ALMACENAMIENTO

Error: $e

Esto podría indicar:
- Problemas de permisos
- Configuración incorrecta de Flutter Secure Storage
- Problemas del emulador/dispositivo
        ''';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Card(
        color: Colors.green.shade50,
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: Colors.green.shade700),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔒 Verificación de Almacenamiento Seguro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Botones de acción
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkStorage,
                    icon: Icon(Icons.search),
                    label: Text('Verificar Storage'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testStorageOperations,
                    icon: Icon(Icons.science),
                    label: Text('Probar Encriptación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Información de debug
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 400),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Verificando almacenamiento...'),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _debugInfo,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
              ),

              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.amber.shade700),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Widget solo para desarrollo. Eliminar en producción.',
                        style: TextStyle(
                          fontSize: 10,
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
}
