import '../models/public_dashboard_content.dart';

abstract class PublicDashboardRepository {
  Future<PublicDashboardContent> getDashboardContent();
}
