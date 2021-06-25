import 'package:aves/widgets/aves_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('widget test', (tester) async {
    await tester.pumpWidget(AvesApp());
  });
}
