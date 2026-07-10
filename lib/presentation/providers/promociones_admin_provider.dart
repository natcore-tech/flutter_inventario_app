import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/promocion.dart';
import '../../data/repository/promocion_repository_impl.dart';

class PromocionesAdminNotifier extends AsyncNotifier<List<Promocion>> {
    @override
    Future<List<Promocion>> build() async {
        return _fetchPromociones();
    }

    Future<List<Promocion>> _fetchPromociones() async {
        return await ref.read(promocionRepositoryProvider).getPromocionesActivas();
    }

    Future<void> addPromocion(Promocion promo) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
        // await ref.read(promocionRepositoryProvider).createPromocion(promo);
        return _fetchPromociones();
        });
    }

    Future<void> updatePromocion(Promocion promo) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
        // await ref.read(promocionRepositoryProvider).updatePromocion(promo);
        return _fetchPromociones();
        });
    }
}

final promocionesAdminProvider = AsyncNotifierProvider<PromocionesAdminNotifier, List<Promocion>>(() {
    return PromocionesAdminNotifier();
});