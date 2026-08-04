import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the documents directory native bridge is bundled', (_) async {
    final directory = await getApplicationDocumentsDirectory();

    expect(directory.path, isNotEmpty);
    expect(await directory.exists(), isTrue);
  });
}
