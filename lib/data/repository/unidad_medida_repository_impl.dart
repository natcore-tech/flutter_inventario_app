import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/unidad_medida.dart';
import '../../domain/repository/unidad_medida_repository.dart';
import '../remote/api/unidad_medida_remote_datasource.dart';

class UnidadMedidaRepositoryImpl implements UnidadMedidaRepository {
    final UnidadMedidaRemoteDataSource remoteDataSource;

    UnidadMedidaRepositoryImpl(this.remoteDataSource);

    @override
    Future<List<UnidadMedida>> getUnidadesMedida() => remoteDataSource.getUnidadesMedida();

    @override
    Future<UnidadMedida?> getUnidadMedidaById(String id) => remoteDataSource.getUnidadMedidaById(id);
}

final unidadMedidaRepositoryProvider = Provider<UnidadMedidaRepository>((ref) {
    final dataSource = ref.watch(unidadMedidaRemoteDataSourceProvider);
    return UnidadMedidaRepositoryImpl(dataSource);
});