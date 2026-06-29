import '../network/api_client.dart';
import '../storage/preferences_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/public_dashboard/data/datasources/public_dashboard_remote_datasource.dart';
import '../../features/public_dashboard/data/repositories/public_dashboard_repository_impl.dart';
import '../../features/public_dashboard/domain/repositories/public_dashboard_repository.dart';

class AppDependencies {
  AppDependencies._({
    required this.secureStorage,
    required this.preferences,
    required this.apiClient,
    required this.publicDashboardRepository,
  });

  final SecureStorageService secureStorage;
  final PreferencesService preferences;
  final ApiClient apiClient;
  final PublicDashboardRepository publicDashboardRepository;

  static late final AppDependencies instance;

  static Future<void> initialize() async {
    final secureStorage = SecureStorageService();
    final preferences = await PreferencesService.create();
    final apiClient = ApiClient(secureStorage: secureStorage);

    final publicDashboardRemoteDataSource = PublicDashboardRemoteDataSource(
      apiClient: apiClient,
    );

    final publicDashboardRepository = PublicDashboardRepositoryImpl(
      remoteDataSource: publicDashboardRemoteDataSource,
    );

    instance = AppDependencies._(
      secureStorage: secureStorage,
      preferences: preferences,
      apiClient: apiClient,
      publicDashboardRepository: publicDashboardRepository,
    );
  }

}
