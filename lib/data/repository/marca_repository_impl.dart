import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/marca.dart';
import '../../domain/repository/marca_repository.dart';
import '../remote/api/marca_remote_datasource.dart';

class MarcaRepositoryImpl implements MarcaRepository {
    final MarcaRemoteDataSource remoteDataSource;

    MarcaRepositoryImpl(this.remoteDataSource);

    @override
    Future<List<Marca>> getMarcas() => remoteDataSource.getMarcas();

    @override
    Future<Marca?> getMarcaById(String id) => remoteDataSource.getMarcaById(id);

    @override
    Future<Marca> createMarca(Marca marca) => remoteDataSource.createMarca(marca);

    @override
    Future<Marca> updateMarca(Marca marca) => remoteDataSource.updateMarca(marca);

    @override
    Future<void> deleteMarca(String id) => remoteDataSource.deleteMarca(id);
    }

final marcaRepositoryProvider = Provider<MarcaRepository>((ref) {
    final dataSource = ref.watch(marcaRemoteDataSourceProvider);
    return MarcaRepositoryImpl(dataSource);
});