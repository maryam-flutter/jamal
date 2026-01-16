class Salon {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String image;

  const Salon({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.image,
  });
}

class SalonService {
  final String id;
  final String salonId;
  final String titleKey;
  final String durationKey;
  final String priceKey;
  final String categoryKey;

  const SalonService({
    required this.id,
    required this.salonId,
    required this.titleKey,
    required this.durationKey,
    required this.priceKey,
    required this.categoryKey,
  });
}

class SalonMaster {
  final String id;
  final String salonId;
  final String name;
  final String image;

  const SalonMaster({
    required this.id,
    required this.salonId,
    required this.name,
    required this.image,
  });
}

class SalonRepository {
  static const List<Salon> _salons = [
    Salon(
      id: 'glow',
      name: 'Glow Beauty Salon',
      address: 'Toshkent, Mirzo Ulugbek',
      rating: 0.0,
      image: 'assets/salon.png',
    ),
    Salon(
      id: 'luxe',
      name: 'Luxe Hair Studio',
      address: 'Toshkent, Chilonzor',
      rating: 0.0,
      image: 'assets/beauty.png',
    ),
    Salon(
      id: 'elegance',
      name: 'Elegance Nails',
      address: 'Toshkent, Yunusobod',
      rating: 0.0,
      image: 'assets/ooo.png',
    ),
    Salon(
      id: 'aura',
      name: 'Aura Spa',
      address: 'Toshkent, Shayxontohur',
      rating: 0.0,
      image: 'assets/girls.png',
    ),
  ];

  static const List<SalonService> _services = [
    SalonService(
      id: 'glow_haircut',
      salonId: 'glow',
      titleKey: 'salon_service_haircut_title',
      durationKey: 'salon_service_haircut_duration',
      priceKey: 'salon_service_haircut_price',
      categoryKey: 'category_hair',
    ),
    SalonService(
      id: 'glow_manicure',
      salonId: 'glow',
      titleKey: 'salon_service_manicure_title',
      durationKey: 'salon_service_manicure_duration',
      priceKey: 'salon_service_manicure_price',
      categoryKey: 'category_manicure',
    ),
    SalonService(
      id: 'glow_facial',
      salonId: 'glow',
      titleKey: 'salon_service_facial_title',
      durationKey: 'salon_service_facial_duration',
      priceKey: 'salon_service_facial_price',
      categoryKey: 'category_face',
    ),
    SalonService(
      id: 'glow_bridal',
      salonId: 'glow',
      titleKey: 'salon_service_bridal_title',
      durationKey: 'salon_service_bridal_duration',
      priceKey: 'salon_service_bridal_price',
      categoryKey: 'category_makeup',
    ),
    SalonService(
      id: 'luxe_haircut',
      salonId: 'luxe',
      titleKey: 'salon_service_haircut_title',
      durationKey: 'salon_service_haircut_duration',
      priceKey: 'salon_service_haircut_price',
      categoryKey: 'category_hair',
    ),
    SalonService(
      id: 'luxe_manicure',
      salonId: 'luxe',
      titleKey: 'salon_service_manicure_title',
      durationKey: 'salon_service_manicure_duration',
      priceKey: 'salon_service_manicure_price',
      categoryKey: 'category_manicure',
    ),
    SalonService(
      id: 'luxe_facial',
      salonId: 'luxe',
      titleKey: 'salon_service_facial_title',
      durationKey: 'salon_service_facial_duration',
      priceKey: 'salon_service_facial_price',
      categoryKey: 'category_face',
    ),
    SalonService(
      id: 'luxe_bridal',
      salonId: 'luxe',
      titleKey: 'salon_service_bridal_title',
      durationKey: 'salon_service_bridal_duration',
      priceKey: 'salon_service_bridal_price',
      categoryKey: 'category_makeup',
    ),
    SalonService(
      id: 'elegance_haircut',
      salonId: 'elegance',
      titleKey: 'salon_service_haircut_title',
      durationKey: 'salon_service_haircut_duration',
      priceKey: 'salon_service_haircut_price',
      categoryKey: 'category_hair',
    ),
    SalonService(
      id: 'elegance_manicure',
      salonId: 'elegance',
      titleKey: 'salon_service_manicure_title',
      durationKey: 'salon_service_manicure_duration',
      priceKey: 'salon_service_manicure_price',
      categoryKey: 'category_manicure',
    ),
    SalonService(
      id: 'elegance_facial',
      salonId: 'elegance',
      titleKey: 'salon_service_facial_title',
      durationKey: 'salon_service_facial_duration',
      priceKey: 'salon_service_facial_price',
      categoryKey: 'category_face',
    ),
    SalonService(
      id: 'elegance_bridal',
      salonId: 'elegance',
      titleKey: 'salon_service_bridal_title',
      durationKey: 'salon_service_bridal_duration',
      priceKey: 'salon_service_bridal_price',
      categoryKey: 'category_makeup',
    ),
    SalonService(
      id: 'aura_haircut',
      salonId: 'aura',
      titleKey: 'salon_service_haircut_title',
      durationKey: 'salon_service_haircut_duration',
      priceKey: 'salon_service_haircut_price',
      categoryKey: 'category_hair',
    ),
    SalonService(
      id: 'aura_manicure',
      salonId: 'aura',
      titleKey: 'salon_service_manicure_title',
      durationKey: 'salon_service_manicure_duration',
      priceKey: 'salon_service_manicure_price',
      categoryKey: 'category_manicure',
    ),
    SalonService(
      id: 'aura_facial',
      salonId: 'aura',
      titleKey: 'salon_service_facial_title',
      durationKey: 'salon_service_facial_duration',
      priceKey: 'salon_service_facial_price',
      categoryKey: 'category_face',
    ),
    SalonService(
      id: 'aura_bridal',
      salonId: 'aura',
      titleKey: 'salon_service_bridal_title',
      durationKey: 'salon_service_bridal_duration',
      priceKey: 'salon_service_bridal_price',
      categoryKey: 'category_makeup',
    ),
  ];

  static List<Salon> getSalons() => List<Salon>.from(_salons);

  static Salon? getSalonById(String id) {
    for (final salon in _salons) {
      if (salon.id == id) return salon;
    }
    return null;
  }

  static List<SalonService> getServicesBySalon(String salonId) {
    return _services.where((s) => s.salonId == salonId).toList();
  }

  static List<SalonService> getServicesByCategory(String categoryKey) {
    return _services.where((s) => s.categoryKey == categoryKey).toList();
  }
}
