import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/view_state.dart';
import '../../domain/models/public_dashboard_content.dart';
import '../../domain/repositories/public_dashboard_repository.dart';

class PublicDashboardViewModel extends ChangeNotifier {
  PublicDashboardViewModel({required PublicDashboardRepository repository})
      : _repository = repository;

  final PublicDashboardRepository _repository;

  ViewState _state = ViewState.idle;
  PublicDashboardContent? _content;
  String? _errorMessage;

  ViewState get state => _state;
  PublicDashboardContent? get content => _content;
  String? get errorMessage => _errorMessage;

  PublicDashboardContent get displayContent =>
      _content ??
      PublicDashboardContent(
        stats: const PublicStats(
          totalTasks: 0,
          activeProjects: 0,
          teamMembers: 0,
          dailyReports: 0,
        ),
        features: PublicDashboardContent.defaultFeatures,
        recentTaskTitles: const [],
      );

  Future<void> loadDashboard() async {
    if (_state == ViewState.loading) return;

    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getDashboardContent();
      _content = result;
      _state = ViewState.success;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _state = ViewState.error;
    } catch (_) {
      _errorMessage = 'An unexpected error occurred.';
      _state = ViewState.error;
    }

    notifyListeners();
  }
}
