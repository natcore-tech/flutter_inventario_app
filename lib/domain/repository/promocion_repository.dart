import '../model/promocion.dart';

abstract class PromocionRepository {
    Future<List<Promocion>> getPromocionesActivas();
    Future<List<Promocion>> getPromocionesByProducto(String productoId);
}