
import 'package:flutter_inventario_app/presentation/domain/model/producto_lite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/api/producto_lite_remote_datasource.dart';

final productosSearchProvider =
    FutureProvider.family<List<ProductoLite>, String>((ref, query) {
  return ref.watch(productoLiteDatasourceProvider).getProductos(search: query);
});