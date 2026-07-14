// lib/data/remote/api/cliente_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_inventario_app/data/remote/api/dio_client.dart';
import 'package:flutter_inventario_app/presentation/domain/model/cliente.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClienteRemoteDatasource {
  final Dio _dio;

  ClienteRemoteDatasource(this._dio);

  Future<List<Cliente>> getClientes() async {
    final response = await _dio.get('/clientes/');
    if (response.statusCode == 200) {
      final raw = response.data;
      final List<dynamic> data = raw is Map<String, dynamic>
          ? (raw['results'] as List<dynamic>)
          : raw as List<dynamic>;
      return data.map((json) => Cliente.fromJson(json)).toList();
    }
    throw Exception('Error al cargar clientes: ${response.statusCode}');
  }

  Future<Cliente> createCliente(Map<String, dynamic> payload) async {
    final response = await _dio.post('/clientes/', data: payload);
    return Cliente.fromJson(response.data);
  }

  Future<Cliente> updateCliente(int id, Map<String, dynamic> payload) async {
    final response = await _dio.patch('/clientes/$id/', data: payload);
    return Cliente.fromJson(response.data);
  }

  Future<void> deleteCliente(int id) async {
    final response = await _dio.delete('/clientes/$id/');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar el cliente');
    }
  }
}

final clienteDatasourceProvider = Provider<ClienteRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return ClienteRemoteDatasource(dio);
});
