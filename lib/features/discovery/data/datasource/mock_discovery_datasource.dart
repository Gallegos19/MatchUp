
import '../../domain/repositories/discovery_repository.dart';
import '../models/profile_model.dart';

class MockDiscoveryDataSource {
  static Future<List<ProfileModel>> getMockProfiles({
    DiscoveryFilters? filters,
    int page = 1,
    int limit = 10,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    // Datos mock para probar
    final mockProfiles = [
      ProfileModel(
        id: '1',
        userId: 'user_1',
        name: 'María García',
        age: 21,
        career: 'Ingeniería en Sistemas',
        semester: '6',
        campus: 'Campus Norte',
        bio: 'Me encanta la tecnología y el café ☕. Buscando nuevos amigos para estudiar y compartir aventuras universitarias.',
        interests: ['Programación', 'Café', 'Música', 'Senderismo'],
        photoUrls: [
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
        ],
        distance: 2.5,
        isActive: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
        isVerified: true,
      ),
      ProfileModel(
        id: '2',
        userId: 'user_2',
        name: 'Carlos Mendoza',
        age: 22,
        career: 'Medicina',
        semester: '8',
        campus: 'Campus Sur',
        bio: 'Futuro médico apasionado por ayudar a otros. En mis tiempos libres toco guitarra y juego fútbol.',
        interests: ['Medicina', 'Guitarra', 'Fútbol', 'Voluntariado'],
        photoUrls: [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        ],
        distance: 1.2,
        isActive: true,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        isVerified: false,
      ),
      ProfileModel(
        id: '3',
        userId: 'user_3',
        name: 'Ana Rodríguez',
        age: 20,
        career: 'Diseño Gráfico',
        semester: '4',
        campus: 'Campus Centro',
        bio: 'Creativa por naturaleza 🎨. Amo el arte, los colores y las buenas conversaciones. Siempre lista para una nueva aventura.',
        interests: ['Arte', 'Diseño', 'Fotografía', 'Viajes'],
        photoUrls: [
          'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400',
          'https://images.unsplash.com/photo-1521310192545-4ac7951413f0?w=400',
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
        ],
        distance: 0.8,
        isActive: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        isVerified: true,
      ),
      ProfileModel(
        id: '4',
        userId: 'user_4',
        name: 'David López',
        age: 23,
        career: 'Administración de Empresas',
        semester: '10',
        campus: 'Campus Norte',
        bio: 'Emprendedor en formación. Me gusta la música electrónica, los deportes extremos y conocer gente nueva.',
        interests: ['Emprendimiento', 'Música', 'Deportes', 'Networking'],
        photoUrls: [
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
        ],
        distance: 3.1,
        isActive: true,
        lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
        isVerified: false,
      ),
      ProfileModel(
        id: '5',
        userId: 'user_5',
        name: 'Sofia Herrera',
        age: 19,
        career: 'Psicología',
        semester: '2',
        campus: 'Campus Sur',
        bio: 'Amante de los libros y la naturaleza 📚🌿. Busco conexiones genuinas y conversaciones profundas.',
        interests: ['Psicología', 'Lectura', 'Yoga', 'Naturaleza'],
        photoUrls: [
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
          'https://images.unsplash.com/photo-1524638431109-93d95c968f03?w=400',
        ],
        distance: 4.7,
        isActive: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
        isVerified: true,
      ),
    ];

    // Simular paginación
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= mockProfiles.length) {
      return [];
    }
    
    final paginatedProfiles = mockProfiles.sublist(
      startIndex,
      endIndex > mockProfiles.length ? mockProfiles.length : endIndex,
    );

    return paginatedProfiles;
  }

  static Future<bool> mockSwipeProfile({
    required String profileId,
    required SwipeAction action,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Simular match (20% de probabilidad)
    if (action == SwipeAction.like) {
      return DateTime.now().millisecond % 5 == 0; // 20% chance
    }

    return false;
  }
}