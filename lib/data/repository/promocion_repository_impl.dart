import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/promocion.dart';
import '../../domain/repository/promocion_repository.dart';
import '../remote/api/promocion_remote_datasource.dart';

class PromocionRepositoryImpl implements PromocionRepository {
  final PromocionRemoteDataSource remoteDataSource;

  PromocionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Promocion>> getPromocionesActivas() => remoteDataSource.getPromocionesActivas();

  @override
  Future<List<Promocion>> getPromocionesByProducto(String productoId) => 
      remoteDataSource.getPromocionesByProducto(productoId);
}

final promocionRepositoryProvider = Provider<PromocionRepository>((ref) {
  final dataSource = ref.watch(promocionRemoteDataSourceProvider);
  return PromocionRepositoryImpl(dataSource);
});