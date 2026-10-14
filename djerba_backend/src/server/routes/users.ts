import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { requireAuth } from '../middlewares/auth';
import { db } from '../../db';
import { user } from '../../db/schema';
import { eq } from 'drizzle-orm';

export const usersRoute = new Hono()
  .get('/', requireAuth(['admin']), async (c) => {
  try {
    // Return all users for admin
    const allUsers = await db.select().from(user);
    // Exclude password hashes if any
    const safeUsers = allUsers.map(u => ({
      id: u.id,
      name: u.name,
      email: u.email,
      emailVerified: u.emailVerified,
      image: u.image,
      createdAt: u.createdAt,
      updatedAt: u.updatedAt,
      role: u.role,
    }));
    return c.json(safeUsers);
  } catch (error) {
    console.error('Error fetching users:', error);
    return c.json({ error: 'Internal Server Error' }, 500);
  }
})
.put('/me/fcm-token', requireAuth(), zValidator('json', z.object({ fcmToken: z.string() })), async (c) => {
  const sessionUser = c.get('user');
  const { fcmToken } = c.req.valid('json');
  
  try {
    await db.update(user).set({ fcmToken }).where(eq(user.id, sessionUser.id));
    return c.json({ success: true });
  } catch (error) {
    console.error('Error updating FCM token:', error);
    return c.json({ error: 'Internal Server Error' }, 500);
  }
});
