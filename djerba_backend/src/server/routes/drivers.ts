import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { requireAuth } from '../middlewares/auth';
import { DispatchService } from '../services/dispatch';
import { db } from '../../db';
import { driverProfiles, orders } from '../../db/schema';
import { eq, and, gte, lte } from 'drizzle-orm';

export const driversRoute = new Hono()
  .post(
    '/location',
    requireAuth(['driver']),
    zValidator('json', z.object({
      lat: z.number(),
      lng: z.number(),
    })),
    async (c) => {
      const user = c.get('user');
      const { lat, lng } = c.req.valid('json');

      try {
        await DispatchService.updateDriverLocation(user.id, lat, lng);
        // Also update SQL for polling clients
        await db.update(driverProfiles)
          .set({ currentLat: lat, currentLng: lng })
          .where(eq(driverProfiles.userId, user.id));
          
        return c.json({ success: true });
      } catch (error) {
        console.error("Driver Location Update Error:", error);
        return c.json({ error: 'Erreur lors de la mise à jour de la position' }, 500);
      }
    }
  )
  .get(
    '/stats',
    requireAuth(['driver']),
    async (c) => {
      const user = c.get('user');

      try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        const driverOrders = await db.query.orders.findMany({
          where: and(
            eq(orders.driverId, user.id),
            eq(orders.status, 'delivered'),
            gte(orders.createdAt, today),
            lte(orders.createdAt, tomorrow)
          ),
          columns: {
            deliveryFee: true
          }
        });

        const deliveriesCount = driverOrders.length;
        const totalEarnings = driverOrders.reduce((sum, order) => sum + (order.deliveryFee || 0), 0);

        return c.json({
          success: true,
          todayEarnings: totalEarnings,
          todayDeliveries: deliveriesCount,
          activeHours: 5.5, // Mocked for now since there's no shift tracking
          rating: 4.9 // Mocked for now
        });
      } catch (error) {
        console.error("Driver Stats Error:", error);
        return c.json({ error: 'Erreur lors de la récupération des statistiques' }, 500);
      }
    }
  );
