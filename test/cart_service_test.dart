import 'package:flutter_test/flutter_test.dart';
import 'package:elyramart/screens/catalog_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    await CartService.instance.load();
    await CartService.instance.clear();
  });

  test('adding same product increments quantity and total', () async {
    final cart = CartService.instance;
    await cart.add('p1', {'title': 'Soap', 'price': 50, 'stock': 4});
    await cart.add('p1', {'title': 'Soap', 'price': 50, 'stock': 4});
    expect(cart.items['p1']?['quantity'], 2);
    expect(cart.total, 100);
  });

  test('decreasing quantity to zero removes item', () async {
    final cart = CartService.instance;
    await cart.add('p1', {'title': 'Soap', 'price': 50, 'stock': 4});
    await cart.change('p1', -1);
    expect(cart.items.containsKey('p1'), isFalse);
    expect(cart.total, 0);
  });

  test('cart content is stored on device preferences', () async {
    final cart = CartService.instance;
    await cart.add('p2', {'title': 'Rice', 'price': 80, 'stock': 2});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('elyramart_cart_v1'), contains('Rice'));
  });
}
