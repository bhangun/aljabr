import '../extensions/contribution_registry.dart';
import 'settings_contribution.dart';

class SettingsRegistry extends ContributionRegistry<SettingsPageContribution> {
  List<SettingsPageContribution> forSection(String section) {
    final pages = getAll().where((page) => page.section == section).toList();
    pages.sort((a, b) => a.order.compareTo(b.order));
    return pages;
  }

  List<String> get sections {
    final result = getAll().map((page) => page.section).toSet().toList();
    result.sort();
    return result;
  }
}
