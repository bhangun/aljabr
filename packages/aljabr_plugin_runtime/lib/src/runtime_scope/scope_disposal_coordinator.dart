import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

class ScopeDisposalCoordinator {
  final Set<ScopeId> _activeDisposals = {};

  Future<void> disposeScope(RuntimeScope scope) async {
    if (_activeDisposals.contains(scope.id)) {
      return;
    }

    _activeDisposals.add(scope.id);
    try {
      await scope.dispose();
    } finally {
      _activeDisposals.remove(scope.id);
    }
  }
}
