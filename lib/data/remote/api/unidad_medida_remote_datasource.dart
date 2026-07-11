import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import 'dio_client.dart';
import '../../../domain/model/unidad_medida.dart';

class UnidadMedidaRemoteDataSource {
    final Dio dio;

    UnidadMedidaRemoteDataSource(this.dio);

    Future<List<UnidadMedida>> getUnidadesMedida() async {
        try {
            final response = await dio.get('/api/unidades-medida/');
            return (response.data as List).map((json) => UnidadMedida.fromJson(json)).toList();
        } on DioException catch (e) {
            throw ApiException('Error al obtener unidades de medida: ${e.message}');
        }
    }

    Future<UnidadMedida> getUnidadMedidaById(String id) async {
        try {
            final response = await dio.get('/api/unidades-medida/$id/');
            return UnidadMedida.fromJson(response.data);
        } on DioException catch (e) {
            throw ApiException('Error al obtener la unidad de medida: ${e.message}');
        }
    }
}

final unidadMedidaRemoteDataSourceProvider = Provider<UnidadMedidaRemoteDataSource>((ref) {
    final dio = ref.watch(dioProvider);
    return UnidadMedidaRemoteDataSource(dio);
});