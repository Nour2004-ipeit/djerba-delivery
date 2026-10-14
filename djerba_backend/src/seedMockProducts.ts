import { db } from './db';
import { restaurants, products } from './db/schema';
import { eq } from 'drizzle-orm';

async function main() {
  try {
    // Check if mock restaurant exists
    const existingResto = await db.select().from(restaurants).where(eq(restaurants.id, 'mockRestaurantId')).get();
    
    if (!existingResto) {
      console.log('Inserting mock restaurant...');
      await db.insert(restaurants).values({
        id: 'mockRestaurantId',
        name: 'Mock Restaurant',
        address: 'Mock Address',
        lat: 33.88,
        lng: 10.85,
        isActive: true,
      });
    }

    // Check if mock product exists
    const existingProd = await db.select().from(products).where(eq(products.id, 'mockProductId')).get();
    if (!existingProd) {
      console.log('Inserting mock product...');
      await db.insert(products).values({
        id: 'mockProductId',
        restaurantId: 'mockRestaurantId',
        name: 'Mock Product',
        price: 15.000,
        isAvailable: true,
      });
    }

    console.log('Mock data seeded successfully!');
    process.exit(0);
  } catch (err) {
    console.error('Error seeding mock data:', err);
    process.exit(1);
  }
}

main();
