// lib/services/medical_record_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medical_record.dart';

class MedicalRecordService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Cambia por tu URL

  // Crear un registro médico
  static Future<Map<String, dynamic>> createMedicalRecord(
      String token, MedicalRecordCreate record) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medical-records'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(record.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al crear registro médico');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener registros médicos del usuario actual
  static Future<List<MedicalRecord>> getMyMedicalRecords(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medical-records/my-records'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((record) => MedicalRecord.fromJson(record)).toList();
      } else {
        throw Exception('Error al obtener registros médicos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un registro médico específico
  static Future<MedicalRecord> getMedicalRecordById(
      String token, int recordId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medical-records/$recordId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return MedicalRecord.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener registro médico');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
