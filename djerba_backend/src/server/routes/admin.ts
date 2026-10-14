import { Hono } from 'hono';
import { requireAuth } from '../middlewares/auth';
import { db } from '../../db';
import { orders, user } from '../../db/schema';
import { eq, sum } from 'drizzle-orm';

export const adminRoute = new Hono()
  .get('/stats', requireAuth(['admin']), async (c) => {
  try {
    // Count total users
    const allUsers = await db.select().from(user);
    const totalUsers = allUsers.length;

    // Count total orders
    const allOrders = await db.select().from(orders);
    const totalOrders = allOrders.length;

    // Calculate total revenue
    let totalRevenue = 0;
    allOrders.forEach(o => {
      if (o.status === 'delivered') {
         totalRevenue += (o.totalAmount || 0);
      }
    });

    // Count active drivers
    const activeDrivers = allUsers.filter(u => u.role === 'driver').length;

    return c.json({
      totalRevenue,
      totalOrders,
      totalUsers,
      activeDrivers,
    });
  } catch (error) {
    console.error('Error fetching admin stats:', error);
    return c.json({ error: 'Internal Server Error' }, 500);
  }
});
