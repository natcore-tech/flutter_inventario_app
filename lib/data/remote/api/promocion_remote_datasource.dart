import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/api_exception.dart';
import 'dio_client.dart';
import '../../../domain/model/promocion.dart';

class PromocionRemoteDataSource {
    final Dio dio;

    PromocionRemoteDataSource(this.dio);

    Future<List<Promocion>> getPromocionesActivas() async {
        try {
            final response = await dio.get('/api/promociones/', queryParameters: {'activa': true});
            return (response.data as List).map((json) => Promocion.fromJson(json)).toList();
        } on DioException catch (e) {
            throw ApiException('Error al obtener promociones activas: ${e.message}');
        }
    }

    Future<List<Promocion>> getPromocionesByProducto(String productoId) async {
        try {
            final response = await dio.get('/api/promociones/', queryParameters: {'producto_id': productoId});
            return (response.data as List).map((json) => Promocion.fromJson(json)).toList();
        } on DioException catch (e) {
            throw ApiException('Error al obtener promociones del producto: ${e.message}');
        }
    }
}

final promocionRemoteDataSourceProvider = Provider<PromocionRemoteDataSource>((ref) {
    final dio = ref.watch(dioProvider);
    return PromocionRemoteDataSource(dio);
});