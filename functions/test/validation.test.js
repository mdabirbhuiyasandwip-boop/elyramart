'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const {normalizeCart, normalizeContact} = require('../validation');

test('normalizes valid cart and combines duplicate products', () => {
  assert.deepEqual(normalizeCart([
    {productId: 'abc_1', quantity: 2},
    {productId: 'abc_1', quantity: 3},
    {productId: 'def-2', quantity: 1},
  ]), [
    {productId: 'abc_1', quantity: 5},
    {productId: 'def-2', quantity: 1},
  ]);
});

test('rejects empty carts, invalid IDs and unsafe quantities', () => {
  assert.throws(() => normalizeCart([]));
  assert.throws(() => normalizeCart([{productId: '../secret', quantity: 1}]));
  assert.throws(() => normalizeCart([{productId: 'p1', quantity: 0}]));
  assert.throws(() => normalizeCart([{productId: 'p1', quantity: 101}]));
});

test('validates and trims customer contact fields', () => {
  assert.deepEqual(normalizeContact(' 01700000000 ', ' Dhaka, Bangladesh '), {
    phone: '01700000000',
    deliveryAddress: 'Dhaka, Bangladesh',
  });
  assert.throws(() => normalizeContact('123', 'Dhaka'));
});
