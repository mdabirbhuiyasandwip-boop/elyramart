import 'package:flutter_test/flutter_test.dart';
import 'package:elyramart/screens/catalog_page.dart';

void main() {
  setUp(() => CartService.instance.items.clear());

  test('adding same product increments quantity and total', () {
    final cart = CartService.instance;
    cart.add('p1', {'title': 'Soap', 'price': 50});
    cart.add('p1', {'title': 'Soap', 'price': 50});
    expect(cart.items['p1']?['quantity'], 2);
    expect(cart.total, 100);
  });

  test('decreasing quantity to zero removes item', () {
    final cart = CartService.instance;
    cart.add('p1', {'title': 'Soap', 'price': 50});
    cart.change('p1', -1);
    expect(cart.items.containsKey('p1'), isFalse);
    expect(cart.total, 0);
  });
}
