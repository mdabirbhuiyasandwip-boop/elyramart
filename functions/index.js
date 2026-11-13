'use strict';

const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');
const {normalizeCart, normalizeContact} = require('./validation');

initializeApp();
const db = getFirestore();

exports.placeOrder = onCall({region: 'asia-south1', maxInstances: 10}, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Please sign in before placing an order.');
  }

  let cart;
  let contact;
  try {
    cart = normalizeCart(request.data?.items);
    contact = normalizeContact(request.data?.phone, request.data?.deliveryAddress);
  } catch (error) {
    throw new HttpsError('invalid-argument', error.message);
  }

  const orderRef = db.collection('orders').doc();
  try {
    const order = await db.runTransaction(async (transaction) => {
      const productRefs = cart.map((item) => db.collection('products').doc(item.productId));
      const productSnapshots = await Promise.all(productRefs.map((ref) => transaction.get(ref)));
      const lines = [];
      let total = 0;

      for (let i = 0; i < cart.length; i += 1) {
        const item = cart[i];
        const snapshot = productSnapshots[i];
        if (!snapshot.exists) {
          throw new HttpsError('not-found', 'A product in your cart no longer exists.');
        }
        const product = snapshot.data();
        const price = product.price;
        const stock = product.stock;
        if (product.status !== 'active' || typeof price !== 'number' ||
            !Number.isFinite(price) || price <= 0 ||
            !Number.isInteger(stock) || stock < item.quantity) {
          throw new HttpsError('failed-precondition',
            'A product is unavailable, out of stock, or has invalid pricing.');
        }
        const lineTotal = Math.round(price * item.quantity * 100) / 100;
        total = Math.round((total + lineTotal) * 100) / 100;
        lines.push({
          productId: item.productId,
          title: String(product.title || 'Product').slice(0, 160),
          unitPrice: price,
          quantity: item.quantity,
          lineTotal,
          sellerUid: typeof product.sellerUid === 'string' ? product.sellerUid : null,
        });
      }

      // All reads are complete before transaction writes.
      for (let i = 0; i < cart.length; i += 1) {
        transaction.update(productRefs[i], {
          stock: productSnapshots[i].data().stock - cart[i].quantity,
          updatedAt: FieldValue.serverTimestamp(),
        });
      }

      transaction.create(orderRef, {
        customerUid: request.auth.uid,
        phone: contact.phone,
        deliveryAddress: contact.deliveryAddress,
        items: lines,
        total,
        status: 'pending',
        paymentMethod: 'cash_on_delivery',
        paymentStatus: 'unpaid',
        createdAt: FieldValue.serverTimestamp(),
      });
      return {orderId: orderRef.id, total};
    });
    return order;
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    console.error('placeOrder failed', error);
    throw new HttpsError('internal', 'Could not place your order. Please try again.');
  }
});
