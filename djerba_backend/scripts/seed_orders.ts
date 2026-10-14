import { createClient } from '@libsql/client';
import { drizzle } from 'drizzle-orm/libsql';
import * as schema from '../src/db/schema';
import crypto from 'crypto';

const client = createClient({ url: 'file:sqlite.db' });
const db = drizzle(client, { schema });

async function seed() {
  const users = await db.query.user.findMany();
  const clientUser = users.find(u => u.role === 'client');
  const driverUser = users.find(u => u.role === 'driver');
  
  const restaurants = await db.query.restaurants.findMany();
  if (restaurants.length === 0) {
    console.log("No restaurants found to assign to orders");
    return;
  }
  const restaurant = restaurants[0];
  
  if (!clientUser || !driverUser) {
    console.log("Missing required users");
    return;
  }
  
  const now = new Date();
  
  const dummyOrders = [
    {
      id: crypto.randomUUID(),
      orderNumber: 'CMD-1001',
      clientId: clientUser.id,
      restaurantId: restaurant.id,
      driverId: driverUser.id,
      status: 'delivered',
      subtotal: 25.5,
      deliveryFee: 4.5,
      totalAmount: 30.0,
      deliveryAddress: 'Houmt Souk Center',
      deliveryLat: 33.876,
      deliveryLng: 10.858,
      createdAt: new Date(now.getTime() - 1000 * 60 * 60 * 24), // 1 day ago
    },
    {
      id: crypto.randomUUID(),
      orderNumber: 'CMD-1002',
      clientId: clientUser.id,
      restaurantId: restaurant.id,
      driverId: driverUser.id,
      status: 'pending',
      subtotal: 12.0,
      deliveryFee: 4.5,
      totalAmount: 16.5,
      deliveryAddress: 'Midoun, Djerba',
      deliveryLat: 33.811,
      deliveryLng: 10.992,
      createdAt: new Date(now.getTime() - 1000 * 60 * 30), // 30 mins ago
    },
    {
      id: crypto.randomUUID(),
      orderNumber: 'CMD-1003',
      clientId: clientUser.id,
      restaurantId: restaurant.id,
      driverId: driverUser.id,
      status: 'preparing',
      subtotal: 45.0,
      deliveryFee: 4.5,
      totalAmount: 49.5,
      deliveryAddress: 'Aghir, Zone Touristique',
      deliveryLat: 33.784,
      deliveryLng: 11.026,
      createdAt: new Date(now.getTime() - 1000 * 60 * 5), // 5 mins ago
    }
  ];

  for (const o of dummyOrders) {
    await db.insert(schema.orders).values(o as any);
  }
  
  console.log("Dummy orders seeded!");
}

seed();
