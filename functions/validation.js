'use strict';

function normalizeCart(items) {
  if (!Array.isArray(items) || items.length < 1 || items.length > 50) {
    throw new Error('Cart must contain between 1 and 50 items.');
  }
  const quantities = new Map();
  for (const item of items) {
    if (!item || typeof item.productId !== 'string' ||
        !/^[A-Za-z0-9_-]{1,128}$/.test(item.productId)) {
      throw new Error('Invalid product identifier.');
    }
    if (!Number.isInteger(item.quantity) || item.quantity < 1 || item.quantity > 100) {
      throw new Error('Quantity must be an integer between 1 and 100.');
    }
    const next = (quantities.get(item.productId) || 0) + item.quantity;
    if (next > 100) throw new Error('Combined product quantity cannot exceed 100.');
    quantities.set(item.productId, next);
  }
  return [...quantities.entries()].map(([productId, quantity]) => ({productId, quantity}));
}

function normalizeContact(phone, deliveryAddress) {
  if (typeof phone !== 'string' || phone.trim().length < 6 || phone.trim().length > 24) {
    throw new Error('Enter a valid contact phone number.');
  }
  if (typeof deliveryAddress !== 'string' ||
      deliveryAddress.trim().length < 6 || deliveryAddress.trim().length > 500) {
    throw new Error('Enter a complete delivery address.');
  }
  return {phone: phone.trim(), deliveryAddress: deliveryAddress.trim()};
}

module.exports = {normalizeCart, normalizeContact};
